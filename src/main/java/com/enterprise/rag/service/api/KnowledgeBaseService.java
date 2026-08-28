package com.enterprise.rag.service.api;

import com.enterprise.rag.dto.response.CategoryVO;

import java.util.List;

/**
 * 知识库服务接口
 */
public interface KnowledgeBaseService {
    List<CategoryVO> listCategories();
    Long createCategory(CategoryVO category);
    void updateCategory(CategoryVO category);
    void deleteCategory(Long id);
}
