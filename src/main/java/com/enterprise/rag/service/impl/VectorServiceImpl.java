package com.enterprise.rag.service.impl;

import cn.hutool.core.util.StrUtil;
import com.enterprise.rag.domain.DocumentChunk;
import com.enterprise.rag.exception.VectorDatabaseException;
import com.enterprise.rag.repository.DocumentChunkMapper;
import com.enterprise.rag.service.api.VectorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 向量服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class VectorServiceImpl implements VectorService {

    private final DocumentChunkMapper chunkMapper;
    private final VectorStore vectorStore;

    /**
     * 批量分片向量化并入库
     * 注意：向量库是外部中间件，不受MySQL事务管理，移除@Transactional
     * 单条分片失败只标记当前chunk状态，不影响其他分片
     * embeddingStatus: 0待处理,1成功,2向量化中,3失败
     */
    @Override
    public void embedAndStoreChunks(Long documentId, List<DocumentChunk> chunks) {
        if (chunks == null || chunks.isEmpty()) {
            log.warn("分片集合为空，跳过向量化 documentId={}", documentId);
            return;
        }

        List<Document> aiDocumentList = new ArrayList<>(chunks.size());
        Map<String, DocumentChunk> aiDocToChunkMap = new HashMap<>();

        for (DocumentChunk chunk : chunks) {
            Map<String, Object> metadata = new HashMap<>();
            metadata.put("chunkId", String.valueOf(chunk.getId()));
            metadata.put("documentId", String.valueOf(documentId));
            metadata.put("chunkIndex", String.valueOf(chunk.getChunkIndex()));

            Document aiDoc = new Document(chunk.getContent(), metadata);
            aiDocumentList.add(aiDoc);
            aiDocToChunkMap.put(aiDoc.getId(), chunk);
        }

        try {
            vectorStore.add(aiDocumentList);

            for (Document aiDoc : aiDocumentList) {
                DocumentChunk chunk = aiDocToChunkMap.get(aiDoc.getId());
                chunk.setEmbeddingStatus(1);
                chunk.setVectorId(aiDoc.getId());
                chunk.setErrorMessage(null);
                chunkMapper.updateById(chunk);
            }
            log.info("文档批量向量化完成 documentId={}, chunkSize={}", documentId, chunks.size());

        } catch (Exception e) {
            log.error("批量向量化整体异常 documentId={}", documentId, e);
            for (DocumentChunk chunk : chunks) {
                chunk.setEmbeddingStatus(3);
                chunk.setErrorMessage(StrUtil.maxLength(e.getMessage(), 500));
                chunkMapper.updateById(chunk);
            }
            throw new VectorDatabaseException("向量批量入库失败：" + e.getMessage());
        }
    }


    /**
     * 根据向量库真实vectorId列表删除向量
     * @param vectorIds 向量库主键ID（Spring‑AI Document.getId()）
     */
    @Override
    public void deleteVectors(List<String> vectorIds) {
        if (vectorIds == null || vectorIds.isEmpty()) {
            return;
        }
        try {
            log.info("开始删除向量数据，size={}", vectorIds.size());
            // Spring‑AI VectorStore 删除，传入AI Document的id集合
            vectorStore.delete(vectorIds);
            log.info("向量删除完成");
        } catch (Exception e) {
            log.error("向量删除失败 vectorIds={}", vectorIds, e);
            throw new VectorDatabaseException("向量删除失败：" + e.getMessage());
        }
    }

    /**
     * 相似度检索
     * @param query 查询文本
     * @param topK 返回条数
     * @param threshold 相似度阈值
     * @return 分片列表
     */
    @Override
    public List<DocumentChunk> searchSimilar(String query, int topK, Double threshold) {
        if (StrUtil.isBlank(query)) {
            return Collections.emptyList();
        }
        try {
            // SearchRequest内部会自动调用embeddingClient，不需要手动embed
            SearchRequest searchRequest = SearchRequest.defaults().withQuery(query).withTopK(topK).withSimilarityThreshold(threshold);

            List<Document> results = vectorStore.similaritySearch(searchRequest);

            return results.stream()
                    .filter(doc -> doc.getMetadata() != null)
                    .filter(doc -> doc.getMetadata().containsKey("chunkId"))
                    .map(doc -> {
                        DocumentChunk chunk = new DocumentChunk();
                        chunk.setId(Long.parseLong(doc.getMetadata().get("chunkId").toString()));
                        chunk.setDocumentId(Long.parseLong(doc.getMetadata().get("documentId").toString()));
                        chunk.setChunkIndex(Integer.parseInt(doc.getMetadata().get("chunkIndex").toString()));
                        chunk.setContent(doc.getContent());
                        return chunk;
                    })
                    .collect(Collectors.toList());

        } catch (Exception e) {
            log.error("向量检索失败 query={}", query, e);
            throw new VectorDatabaseException("向量检索失败：" + e.getMessage());
        }
    }
}
