package com.enterprise.rag.controller;

import com.enterprise.rag.dto.request.DocumentUploadRequest;
import com.enterprise.rag.util.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

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
    public Result<Long> uploadDocument(@Validated DocumentUploadRequest request) {
        Long documentId = documentService.handleDocumentUpload(request);
        return Result.success("文档上传成功", documentId);
    }
}
