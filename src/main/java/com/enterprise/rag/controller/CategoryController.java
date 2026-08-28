package com.enterprise.rag.controller;

import com.enterprise.rag.dto.response.CategoryVO;
import com.enterprise.rag.service.api.KnowledgeBaseService;
import com.enterprise.rag.util.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 知识库分类控制器
 */
@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
@Tag(name = "知识库分类", description = "分类管理接口")
public class CategoryController {

    private final KnowledgeBaseService knowledgeBaseService;

    @GetMapping("/list")
    @Operation(summary = "分类列表")
    public Result<List<CategoryVO>> list() {
        return Result.success(knowledgeBaseService.listCategories());
    }

    @PostMapping
    @Operation(summary = "新增分类")
    public Result<Long> create(@RequestBody CategoryVO category) {
        return Result.success("分类创建成功", knowledgeBaseService.createCategory(category));
    }

    @PutMapping
    @Operation(summary = "更新分类")
    public Result<Void> update(@RequestBody CategoryVO category) {
        knowledgeBaseService.updateCategory(category);
        return Result.success("分类更新成功");
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除分类")
    public Result<Void> delete(@PathVariable Long id) {
        knowledgeBaseService.deleteCategory(id);
        return Result.success("分类删除成功");
    }
}
