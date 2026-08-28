package com.enterprise.rag.config;

import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.ai.vectorstore.filter.FilterExpressionBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * 自定义内存向量库（仅用于测试）
 */
@Component
public class CustomInMemoryVectorStore implements VectorStore {

    private final Map<String, Document> documents = new ConcurrentHashMap<>();
    private final Map<String, List<Double>> vectors = new ConcurrentHashMap<>();

    @Autowired
    private EmbeddingModel embeddingModel;

    @Override
    public void add(List<Document> documents) {
        for (Document doc : documents) {
            String id = UUID.randomUUID().toString();
            this.documents.put(id, doc);

            // 生成向量
            List<Double> embedding = embeddingModel.embed(doc.getContent());
            this.vectors.put(id, embedding);
        }
    }

    @Override
    public Optional<Boolean> delete(List<String> documentIds) {
        try{
            documentIds.forEach(id -> {
                this.documents.remove(id);
                this.vectors.remove(id);
            });
        } catch (Exception e){
            return Optional.empty();
        }
        return Optional.of(true);
    }

    @Override
    public List<Document> similaritySearch(SearchRequest request) {
        if (vectors.isEmpty()) {
            return Collections.emptyList();
        }

        // 获取查询向量
        List<Double> queryEmbedding = embeddingModel.embed(request.getQuery());

        // 计算相似度
        List<ScoredDocument> scoredDocs = vectors.entrySet().stream()
                .map(entry -> {
                    double similarity = cosineSimilarity(queryEmbedding, entry.getValue());
                    return new ScoredDocument(entry.getKey(), similarity);
                })
                .filter(sd -> sd.score >= request.getSimilarityThreshold())
                .sorted((a, b) -> Double.compare(b.score, a.score))
                .limit(request.getTopK())
                .collect(Collectors.toList());

        return scoredDocs.stream()
                .map(sd -> documents.get(sd.documentId))
                .collect(Collectors.toList());
    }

    // 余弦相似度计算
    private double cosineSimilarity(List<Double> v1, List<Double> v2) {
        double dotProduct = 0.0;
        double norm1 = 0.0;
        double norm2 = 0.0;

        for (int i = 0; i < v1.size(); i++) {
            dotProduct += v1.get(i) * v2.get(i);
            norm1 += v1.get(i) * v1.get(i);
            norm2 += v2.get(i) * v2.get(i);
        }

        if (norm1 == 0 || norm2 == 0) {
            return 0.0;
        }

        return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
    }

    private static class ScoredDocument {
        final String documentId;
        final double score;

        ScoredDocument(String documentId, double score) {
            this.documentId = documentId;
            this.score = score;
        }
    }
}