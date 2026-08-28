package com.enterprise.rag.service.api;

import com.enterprise.rag.domain.DocumentChunk;

import java.util.List;

/**
 * 向量服务接口
 */
public interface VectorService {
    void embedAndStoreChunks(Long documentId, List<DocumentChunk> chunks);
    void deleteVectors(List<String> vectorIds);
    List<DocumentChunk> searchSimilar(String query, int topK, Double threshold);
}
