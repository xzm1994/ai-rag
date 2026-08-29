package com.enterprise.rag.controller;

import com.enterprise.rag.dto.request.DocumentUploadRequest;
import com.enterprise.rag.service.api.DocumentService;
import com.enterprise.rag.util.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * 文件上传控制器
 */
@RestController
@RequestMapping("/api/upload")
@RequiredArgsConstructor
@Tag(name = "文件上传", description = "文档上传接口")
public class FileUploadController {

    private final DocumentService documentService;

    @PostMapping("/document")
    @Operation(summary = "上传文档")
    public Result<Long> uploadDocument(
            @NotNull(message = "文件不能为空") @RequestParam("file") MultipartFile file,
            @NotBlank(message = "标题不能为空") @RequestParam("title") String title,
            @RequestParam(value = "categoryId", required = false) Long categoryId,
            @NotNull(message = "查看权限不能为空") @RequestParam("viewPermission") Integer viewPermission,
            @RequestParam(value = "deptId", required = false) Long deptId
    ) {
        // 手动组装DTO，传给service层，service层依然使用DTO对象
        DocumentUploadRequest request = new DocumentUploadRequest();
        request.setTitle(title);
        request.setCategoryId(categoryId);
        request.setViewPermission(viewPermission);
        request.setDeptId(deptId);
        request.setFile(file);
        Long documentId = documentService.handleDocumentUpload(request);
        return Result.success("文档上传成功", documentId);
    }
}
