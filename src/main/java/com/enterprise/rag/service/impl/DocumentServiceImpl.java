package com.enterprise.rag.service.impl;

import cn.hutool.core.io.FileUtil;
import cn.hutool.core.util.IdUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.enterprise.rag.constant.DocumentStatus;
import com.enterprise.rag.domain.Document;
import com.enterprise.rag.domain.DocumentChunk;
import com.enterprise.rag.dto.request.DocumentUploadRequest;
import com.enterprise.rag.dto.response.DocumentVO;
import com.enterprise.rag.exception.BusinessException;
import com.enterprise.rag.exception.FileParseException;
import com.enterprise.rag.repository.DocumentChunkMapper;
import com.enterprise.rag.repository.DocumentMapper;
import com.enterprise.rag.service.api.*;
import com.enterprise.rag.util.SecurityUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.tika.Tika;
import org.springframework.beans.BeanUtils;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 文档服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DocumentServiceImpl implements DocumentService {

    private final DocumentMapper documentMapper;
    private final DocumentChunkMapper chunkMapper;
    private final FileParseService fileParseService;
    private final VectorService vectorService;
    private final PermissionService permissionService;

    private final Tika tika = new Tika();
    private static final String UPLOAD_ROOT = "D:/rag/uploads";

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long handleDocumentUpload(DocumentUploadRequest request) {
        MultipartFile file = request.getFile();
        if (file.isEmpty()) {
            throw new BusinessException("文件不能为空");
        }

        String originalFilename = file.getOriginalFilename();
        String contentType;
        try {
            contentType = file.getContentType();
            if (contentType == null) {
                contentType = tika.detect(file.getInputStream());
            }
        } catch (IOException e) {
            throw new BusinessException("文件读取失败");
        }

        String fileType = getFileExtension(originalFilename).toUpperCase();
        if (!isValidFileType(fileType)) {
            throw new BusinessException("不支持的文件类型：" + fileType);
        }

        String fileName = IdUtil.fastSimpleUUID() + "." + getFileExtension(originalFilename);
        String relativePath = "docs/" + fileName;
        String absolutePath = UPLOAD_ROOT + "/" + relativePath;

        try {
            File dest = new File(absolutePath);
            FileUtil.mkParentDirs(dest);
            file.transferTo(dest);
        } catch (IOException e) {
            log.error("文件保存失败: {}", absolutePath, e);
            throw new BusinessException("文件保存失败");
        }

        Document document = new Document();
        document.setTitle(request.getTitle());
        document.setOriginalName(originalFilename);
        document.setFilePath(absolutePath);
        document.setFileSize(file.getSize());
        document.setFileType(fileType);
        document.setUploadUserId(SecurityUtil.getCurrentUserId());
        document.setCategoryId(request.getCategoryId());
        document.setStatus(DocumentStatus.PENDING.getCode());
        document.setViewPermission(request.getViewPermission());
        document.setDeptId(request.getDeptId());

        documentMapper.insert(document);

        if (request.getViewPermission() != 0) {
            permissionService.createPermission(document.getId(), document.getUploadUserId(), 3);
        }

        processDocumentAsync(document.getId());
        return document.getId();
    }

    @Async("asyncTaskExecutor")
    public void processDocumentAsync(Long documentId) {
        try {
            updateDocumentStatus(documentId, DocumentStatus.PROCESSING.getCode());
            List<String> contentList = fileParseService.parseDocument(documentId);

            if (contentList.isEmpty()) {
                throw new FileParseException("文档解析结果为空");
            }

            List<String> cleanedContentList = contentList.stream()
                    .map(this::cleanText)
                    .collect(Collectors.toList());
            List<String> chunkTexts = chunkTexts(cleanedContentList);

            List<DocumentChunk> chunkEntities = new ArrayList<>();
            for (int i = 0; i < chunkTexts.size(); i++) {
                String content = chunkTexts.get(i);
                DocumentChunk chunk = new DocumentChunk();
                chunk.setDocumentId(documentId);
                chunk.setChunkIndex(i);
                chunk.setContent(content);
                chunk.setContentLength(content.length());
                chunk.setTokenCount(estimateTokenCount(content));
                chunk.setEmbeddingStatus(0);
                chunkEntities.add(chunk);
            }
            chunkMapper.insert(chunkEntities);

            Document document = documentMapper.selectById(documentId);
            document.setChunkCount(chunkEntities.size());
            document.setWordCount(chunkEntities.stream().mapToInt(DocumentChunk::getContentLength).sum());
            documentMapper.updateById(document);

            updateDocumentStatus(documentId, 1);
            vectorService.embedAndStoreChunks(documentId, chunkEntities);
            updateDocumentStatus(documentId, DocumentStatus.READY.getCode());

            log.info("文档处理完成: documentId={}", documentId);

        } catch (Exception e) {
            log.error("文档处理失败: documentId={}", documentId, e);
            updateDocumentStatus(documentId, DocumentStatus.FAILED.getCode());
            Document doc = documentMapper.selectById(documentId);
            doc.setErrorMessage(e.getMessage());
            documentMapper.updateById(doc);
        }
    }

    @Override
    public Page<DocumentVO> getDocumentList(Long categoryId, Integer status, int pageSize, int pageNum) {
        LambdaQueryWrapper<Document> wrapper = new LambdaQueryWrapper<>();
        Long currentUserId = SecurityUtil.getCurrentUserId();
        wrapper.and(w -> w.eq(Document::getViewPermission, 0)
                .or().eq(Document::getUploadUserId, currentUserId))
                .or().eq(Document::getDeptId, getCurrentUserDeptId());

        if (categoryId != null) {
            wrapper.eq(Document::getCategoryId, categoryId);
        }
        if (status != null) {
            wrapper.eq(Document::getStatus, status);
        }
        wrapper.orderByDesc(Document::getCreatedAt);

        Page<Document> page = new Page<>(pageNum, pageSize);
        Page<Document> documentPage = documentMapper.selectPage(page, wrapper);

        Page<DocumentVO> result = new Page<>(documentPage.getCurrent(), documentPage.getSize(), documentPage.getTotal());
        List<DocumentVO> list = documentPage.getRecords().stream().map(d -> {
            DocumentVO vo = new DocumentVO();
            BeanUtils.copyProperties(d, vo);
            return vo;
        }).toList();
        result.setRecords(list);

        return result;
    }

    @Override
    public DocumentVO getDocumentById(Long id) {
        Document document = documentMapper.selectById(id);
        if (document == null) {
            throw new BusinessException("文档不存在");
        }
        checkDocumentPermission(id);
        DocumentVO vo = new DocumentVO();
        BeanUtils.copyProperties(document, vo);
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteDocument(Long id) {
        Document document = documentMapper.selectById(id);
        if (document == null) {
            return;
        }
        checkDocumentPermission(id);

        List<DocumentChunk> chunks = chunkMapper.selectList(
                new LambdaQueryWrapper<DocumentChunk>().eq(DocumentChunk::getDocumentId, id));
        if (!chunks.isEmpty()) {
            List<String> vectorIds = chunks.stream()
                    .map(DocumentChunk::getVectorId)
                    .filter(Objects::nonNull)
                    .collect(Collectors.toList());
            if (!vectorIds.isEmpty()) {
                vectorService.deleteVectors(vectorIds);
            }
        }

        chunkMapper.delete(new LambdaQueryWrapper<DocumentChunk>().eq(DocumentChunk::getDocumentId, id));
        permissionService.deleteByDocumentId(id);
        documentMapper.deleteBatchIds(Collections.singletonList(id));
        FileUtil.del(document.getFilePath());
    }

    @Override
    public void updateDocumentStatus(Long documentId, Integer status) {
        Document document = new Document();
        document.setId(documentId);
        document.setStatus(status);
        documentMapper.updateById(document);
    }

    private void checkDocumentPermission(Long documentId) {
        Document document = documentMapper.selectById(documentId);
        if (document == null) {
            throw new BusinessException("文档不存在");
        }
        Long currentUserId = SecurityUtil.getCurrentUserId();
        if (document.getViewPermission() == 0) {
            return;
        }
        if (!Objects.equals(document.getUploadUserId(), currentUserId) &&
                !permissionService.hasPermission(currentUserId, documentId, 1)) {
            throw new BusinessException("无权访问该文档");
        }
    }

    private String getFileExtension(String filename) {
        if (filename == null) return "";
        int lastDot = filename.lastIndexOf('.');
        return lastDot > 0 ? filename.substring(lastDot + 1) : "";
    }

    private boolean isValidFileType(String type) {
        return Arrays.asList("PDF", "DOC", "DOCX", "MD", "TXT").contains(type.toUpperCase());
    }

    private String cleanText(String text) {
        return text.replaceAll("\\s+", " ").trim();
    }

    private List<String> chunkTexts(List<String> texts) {
        List<String> chunks = new ArrayList<>();
        for (String text : texts) {
            int maxLength = 300;
            int overlap = 30;
            if (text.length() <= maxLength) {
                chunks.add(text);
                continue;
            }
            int start = 0;
            while (start < text.length()) {
                int end = Math.min(start + maxLength, text.length());
                String chunk = text.substring(start, end);
                chunks.add(chunk);
                start = end - overlap;
                if (start < 0) start = 0;
            }
        }
        return chunks;
    }

    private int estimateTokenCount(String text) {
        return (text.length() + 2) / 3;
    }

    private Long getCurrentUserDeptId() {
        return 1L;
    }
}
