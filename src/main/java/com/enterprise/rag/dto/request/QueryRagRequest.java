package com.enterprise.rag.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

/**
 * RAG问答请求
 */
@Data
@Schema(description = "RAG问答请求")
public class QueryRagRequest {
    @NotBlank(message = "问题不能为空")
    private String question;

    private Long categoryId;

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    private Integer topK = 3;

    private Double similarityThreshold = 0.5;
}
