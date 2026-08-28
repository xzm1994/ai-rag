package com.enterprise.rag.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 文档VO
 */
@Data
@Schema(description = "文档VO")
public class DocumentVO {
    private Long id;
    private String title;
    private String originalName;
    private String fileType;
    private Long fileSize;
    private String uploadUserName;
    private String categoryName;
    private Integer status;
    private String errorMessage;
    private Integer chunkCount;
    private Integer wordCount;
    private Integer viewPermission;
    private Long deptId;
    private LocalDateTime createdAt;
}
