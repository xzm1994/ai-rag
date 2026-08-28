package com.enterprise.rag.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.List;

/**
 * 文档上传请求
 */
@Data
@Schema(description = "文档上传请求")
public class DocumentUploadRequest {
    @NotNull(message = "文件不能为空")
    private MultipartFile file;

    @NotBlank(message = "标题不能为空")
    private String title;

    private Long categoryId;

    @NotNull(message = "查看权限不能为空")
    private Integer viewPermission;

    private Long deptId;
}
