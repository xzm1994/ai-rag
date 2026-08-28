package com.enterprise.rag.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 聊天请求
 */
@Data
@Schema(description = "聊天请求")
public class ChatRequest {
    private String sessionId;
    private String question;
    private Long userId;
}
