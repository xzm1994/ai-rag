package com.enterprise.rag.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 对话历史VO
 */
@Data
@Schema(description = "对话历史VO")
public class ChatHistoryVO {
    private Long id;
    private String sessionId;
    private String question;
    private String answer;
    private List<Long> documentIds;
    private Integer tokensUsed;
    private LocalDateTime createdAt;
}
