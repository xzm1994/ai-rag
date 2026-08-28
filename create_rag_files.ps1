# PowerShell 脚本 - 创建企业AI知识库RAG系统的所有Java文件
# 运行方式: powershell -ExecutionPolicy Bypass -File create_rag_files.ps1

$baseDir = "Z:\myworkspace\ai-rag\src\main\java\com\enterprise\rag"

# 创建目录结构
$directories = @(
    "config",
    "controller",
    "service\api",
    "service\impl",
    "domain",
    "repository",
    "dto\request",
    "dto\response",
    "exception",
    "constant",
    "util",
    "properties"
)

foreach ($dir in $directories) {
    $path = Join-Path $baseDir $dir
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "Created directory: $path"
    }
}

# 创建配置类文件
$configFiles = @{}

# 1. OpenAiConfig.java
$configFiles["config\OpenAiConfig.java"] = @'
package com.enterprise.rag.config;

import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.embedding.EmbeddingClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * OpenAI 配置类
 *
 * @author Enterprise RAG Team
 */
@Configuration
public class OpenAiConfig {

    @Bean
    public ChatModel chatModel(org.springframework.ai.openai.OpenAiChatModel chatModel) {
        return chatModel;
    }

    @Bean
    public EmbeddingClient embeddingClient(org.springframework.ai.openai.OpenAiEmbeddingModel embeddingModel) {
        return embeddingModel;
    }
}
'@

# 2. MyBatisPlusConfig.java
$configFiles["config\MyBatisPlusConfig.java"] = @'
package com.enterprise.rag.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis Plus 配置类
 *
 * @author Enterprise RAG Team
 */
@Configuration
public class MyBatisPlusConfig {

    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        return interceptor;
    }
}
'@

# 3. AsyncConfig.java
$configFiles["config\AsyncConfig.java"] = @'
package com.enterprise.rag.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.AsyncConfigurer;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

/**
 * 异步任务配置类
 *
 * @author Enterprise RAG Team
 */
@Configuration
@EnableAsync
public class AsyncConfig implements AsyncConfigurer {

    @Override
    @Bean(name = "asyncTaskExecutor")
    public Executor getAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-task-");
        executor.initialize();
        return executor;
    }
}
'@

# 4. MilvusConfig.java - 简化版本
$configFiles["config\MilvusConfig.java"] = @'
package com.enterprise.rag.config;

import io.milvus.client.MilvusServiceClient;
import io.milvus.param.ConnectParam;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Milvus 向量数据库配置类
 *
 * @author Enterprise RAG Team
 */
@Slf4j
@Configuration
@ConditionalOnProperty(prefix = "enterprise.rag.milvus", name = "host")
public class MilvusConfig {

    private final RagProperties ragProperties;

    public MilvusConfig(RagProperties ragProperties) {
        this.ragProperties = ragProperties;
    }

    @Bean
    public MilvusServiceClient milvusServiceClient() {
        ConnectParam connectParam = ConnectParam.newBuilder()
                .withHost(ragProperties.getMilvus().getHost())
                .withPort(ragProperties.getMilvus().getPort())
                .withConnectTimeoutMs(10000L)
                .withConnectionUsageTimeoutMs(30000L)
                .build();

        MilvusServiceClient milvusClient = new MilvusServiceClient(connectParam);
        
        log.info("Milvus 客户端初始化成功: {}://{}", 
                ragProperties.getMilvus().getHost(), 
                ragProperties.getMilvus().getPort());
        
        return milvusClient;
    }
}
'@

# 5. Document.java
$configFiles["domain\Document.java"] = @'
package com.enterprise.rag.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档主表实体
 */
