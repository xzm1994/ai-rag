-- 企业内部AI知识库RAG系统 - MySQL建表SQL
-- 数据库创建
CREATE DATABASE IF NOT EXISTS enterprise_rag DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE enterprise_rag;

-- 用户表（简化版，实际可对接企业AD/LDAP）
CREATE TABLE IF NOT EXISTS user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    nickname VARCHAR(50) COMMENT '昵称',
    dept_id BIGINT COMMENT '部门ID',
    role VARCHAR(20) DEFAULT 'USER' COMMENT '角色：ADMIN/USER',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_dept_id (dept_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 知识库分类表
CREATE TABLE IF NOT EXISTS category (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    name VARCHAR(50) NOT NULL COMMENT '分类名称',
    parent_id BIGINT DEFAULT 0 COMMENT '父分类ID（0表示根）',
    description VARCHAR(255) COMMENT '描述',
    sort INT DEFAULT 0 COMMENT '排序',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_parent_id (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识库分类表';

-- 文档主表
CREATE TABLE IF NOT EXISTS document (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '文档ID',
    title VARCHAR(255) NOT NULL COMMENT '文档标题',
    original_name VARCHAR(255) NOT NULL COMMENT '原始文件名',
    file_path VARCHAR(500) NOT NULL COMMENT '文件存储路径',
    file_size BIGINT COMMENT '文件大小（字节）',
    file_type VARCHAR(50) COMMENT '文件类型：PDF/DOC/DOCX/MD/TXT',
    upload_user_id BIGINT NOT NULL COMMENT '上传用户ID',
    category_id BIGINT COMMENT '分类ID',
    status TINYINT DEFAULT 0 COMMENT '状态：0=待处理,1=处理中,2=已就绪,3=处理失败',
    error_message VARCHAR(500) COMMENT '错误信息',
    chunk_count INT DEFAULT 0 COMMENT '分片数量',
    word_count INT DEFAULT 0 COMMENT '字数',
    view_permission TINYINT DEFAULT 0 COMMENT '查看权限：0=公开,1=仅上传人,2=指定部门',
    dept_id BIGINT COMMENT '可见部门ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_upload_user_id (upload_user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文档主表';

-- 文档分片表（向量化前的文本分片）
CREATE TABLE IF NOT EXISTS document_chunk (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分片ID',
    document_id BIGINT NOT NULL COMMENT '文档ID',
    chunk_index INT NOT NULL COMMENT '分片序号',
    content TEXT NOT NULL COMMENT '分片内容',
    content_length INT COMMENT '内容长度',
    token_count INT COMMENT 'Token数量（估算）',
    embedding_status TINYINT DEFAULT 0 COMMENT '向量化状态：0=未向量,1=处理中,2=已就绪,3=失败',
    vector_id VARCHAR(64) COMMENT 'Milvus向量ID',
    error_message VARCHAR(500) COMMENT '错误信息',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_document_id (document_id),
    INDEX idx_embedding_status (embedding_status),
    FULLTEXT INDEX ft_content (content) WITH_PARSER ngram
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文档分片表';

-- 知识库权限表
CREATE TABLE IF NOT EXISTS permission (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '权限ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    document_id BIGINT NOT NULL COMMENT '文档ID',
    permission_level TINYINT NOT NULL COMMENT '权限级别：1=只读,2=编辑,3=管理',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_document (user_id, document_id),
    INDEX idx_user_id (user_id),
    INDEX idx_document_id (document_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识库权限表';

-- 对话历史表
CREATE TABLE IF NOT EXISTS chat_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '对话ID',
    session_id VARCHAR(64) NOT NULL COMMENT '会话ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    question TEXT NOT NULL COMMENT '问题内容',
    answer TEXT NOT NULL COMMENT '回答内容',
    document_ids TEXT COMMENT '引用文档ID列表（JSON数组）',
    tokens_used INT DEFAULT 0 COMMENT '消耗Token数',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_session_id (session_id),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='对话历史表';
