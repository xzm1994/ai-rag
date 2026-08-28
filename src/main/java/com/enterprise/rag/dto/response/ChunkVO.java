package com.enterprise.rag.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 分片VO
 */
@Data
@Schema(description = "分片VO")
public class ChunkVO {
    private Long id;
    private Long documentId;
    private String documentTitle;
    private String content;
    private Double similarity;
    private Integer chunkIndex;
}
