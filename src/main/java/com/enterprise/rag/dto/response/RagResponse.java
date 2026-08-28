package com.enterprise.rag.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.util.List;

/**
 * RAG回答响应
 */
@Data
@Schema(description = "RAG回答响应")
public class RagResponse {
    private String answer;
    private List<ChunkVO> sources;
    private Integer tokensUsed;
}