@Data
@TableName("document")
public class Document {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private String title;
    private String originalName;
    private String filePath;
    private Long fileSize;
    private String fileType;
    private Long uploadUserId;
    private Long categoryId;
    private Integer status;
    private String errorMessage;
    private Integer chunkCount;
    private Integer wordCount;
    private Integer viewPermission;
    private Long deptId;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
'@

# 6. DocumentChunk.java
$configFiles["domain\DocumentChunk.java"] = @'
package com.enterprise.rag.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档分片实体
 */
@Data
@TableName("document_chunk")
public class DocumentChunk {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private Long documentId;
    private Integer chunkIndex;
    private String content;
    private Integer contentLength;
    private Integer tokenCount;
    private Integer embeddingStatus;
    private String vectorId;
    private String errorMessage;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
'@

# 7. User.java
$configFiles["domain\User.java"] = @'
package com.enterprise.rag.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户实体
 */
@Data
@TableName("user")
public class User {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private String username;
    private String nickname;
    private Long deptId;
    private String role;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
'@

# 8. Permission.java
$configFiles["domain\Permission.java"] = @'
package com.enterprise.rag.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 权限实体
 */
@Data
@TableName("permission")
public class Permission {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long documentId;
    private Integer permissionLevel;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
'@

# 9. ChatHistory.java
$configFiles["domain\ChatHistory.java"] = @'
package com.enterprise.rag.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 对话历史实体
 */
@Data
@TableName("chat_history")
public class ChatHistory {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private String sessionId;
    private Long userId;
    private String question;
    private String answer;
    private String documentIds;
    private Integer tokensUsed;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
'@

# 10. DocumentMapper.java
$configFiles["repository\DocumentMapper.java"] = @'
package com.enterprise.rag.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.enterprise.rag.domain.Document;
import org.apache.ibatis.annotations.Mapper;

/**
 * 文档Mapper
 */
@Mapper
public interface DocumentMapper extends BaseMapper<Document> {
}
'@

# 11. DocumentChunkMapper.java
$configFiles["repository\DocumentChunkMapper.java"] = @'
package com.enterprise.rag.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.enterprise.rag.domain.DocumentChunk;
import org.apache.ibatis.annotations.Mapper;

/**
 * 文档分片Mapper
 */
@Mapper
public interface DocumentChunkMapper extends BaseMapper<DocumentChunk> {
}
'@

# 12. PermissionMapper.java
$configFiles["repository\PermissionMapper.java"] = @'
package com.enterprise.rag.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.enterprise.rag.domain.Permission;
import org.apache.ibatis.annotations.Mapper;

/**
 * 权限Mapper
 */
@Mapper
public interface PermissionMapper extends BaseMapper<Permission> {
}
'@

# 13. ChatHistoryMapper.java
$configFiles["repository\ChatHistoryMapper.java"] = @'
package com.enterprise.rag.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.enterprise.rag.domain.ChatHistory;
import org.apache.ibatis.annotations.Mapper;

/**
 * 对话历史Mapper
 */
@Mapper
public interface ChatHistoryMapper extends BaseMapper<ChatHistory> {
}
'@

# 14. DocumentService.java
$configFiles["service\api\DocumentService.java"] = @'
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
'@

# 15. ChatService.java
$configFiles["service\api\ChatService.java"] = @'
package com.enterprise.rag.service.api;

import com.enterprise.rag.dto.request.QueryRagRequest;
import com.enterprise.rag.dto.response.RagResponse;
import com.enterprise.rag.dto.response.ChatHistoryVO;

import java.util.List;

/**
 * 聊天/问答服务接口
 */
public interface ChatService {
    RagResponse answerWithRag(QueryRagRequest request);
    List<ChatHistoryVO> getChatHistory(String sessionId, Long userId, int pageSize, int pageNum);
}
'@

# 16. FileParseService.java
$configFiles["service\api\FileParseService.java"] = @'
package com.enterprise.rag.service.api;

import java.util.List;

/**
 * 文件解析服务接口
 */
public interface FileParseService {
    List<String> parseDocument(Long documentId);
}
'@

# 17. VectorService.java
$configFiles["service\api\VectorService.java"] = @'
package com.enterprise.rag.service.api;

import com.enterprise.rag.domain.DocumentChunk;

import java.util.List;

/**
 * 向量服务接口
 */
public interface VectorService {
    void embedAndStoreChunks(Long documentId, List<DocumentChunk> chunks);
    void deleteVectors(List<String> vectorIds);
    List<DocumentChunk> searchSimilar(String query, int topK, Double threshold);
}
'@

# 18. PermissionService.java
$configFiles["service\api\PermissionService.java"] = @'
package com.enterprise.rag.service.api;

/**
 * 权限服务接口
 */
public interface PermissionService {
    void createPermission(Long documentId, Long userId, Integer level);
    void deleteByDocumentId(Long documentId);
    boolean hasPermission(Long userId, Long documentId, Integer minLevel);
}
'@

# 19. KnowledgeBaseService.java
$configFiles["service\api\KnowledgeBaseService.java"] = @'
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
'@

# 20. DocumentServiceImpl.java
$configFiles["service\impl\DocumentServiceImpl.java"] = @'
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
            chunkMapper.insertBatch(chunkEntities);

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
                .or(w.eq(Document::getUploadUserId, currentUserId))
                .or(w.eq(Document::getDeptId, getCurrentUserDeptId())));

