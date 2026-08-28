package com.enterprise.rag.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.ai.openai.OpenAiEmbeddingModel;
import org.springframework.ai.openai.api.OpenAiApi;
import org.springframework.ai.chat.model.ChatModel;

/**
 * OpenAI 配置类
 *
 * @author Enterprise RAG Team
 */
@Configuration
public class OpenAiConfig {

    private final org.springframework.ai.openai.OpenAiChatModel openAiChatModel;
    private final org.springframework.ai.openai.OpenAiEmbeddingModel openAiEmbeddingModel;

    public OpenAiConfig() {
        // Spring AI 会自动配置这些 Bean
        this.openAiChatModel = null;
        this.openAiEmbeddingModel = null;
    }

    @Bean
    public ChatModel chatModel() {
        return openAiChatModel;
    }

    @Bean
    public OpenAiEmbeddingModel embeddingClient() {
        return openAiEmbeddingModel;
    }
}
