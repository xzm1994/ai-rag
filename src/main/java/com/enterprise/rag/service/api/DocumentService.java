package com.enterprise.rag.service.api;

import com.enterprise.rag.dto.request.DocumentUploadRequest;
import com.enterprise.rag.dto.response.DocumentVO;
import com.enterprise.rag.domain.Document;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.util.List;

/**
 * 文档服务接口
 */
public interface DocumentService {
    Long handleDocumentUpload(DocumentUploadRequest request);
    Page<DocumentVO> getDocumentList(Long categoryId, Integer status, int pageSize, int pageNum);
    DocumentVO getDocumentById(Long id);
    void deleteDocument(Long id);
    void updateDocumentStatus(Long documentId, Integer status);
}
