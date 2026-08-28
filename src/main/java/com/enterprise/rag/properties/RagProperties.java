package com.enterprise.rag.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * RAG 系统自定义配置
 *
 * @author Enterprise RAG Team
 */
@Data
@Configuration
@ConfigurationProperties(prefix = "enterprise.rag")
public class RagProperties {

    private MilvusConfig milvus = new MilvusConfig();
    private DocumentConfig document = new DocumentConfig();
    private PermissionConfig permission = new PermissionConfig();
    private RedisConfig redis = new RedisConfig();

    @Data
    public static class MilvusConfig {
        private String host = "localhost";
        private Integer port = 19530;
        private String collectionName = "rag_document_chunks";
        private Integer dimension = 1024;
        private String metricType = "COSINE";
        private String indexType = "IVF_FLAT";
        private Integer nlist = 100;
    }

    @Data
    public static class DocumentConfig {
        private ChunkConfig chunk = new ChunkConfig();
        private Integer parseTimeout = 120;
        private Integer vectorTimeout = 300;

        @Data
        public static class ChunkConfig {
            private Integer maxSize = 300;
            private Integer overlap = 30;
            private String strategy = "fixed";
        }
    }

    @Data
    public static class PermissionConfig {
        private String defaultView = "PUBLIC";
        private Boolean deptPermissionEnabled = true;
    }

    @Data
    public static class RedisConfig {
        private String host = "localhost";
        private Integer port = 6379;
        private String password = "";
        private Integer database = 0;
    }
}
