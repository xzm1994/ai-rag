package com.enterprise.rag.service.impl;

import com.enterprise.rag.exception.FileParseException;
import com.enterprise.rag.repository.DocumentMapper;
import com.enterprise.rag.service.api.FileParseService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.tika.Tika;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Collections;
import java.util.List;

/**
 * 文件解析服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class FileParseServiceImpl implements FileParseService {

    private final DocumentMapper documentMapper;

    @Override
    public List<String> parseDocument(Long documentId) {
        // TODO: 实现完整的文档解析逻辑
        // 这里需要补充完整实现
        return Collections.singletonList("");
    }
}
