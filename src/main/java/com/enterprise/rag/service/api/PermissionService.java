package com.enterprise.rag.service.api;

/**
 * 权限服务接口
 */
public interface PermissionService {
    void createPermission(Long documentId, Long userId, Integer level);
    void deleteByDocumentId(Long documentId);
    boolean hasPermission(Long userId, Long documentId, Integer minLevel);
}