        if (categoryId != null) {
            wrapper.eq(Document::getCategoryId, categoryId);
        }
        if (status != null) {
            wrapper.eq(Document::getStatus, status);
        }
        wrapper.orderByDesc(Document::getCreatedAt);

        Page<Document> page = new Page<>(pageNum, pageSize);
        Page<Document> documentPage = documentMapper.selectPage(page, wrapper);

        return documentPage.convert(d -> {
            DocumentVO vo = new DocumentVO();
            BeanUtils.copyProperties(d, vo);
            return vo;
        });
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
'@

# 21. ChatServiceImpl.java
$configFiles["service\impl\ChatServiceImpl.java"] = @'
package com.enterprise.rag.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.enterprise.rag.domain.DocumentChunk;
import com.enterprise.rag.dto.request.QueryRagRequest;
import com.enterprise.rag.dto.response.RagResponse;
import com.enterprise.rag.dto.response.ChunkVO;
import com.enterprise.rag.exception.OpenAiException;
import com.enterprise.rag.repository.ChatHistoryMapper;
import com.enterprise.rag.service.api.ChatService;
import com.enterprise.rag.service.api.VectorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 聊天服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final ChatModel chatModel;
    private final VectorService vectorService;
    private final ChatHistoryMapper historyMapper;

    @Override
    public RagResponse answerWithRag(QueryRagRequest request) {
        try {
            List<DocumentChunk> similarChunks = vectorService.searchSimilar(
                    request.getQuestion(),
                    request.getTopK(),
                    request.getSimilarityThreshold()
            );

            if (similarChunks.isEmpty()) {
                log.warn("未检索到相关知识: question={}", request.getQuestion());
            }

            String context = buildContext(similarChunks);
            String promptTemplate = buildPrompt(context, request.getQuestion());

            List<Message> messages = Collections.singletonList(new UserMessage(promptTemplate));
            Prompt prompt = new Prompt(messages);
            ChatResponse response = chatModel.call(prompt);

            String answer = response.getResult().getOutput().getContent();

            RagResponse ragResponse = new RagResponse();
            ragResponse.setAnswer(answer);
            ragResponse.setSources(convertToChunkVOs(similarChunks));

            return ragResponse;

        } catch (Exception e) {
            log.error("RAG问答失败", e);
            throw new OpenAiException("大模型调用失败：" + e.getMessage());
        }
    }

    @Override
    public List<com.enterprise.rag.dto.response.ChatHistoryVO> getChatHistory(String sessionId, Long userId, int pageSize, int pageNum) {
        LambdaQueryWrapper<com.enterprise.rag.domain.ChatHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(com.enterprise.rag.domain.ChatHistory::getSessionId, sessionId)
                .eq(com.enterprise.rag.domain.ChatHistory::getUserId, userId)
                .orderByDesc(com.enterprise.rag.domain.ChatHistory::getCreatedAt);

        return new ArrayList<>();
    }

    private String buildContext(List<DocumentChunk> chunks) {
        if (chunks.isEmpty()) {
            return "无相关知识库内容";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("【知识库内容】\n");
        for (DocumentChunk chunk : chunks) {
            sb.append("分片 ").append(chunk.getChunkIndex()).append(":\n");
            sb.append(chunk.getContent()).append("\n\n");
        }
        return sb.toString();
    }

    private String buildPrompt(String context, String question) {
        return String.format(
                "你是一个企业知识库助手，请基于以下知识库内容回答问题。\n" +
                "如果知识库中没有相关信息，请如实回答"知识库中无相关信息"。\n" +
                "【知识库内容】\n%s\n\n" +
                "【问题】\n%s\n\n" +
                "【回答】",
                context, question
        );
    }

    private List<ChunkVO> convertToChunkVOs(List<DocumentChunk> chunks) {
        return chunks.stream()
                .map(chunk -> {
                    ChunkVO vo = new ChunkVO();
                    vo.setId(chunk.getId());
                    vo.setDocumentId(chunk.getDocumentId());
                    vo.setContent(chunk.getContent());
                    vo.setChunkIndex(chunk.getChunkIndex());
                    return vo;
                })
                .collect(Collectors.toList());
    }
}
'@

# 22. FileParseServiceImpl.java
$configFiles["service\impl\FileParseServiceImpl.java"] = @'
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
    private final Tika tika = new Tika();

