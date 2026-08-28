package com.enterprise.rag.controller;

import com.enterprise.rag.dto.request.DocumentUploadRequest;
import com.enterprise.rag.dto.response.DocumentVO;
import com.enterprise.rag.service.api.DocumentService;
import com.enterprise.rag.util.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 文档管理控制器
 */
@RestController
@RequestMapping("/api/documents")
@RequiredArgsConstructor
@Tag(name = "文档管理", description = "文档上传、查询、管理等接口")
public class DocumentController {

    private final DocumentService documentService;

    @GetMapping("/list")
    @Operation(summary = "文档列表")
    public Result<List<DocumentVO>> list(@RequestParam(required = false) Long categoryId,
                                          @RequestParam(required = false) Integer status,
                                          @RequestParam(defaultValue = "10") int pageSize,
                                          @RequestParam(defaultValue = "1") int pageNum) {
        return Result.success(documentService.getDocumentList(categoryId, status, pageSize, pageNum));
    }

    @GetMapping("/{id}")
    @Operation(summary = "文档详情")
    public Result<DocumentVO> detail(@PathVariable Long id) {
        return Result.success(documentService.getDocumentById(id));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除文档")
    public Result<String> delete(@PathVariable Long id) {
        documentService.deleteDocument(id);
        return Result.success("删除成功");
    }

    @PutMapping("/{id}/status")
    @Operation(summary = "更新文档状态")
    public Result<String> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        documentService.updateDocumentStatus(id, status);
        return Result.success("状态更新成功");
    }
}
