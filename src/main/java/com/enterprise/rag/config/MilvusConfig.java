//package com.enterprise.rag.config;
//
//import com.enterprise.rag.properties.RagProperties;
//import io.milvus.client.MilvusServiceClient;
//import io.milvus.common.clientenum.ConsistencyLevelEnum;
//import io.milvus.grpc.DataType;
//import io.milvus.param.ConnectParam;
//import io.milvus.param.collection.CreateCollectionParam;
//import io.milvus.param.collection.FieldType;
//import org.springframework.ai.vectorstore.VectorStore;
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//
//import java.util.List;
//import java.util.concurrent.TimeUnit;
//
///**
// * Milvus 向量数据库配置类
// *
// * @author Enterprise RAG Team
// */
//@Configuration
//public class MilvusConfig {
//
//    private final RagProperties ragProperties;
//
//    public MilvusConfig(RagProperties ragProperties) {
//        this.ragProperties = ragProperties;
//    }
//
//    /**
//     * 创建 Milvus 客户端
//     */
//    @Bean
//    public MilvusServiceClient milvusServiceClient() {
//        ConnectParam connectParam = ConnectParam.newBuilder()
//                .withHost(ragProperties.getMilvus().getHost())
//                .withPort(ragProperties.getMilvus().getPort())
//                .withConnectTimeout(10000L, TimeUnit.MILLISECONDS)
//                .build();
//
//        MilvusServiceClient milvusClient = new MilvusServiceClient(connectParam);
//
//        // 检查并创建 Collection
//        createCollectionIfNotExists(milvusClient);
//
//        return milvusClient;
//    }
//
//    /**
//     * 创建向量库集合（如果不存在）
//     */
//    private void createCollectionIfNotExists(MilvusServiceClient milvusClient) {
//        String collectionName = ragProperties.getMilvus().getCollectionName();
//
//        // 检查集合是否存在
//        // 这里简化处理，实际应先检查再创建
//
//        // 定义字段
//        FieldType fieldType1 = FieldType.newBuilder()
//                .withName("id")
//                .withDataType(DataType.Int64)
//                .withPrimaryKey(true)
//                .withAutoID(false)
//                .build();
//
//        FieldType fieldType2 = FieldType.newBuilder()
//                .withName("vector")
//                .withDataType(DataType.FloatVector)
//                .withDimension(ragProperties.getMilvus().getDimension())
//                .build();
//
//        FieldType fieldType3 = FieldType.newBuilder()
//                .withName("metadata")
//                .withDataType(DataType.VarChar)
//                .withMaxLength(65535)
//                .build();
//
//        // 创建集合
//        CreateCollectionParam createCollectionReq = CreateCollectionParam.newBuilder()
//                .withCollectionName(collectionName)
//                .withFieldTypes(List.of(fieldType1, fieldType2, fieldType3))
//                .withConsistencyLevel(ConsistencyLevelEnum.BOUNDED)
//                .build();
//
//        try {
//            milvusClient.createCollection(createCollectionReq);
//            System.out.println("✅ Milvus Collection 创建成功: " + collectionName);
//        } catch (Exception e) {
//            // 集合已存在则忽略
//            System.out.println("⚠️ Milvus Collection 已存在: " + collectionName);
//        }
//    }
//
//    /**
//     * 向量存储 Bean（Spring AI 兼容）
//     * 注意：Spring AI 0.8.x 提供了 Milvus VectorStore 实现
//     */
//    @Bean
//    public VectorStore vectorStore(MilvusServiceClient milvusServiceClient) {
//        // 实际项目中应使用 Spring AI 的 MilvusVectorStore
//        // 这里仅为示例，真实实现需要引入 spring-ai-milvus-store
//        return null;
//    }
//}
