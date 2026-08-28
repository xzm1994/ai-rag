package com.enterprise.rag.service.api;

import java.util.List;

/**
 * 文件解析服务接口
 */
public interface FileParseService {
    List<String> parseDocument(Long documentId);
}