    @Override
    public List<String> parseDocument(Long documentId) {
        try {
            Document document = documentMapper.selectById(documentId);
            if (document == null) {
                throw new FileParseException("文档不存在");
            }

            File file = new File(document.getFilePath());
            if (!file.exists()) {
                throw new FileParseException("文件不存在");
            }

            String content = tika.parseToString(new FileInputStream(file));
            
            if (content == null || content.trim().isEmpty()) {
                throw new FileParseException("文档解析结果为空");
            }

            // 简化处理，实际项目中应按需分页
            return Collections.singletonList(content);

        } catch (Exception e) {
            log.error("文件解析失败: documentId={}", documentId, e);
            throw new FileParseException("文件解析失败: " + e.getMessage(), e);
        }
    }
}
'@

# 23. VectorServiceImpl.java
$configFiles["service\impl\VectorServiceImpl.java"] = @'
package com.enterprise.rag.service.impl;

import com.enterprise.rag.domain.DocumentChunk;
import com.enterprise.rag.exception.VectorDatabaseException;
import com.enterprise.rag.repository.DocumentChunkMapper;
import com.enterprise.rag.service.api.VectorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.EmbeddingClient;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 向量服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class VectorServiceImpl implements VectorService {

    private final DocumentChunkMapper chunkMapper;
    private final VectorStore vectorStore;
    private final EmbeddingClient embeddingClient;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void embedAndStoreChunks(Long documentId, List<DocumentChunk> chunks) {
        try {
            for (DocumentChunk chunk : chunks) {
                try {
                    List<Float> embedding = embeddingClient.embed(chunk.getContent());

                    Document doc = Document.builder()
                            .withContent(chunk.getContent())
                            .withMetadata("chunkId", String.valueOf(chunk.getId()))
                            .withMetadata("documentId", String.valueOf(documentId))
                            .withMetadata("chunkIndex", String.valueOf(chunk.getChunkIndex()))
                            .build();

                    vectorStore.add(Collections.singletonList(doc));

                    chunk.setEmbeddingStatus(2);
                    chunk.setVectorId(String.valueOf(chunk.getId()));
                    chunkMapper.updateById(chunk);

                } catch (Exception e) {
                    log.error("单个分片向量化失败: chunkId={}", chunk.getId(), e);
                    chunk.setEmbeddingStatus(3);
                    chunk.setErrorMessage(e.getMessage());
                    chunkMapper.updateById(chunk);
                }
            }
        } catch (Exception e) {
            log.error("批量向量化失败: documentId={}", documentId, e);
            throw new VectorDatabaseException("向量入库失败：" + e.getMessage());
        }
    }

    @Override
    public void deleteVectors(List<String> vectorIds) {
        try {
            log.warn("向量删除暂未实现");
        } catch (Exception e) {
            throw new VectorDatabaseException("向量删除失败：" + e.getMessage());
        }
    }

    @Override
    public List<DocumentChunk> searchSimilar(String query, int topK, Double threshold) {
        try {
            SearchRequest searchRequest = SearchRequest.builder()
                    .query(query)
                    .topK(topK)
                    .similarityThreshold(threshold)
                    .build();

            List<Document> results = vectorStore.similaritySearch(searchRequest);

            return results.stream()
                    .map(doc -> {
                        DocumentChunk chunk = new DocumentChunk();
                        chunk.setId(Long.parseLong(doc.getMetadata().get("chunkId")));
                        chunk.setDocumentId(Long.parseLong(doc.getMetadata().get("documentId")));
                        chunk.setChunkIndex(Integer.parseInt(doc.getMetadata().get("chunkIndex")));
                        chunk.setContent(doc.getContent());
                        return chunk;
                    })
                    .collect(Collectors.toList());

        } catch (Exception e) {
            log.error("向量检索失败", e);
            throw new VectorDatabaseException("向量检索失败：" + e.getMessage());
        }
    }
}
'@

# 24. PermissionServiceImpl.java
$configFiles["service\impl\PermissionServiceImpl.java"] = @'
package com.enterprise.rag.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.enterprise.rag.repository.PermissionMapper;
import com.enterprise.rag.service.api.PermissionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 权限服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PermissionServiceImpl implements PermissionService {

    private final PermissionMapper permissionMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createPermission(Long documentId, Long userId, Integer level) {
        Permission permission = new Permission();
        permission.setDocumentId(documentId);
        permission.setUserId(userId);
        permission.setPermissionLevel(level);
        permissionMapper.insert(permission);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteByDocumentId(Long documentId) {
        permissionMapper.delete(new LambdaQueryWrapper<>().eq(Permission::getDocumentId, documentId));
    }

    @Override
    public boolean hasPermission(Long userId, Long documentId, Integer minLevel) {
        return permissionMapper.selectCount(
                new LambdaQueryWrapper<Permission>()
                        .eq(Permission::getUserId, userId)
                        .eq(Permission::getDocumentId, documentId)
                        .ge(Permission::getPermissionLevel, minLevel)) > 0;
    }
}
'@

# 25. KnowledgeBaseServiceImpl.java
$configFiles["service\impl\KnowledgeBaseServiceImpl.java"] = @'
package com.enterprise.rag.service.impl;

import com.enterprise.rag.dto.response.CategoryVO;
import com.enterprise.rag.service.api.KnowledgeBaseService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * 知识库服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class KnowledgeBaseServiceImpl implements KnowledgeBaseService {

    @Override
    public List<CategoryVO> listCategories() {
        // TODO: 实现分类列表逻辑
        return new ArrayList<>();
    }

    @Override
    public Long createCategory(CategoryVO category) {
        // TODO: 实现创建分类逻辑
        return null;
    }

    @Override
    public void updateCategory(CategoryVO category) {
        // TODO: 实现更新分类逻辑
    }

    @Override
    public void deleteCategory(Long id) {
        // TODO: 实现删除分类逻辑
    }
}
'@

# 26. DocumentVO.java
$configFiles["dto\response\DocumentVO.java"] = @'
package com.enterprise.rag.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档VO
 */
@Data
@Schema(description = "文档VO")
public class DocumentVO {
    private Long id;
    private String title;
    private String originalName;
    private String fileType;
    private Long fileSize;
    private String uploadUserName;
    private String categoryName;
    private Integer status;
    private String errorMessage;
    private Integer chunkCount;
    private Integer wordCount;
    private Integer viewPermission;
    private Long deptId;
    private LocalDateTime createdAt;
}
'@

# 27. RagResponse.java
$configFiles["dto\response\RagResponse.java"] = @'
package com.enterprise.rag.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.util.List;

/**
 * RAG回答响应
 */
@Data
@Schema(description = "RAG回答响应")
public class RagResponse {
    private String answer;
    private List<ChunkVO> sources;
    private Integer tokensUsed;
}
'@

# 28. ChunkVO.java
$configFiles["dto\response\ChunkVO.java"] = @'
package com.enterprise.rag.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 分片VO
 */
@Data
@Schema(description = "分片VO")
public class ChunkVO {
    private Long id;
    private Long documentId;
    private String documentTitle;
    private String content;
    private Double similarity;
    private Integer chunkIndex;
}
'@

# 29. CategoryVO.java
$configFiles["dto\response\CategoryVO.java"] = @'
package com.enterprise.rag.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 分类VO
 */
@Data
@Schema(description = "分类VO")
public class CategoryVO {
    private Long id;
    private String name;
    private Long parentId;
    private String description;
    private Integer sort;
}
'@

# 30. ChatHistoryVO.java
$configFiles["dto\response\ChatHistoryVO.java"] = @'
package com.enterprise.rag.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 对话历史VO
 */
@Data
@Schema(description = "对话历史VO")
public class ChatHistoryVO {
    private Long id;
    private String sessionId;
    private String question;
    private String answer;
    private java.util.List<Long> documentIds;
    private Integer tokensUsed;
    private LocalDateTime createdAt;
}
'@

# 31. DocumentUploadRequest.java
$configFiles["dto\request\DocumentUploadRequest.java"] = @'
package com.enterprise.rag.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

/**
 * 文档上传请求
 */
@Data
@Schema(description = "文档上传请求")
public class DocumentUploadRequest {
    @NotNull(message = "文件不能为空")
    private MultipartFile file;

    @NotBlank(message = "标题不能为空")
    private String title;

    private Long categoryId;

    @NotNull(message = "查看权限不能为空")
    private Integer viewPermission;

    private Long deptId;
}
'@

# 32. QueryRagRequest.java
$configFiles["dto\request\QueryRagRequest.java"] = @'
package com.enterprise.rag.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

/**
 * RAG问答请求
 */
@Data
@Schema(description = "RAG问答请求")
public class QueryRagRequest {
    @NotBlank(message = "问题不能为空")
    private String question;

    private Long categoryId;

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    private Integer topK = 3;

    private Double similarityThreshold = 0.5;
}
'@

# 33. ChatRequest.java
$configFiles["dto\request\ChatRequest.java"] = @'
package com.enterprise.rag.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 聊天请求
 */
@Data
@Schema(description = "聊天请求")
public class ChatRequest {
    private String sessionId;
    private String question;
    private Long userId;
}
'@

# 34. DocumentController.java
$configFiles["controller\DocumentController.java"] = @'
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
    public Result<Void> delete(@PathVariable Long id) {
        documentService.deleteDocument(id);
        return Result.success("删除成功");
    }

    @PutMapping("/{id}/status")
    @Operation(summary = "更新文档状态")
    public Result<Void> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        documentService.updateDocumentStatus(id, status);
        return Result.success("状态更新成功");
    }
}
'@

# 35. ChatController.java
$configFiles["controller\ChatController.java"] = @'
package com.enterprise.rag.controller;

import com.enterprise.rag.dto.request.QueryRagRequest;
import com.enterprise.rag.dto.response.RagResponse;
import com.enterprise.rag.service.api.ChatService;
import com.enterprise.rag.util.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 聊天/问答控制器
 */
@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
@Tag(name = "智能问答", description = "RAG问答相关接口")
public class ChatController {

