package com.enterprise.rag.config;

import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.ai.openai.OpenAiEmbeddingModel;
import org.springframework.ai.openai.api.OpenAiApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * DeepSeek API 配置类
 *
 * @author Enterprise RAG Team
 */
@Configuration
public class DeepSeekConfig {

    /**
     * Chat Model Bean - 用于问答
     */
    @Bean
    public ChatModel chatModel() {
        OpenAiApi openAiApi = new OpenAiApi(
                "https://api.deepseek.com/v1",  // DeepSeek API 地址
                "sk-0479be630986491db7a70c8f0b28519c"  // 替换为您的 DeepSeek API Key
        );
        return new OpenAiChatModel(openAiApi);
    }

    /**
     * Embedding Model Bean - 用于向量化
     */
    @Bean
    public OpenAiEmbeddingModel embeddingModel() {
        OpenAiApi openAiApi = new OpenAiApi(
                "https://api.deepseek.com/v1",
                "sk-0479be630986491db7a70c8f0b28519c"  // 替换为您的 DeepSeek API Key
        );
        return new OpenAiEmbeddingModel(openAiApi);
    }
}