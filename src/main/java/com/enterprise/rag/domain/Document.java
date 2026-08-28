package com.enterprise.rag.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档主表实体
 */
@Data
@TableName("document")
public class Document {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private String title;
    private String originalName;
    private String filePath;
    private Long fileSize;
    private String fileType;
    private Long uploadUserId;
    private Long categoryId;
    private Integer status;
    private String errorMessage;
    private Integer chunkCount;
    private Integer wordCount;
    private Integer viewPermission;
    private Long deptId;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