    private final ChatService chatService;

    @PostMapping("/rag")
    @Operation(summary = "RAG问答")
    public Result<RagResponse> ragQuery(@Validated @RequestBody QueryRagRequest request) {
        RagResponse response = chatService.answerWithRag(request);
        return Result.success(response);
    }

    @GetMapping("/history")
    @Operation(summary = "对话历史")
    public Result<List<com.enterprise.rag.dto.response.ChatHistoryVO>> getHistory(@RequestParam String sessionId,
                                                  @RequestParam Long userId,
                                                  @RequestParam(defaultValue = "10") int pageSize,
                                                  @RequestParam(defaultValue = "1") int pageNum) {
        return Result.success(chatService.getChatHistory(sessionId, userId, pageSize, pageNum));
    }
}
'@

# 36. CategoryController.java
$configFiles["controller\CategoryController.java"] = @'
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
'@

# 37. FileUploadController.java
$configFiles["controller\FileUploadController.java"] = @'
package com.enterprise.rag.controller;

import com.enterprise.rag.dto.request.DocumentUploadRequest;
import com.enterprise.rag.service.api.DocumentService;
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
'@

# 38. BusinessException.java
$configFiles["exception\BusinessException.java"] = @'
package com.enterprise.rag.exception;

import lombok.Getter;

/**
 * 业务异常
 */
@Getter
public class BusinessException extends RuntimeException {
    private final int code;

