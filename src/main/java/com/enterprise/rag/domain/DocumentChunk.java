package com.enterprise.rag.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档分片实体
 */
@Data
@TableName("document_chunk")
public class DocumentChunk {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private Long documentId;
    private Integer chunkIndex;
    private String content;
    private Integer contentLength;
    private Integer tokenCount;
    private Integer embeddingStatus;
    private String vectorId;
    private String errorMessage;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
