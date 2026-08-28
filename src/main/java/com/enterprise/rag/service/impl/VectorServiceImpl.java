package com.enterprise.rag.service.impl;

import cn.hutool.core.util.StrUtil;
import com.enterprise.rag.domain.DocumentChunk;
import com.enterprise.rag.exception.VectorDatabaseException;
import com.enterprise.rag.repository.DocumentChunkMapper;
import com.enterprise.rag.service.api.VectorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.Embedding;
import org.springframework.ai.embedding.EmbeddingClient;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    private final EmbeddingModel embeddingClient;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void embedAndStoreChunks(Long documentId, List<DocumentChunk> chunks) {
        try {
            for (DocumentChunk chunk : chunks) {
                try {
                    List<Double> embedding = embeddingClient.embed(chunk.getContent());

                    org.springframework.ai.document.Document doc = Document.builder()
                            .withContent(chunk.getContent())
                            .withMetadata("chunkId", String.valueOf(chunk.getId()))
                            .withMetadata("documentId", String.valueOf(documentId))
                            .withMetadata("chunkIndex", String.valueOf(chunk.getChunkIndex()))
                            .build();

                    vectorStore.add(Collections.singletonList(doc));

                    chunk.setEmbeddingStatus(2);
                    chunk.setVectorId(String.valueOf(chunk.getId()));
                    chunkMapper.updateById(chunk);

                } catch (Exception e) {
                    log.error("单个分片向量化失败: chunkId={}", chunk.getId(), e);
                    chunk.setEmbeddingStatus(3);
                    chunk.setErrorMessage(e.getMessage());
                    chunkMapper.updateById(chunk);
                }
            }
        } catch (Exception e) {
            log.error("批量向量化失败: documentId={}", documentId, e);
            throw new VectorDatabaseException("向量入库失败：" + e.getMessage());
        }
    }

    @Override
    public void deleteVectors(List<String> vectorIds) {
        try {
            log.warn("向量删除暂未实现");
        } catch (Exception e) {
            throw new VectorDatabaseException("向量删除失败：" + e.getMessage());
        }
    }

    @Override
    public List<DocumentChunk> searchSimilar(String query, int topK, Double threshold) {
        try {
            List<Float> queryEmbedding = embeddingClient.embed(query);

            SearchRequest searchRequest = SearchRequest.builder()
                    .query(query)
                    .topK(topK)
                    .similarityThreshold(threshold)
                    .build();

            List<org.springframework.ai.document.Document> results = vectorStore.similaritySearch(searchRequest);

            return results.stream()
                    .map(doc -> {
                        DocumentChunk chunk = new DocumentChunk();
                        chunk.setId(Long.parseLong(doc.getMetadata().get("chunkId")));
                        chunk.setDocumentId(Long.parseLong(doc.getMetadata().get("documentId")));
                        chunk.setChunkIndex(Integer.parseInt(doc.getMetadata().get("chunkIndex")));
                        chunk.setContent(doc.getContent());
                        return chunk;
                    })
                    .collect(Collectors.toList());

        } catch (Exception e) {
            log.error("向量检索失败", e);
            throw new VectorDatabaseException("向量检索失败：" + e.getMessage());
        }
    }
}