    public BusinessException(String message) {
        super(message);
        this.code = 400;
    }

    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }

    public BusinessException(String message, Throwable cause) {
        super(message, cause);
        this.code = 400;
    }
}
'@

# 39. FileParseException.java
$configFiles["exception\FileParseException.java"] = @'
package com.enterprise.rag.exception;

import lombok.Getter;

/**
 * 文件解析异常
 */
@Getter
public class FileParseException extends RuntimeException {
    public FileParseException(String message) {
        super(message);
    }

    public FileParseException(String message, Throwable cause) {
        super(message, cause);
    }
}
'@

# 40. VectorDatabaseException.java
$configFiles["exception\VectorDatabaseException.java"] = @'
package com.enterprise.rag.exception;

import lombok.Getter;

/**
 * 向量数据库异常
 */
@Getter
public class VectorDatabaseException extends RuntimeException {
    public VectorDatabaseException(String message) {
        super(message);
    }

    public VectorDatabaseException(String message, Throwable cause) {
        super(message, cause);
    }
}
'@

# 41. OpenAiException.java
$configFiles["exception\OpenAiException.java"] = @'
package com.enterprise.rag.exception;

import lombok.Getter;

/**
 * OpenAI 调用异常
 */
@Getter
public class OpenAiException extends RuntimeException {
    public OpenAiException(String message) {
        super(message);
    }

    public OpenAiException(String message, Throwable cause) {
        super(message, cause);
    }
}
'@

# 42. DocumentStatus.java
$configFiles["constant\DocumentStatus.java"] = @'
package com.enterprise.rag.constant;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 文档状态枚举
 */
@Getter
@AllArgsConstructor
public enum DocumentStatus {
    PENDING(0, "待处理"),
    PROCESSING(1, "处理中"),
    READY(2, "已就绪"),
    FAILED(3, "处理失败");

    private final int code;
    private final String desc;
}
'@

# 43. PermissionLevel.java
$configFiles["constant\PermissionLevel.java"] = @'
package com.enterprise.rag.constant;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 权限级别枚举
 */
@Getter
@AllArgsConstructor
public enum PermissionLevel {
    READ(1, "只读"),
    WRITE(2, "编辑"),
    ADMIN(3, "管理");

    private final int code;
    private final String desc;
}
'@

# 44. ViewPermission.java
$configFiles["constant\ViewPermission.java"] = @'
package com.enterprise.rag.constant;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 查看权限类型
 */
@Getter
@AllArgsConstructor
public enum ViewPermission {
    PUBLIC(0, "公开"),
    PRIVATE(1, "仅上传人"),
    DEPT(2, "指定部门");

    private final int code;
    private final String desc;
}
'@

# 45. Result.java
$configFiles["util\Result.java"] = @'
package com.enterprise.rag.util;

import lombok.Data;

/**
 * 统一响应结果封装
 *
 * @param <T> 响应数据类型
 */
@Data
public class Result<T> {
    private int code;
    private String message;
    private T data;

    private Result(int code, String message, T data) {
        this.code = code;
        this.message = message;
        this.data = data;
    }

    public static <T> Result<T> success() {
        return new Result<>(200, "操作成功", null);
    }

    public static <T> Result<T> success(T data) {
        return new Result<>(200, "操作成功", data);
    }

    public static <T> Result<T> success(String message, T data) {
        return new Result<>(200, message, data);
    }

    public static <T> Result<T> error(String message) {
        return new Result<>(500, message, null);
    }

    public static <T> Result<T> error(int code, String message) {
        return new Result<>(code, message, null);
    }

    public static <T> Result<T> of(int code, String message, T data) {
        return new Result<>(code, message, data);
    }
}
'@

# 46. SecurityUtil.java
$configFiles["util\SecurityUtil.java"] = @'
package com.enterprise.rag.util;

import lombok.experimental.UtilityClass;

/**
 * 安全工具类（简化版）
 */
@UtilityClass
public class SecurityUtil {

    /**
     * 获取当前用户ID
     */
    public Long getCurrentUserId() {
        return 1L;
    }

    /**
     * 获取当前用户部门ID
     */
    public Long getCurrentUserDeptId() {
        return 1L;
    }
}
'@

# 47. FileUtil.java
$configFiles["util\FileUtil.java"] = @'
package com.enterprise.rag.util;

import lombok.experimental.UtilityClass;

/**
 * 文件工具类
 */
@UtilityClass
public class FileUtil {

    /**
     * 获取文件扩展名
     */
    public String getExtension(String filename) {
        if (filename == null) return "";
        int lastDot = filename.lastIndexOf('.');
        return lastDot > 0 ? filename.substring(lastDot + 1).toLowerCase() : "";
    }

    /**
     * 校验文件类型
     */
    public boolean isValidFileType(String type) {
        String[] validTypes = {"pdf", "doc", "docx", "md", "txt"};
        for (String validType : validTypes) {
            if (validType.equals(type.toLowerCase())) {
                return true;
            }
        }
        return false;
    }
}
'@

# 48. GlobalExceptionHandler.java
$configFiles["GlobalExceptionHandler.java"] = @'
package com.enterprise.rag.exception;

import com.enterprise.rag.util.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import javax.validation.ConstraintViolation;
import javax.validation.ConstraintViolationException;
import java.util.List;
import java.util.Set;

/**
 * 全局异常处理器
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<String> handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        List<FieldError> fieldErrors = e.getBindingResult().getFieldErrors();
        String msg = fieldErrors.stream()
                .map(FieldError::getDefaultMessage)
                .findFirst().orElse("参数校验失败");
        log.warn("[参数校验失败] {}", msg, e);
        return Result.error(400, msg);
    }

    @ExceptionHandler(BindException.class)
    public Result<String> handleBindException(BindException e) {
        List<FieldError> fieldErrors = e.getFieldErrors();
        String msg = fieldErrors.stream()
                .map(FieldError::getDefaultMessage)
                .findFirst().orElse("参数绑定失败");
        log.warn("[参数绑定失败] {}", msg, e);
        return Result.error(400, msg);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public Result<String> handleConstraintViolationException(ConstraintViolationException e) {
        Set<ConstraintViolation<?>> violations = e.getConstraintViolations();
        String msg = violations.stream()
                .map(ConstraintViolation::getMessage)
                .findFirst().orElse("参数校验失败");
        log.warn("[参数校验失败] {}", msg, e);
        return Result.error(400, msg);
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public Result<String> handleMissingServletRequestParameterException(MissingServletRequestParameterException e) {
        String msg = "缺少必要参数: " + e.getParameterName();
        log.warn("[缺少参数] {}", msg, e);
        return Result.error(400, msg);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public Result<String> handleHttpMessageNotReadableException(HttpMessageNotReadableException e) {
        String msg = "请求体格式错误";
        log.warn("[请求体格式错误] {}", msg, e);
        return Result.error(400, msg);
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public Result<String> handleMaxUploadSizeExceededException(MaxUploadSizeExceededException e) {
        String msg = "文件大小超出限制（最大 200MB）";
        log.warn("[文件过大] {}", msg, e);
        return Result.error(413, msg);
    }

    @ExceptionHandler(BusinessException.class)
    public Result<String> handleBusinessException(BusinessException e) {
        log.warn("[业务异常] {}", e.getMessage(), e);
        return Result.error(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(FileParseException.class)
    public Result<String> handleFileParseException(FileParseException e) {
        log.error("[文件解析失败] {}", e.getMessage(), e);
        return Result.error(400, "文件解析失败：" + e.getMessage());
    }

    @ExceptionHandler(VectorDatabaseException.class)
    public Result<String> handleVectorDatabaseException(VectorDatabaseException e) {
        log.error("[向量数据库异常] {}", e.getMessage(), e);
        return Result.error(503, "向量服务暂时不可用");
    }

    @ExceptionHandler(OpenAiException.class)
    public Result<String> handleOpenAiException(OpenAiException e) {
        log.error("[大模型调用异常] {}", e.getMessage(), e);
        return Result.error(504, "大模型服务调用失败");
    }

    @ExceptionHandler(org.springframework.web.servlet.resource.NoResourceFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public Result<String> handleNoResourceFoundException() {
        return Result.error(404, "资源不存在");
    }

    @ExceptionHandler(Exception.class)
    public Result<String> handleException(Exception e) {
        log.error("[系统异常] ", e);
        return Result.error(500, "系统异常，请联系管理员");
    }
}
'@

# 创建 MyBatis XML 文件
$mapperDir = Join-Path $baseDir "..\resources\mapper"
if (!(Test-Path $mapperDir)) {
    New-Item -ItemType Directory -Path $mapperDir -Force | Out-Null
}

$configFiles["mapper\DocumentMapper.xml"] = @'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.enterprise.rag.repository.DocumentMapper">

</mapper>
'@

$configFiles["mapper\DocumentChunkMapper.xml"] = @'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.enterprise.rag.repository.DocumentChunkMapper">

</mapper>
'@

$configFiles["mapper\PermissionMapper.xml"] = @'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.enterprise.rag.repository.PermissionMapper">

</mapper>
'@

$configFiles["mapper\ChatHistoryMapper.xml"] = @'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.enterprise.rag.repository.ChatHistoryMapper">

</mapper>
'@

# 写入所有文件
foreach ($filePath in $configFiles.Keys) {
    $fullPath = Join-Path $baseDir $filePath
    $content = $configFiles[$filePath]
    
    # 处理 MyBatis XML 文件路径
    if ($filePath -like "mapper/*") {
        $fullPath = Join-Path $baseDir "..\resources" $filePath
    }
    
    # 确保目录存在
    $dir = Split-Path $fullPath -Parent
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    try {
        Set-Content -Path $fullPath -Value $content -Encoding UTF8
        Write-Host "Created: $fullPath"
    } catch {
        Write-Host "Failed: $fullPath - $_" -ForegroundColor Red
    }
}

Write-Host "`nAll files created successfully!"
Write-Host "Base directory: $baseDir"
Write-Host "Mapper directory: $mapperDir"
