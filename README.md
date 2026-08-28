# 企业内部AI知识库RAG系统

## 项目介绍
这是一个基于Spring Boot 3.3.x的企业级AI知识库系统，支持文档上传、智能问答、权限管理等功能。

## 技术栈
- 后端框架：Spring Boot 3.3.x + Java 17
- ORM框架：MyBatis-Plus
- 文档解析：Apache Tika
- 向量数据库：Milvus
- 大模型：OpenAI兼容接口（支持通义千问、DeepSeek等）
- 工具库：Hutool、Lombok、Fastjson

## 项目结构
```
src/main/java/com/enterprise/rag/
├── Application.java              # 启动类
├── config/                       # 配置类
├── constant/                     # 常量枚举
├── controller/                   # 控制器层
├── domain/                       # 领域实体
├── service/                      # 服务层
│   ├── api/                      # 服务接口
│   └── impl/                     # 服务实现
├── repository/                   # 数据访问层
├── dto/                          # 数据传输对象
├── exception/                    # 异常处理
└── util/                         # 工具类
```

## 快速开始

### 1. 数据库初始化
执行`sql/rag_database.sql`初始化数据库表结构。

### 2. 配置文件
修改`application.yml`和`application-dev.yml`中的配置：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/enterprise_rag?useUnicode=true&characterEncoding=utf8mb4&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: root1234

enterprise:
  rag:
    milvus:
      host: localhost
      port: 19530
      collection-name: rag_document_chunks
      dimension: 1024
    openai:
      base-url: https://api.deepseek.com/v1
      api-key: your-api-key
```

### 3. 启动项目
```bash
mvn spring-boot:run
```

## API接口文档

### 文档管理
- `POST /api/upload/document` - 上传文档
- `GET /api/documents/list` - 文档列表
- `GET /api/documents/{id}` - 文档详情
- `DELETE /api/documents/{id}` - 删除文档
- `PUT /api/documents/{id}/status` - 更新文档状态

### 智能问答
- `POST /api/chat/rag` - RAG问答
- `GET /api/chat/history` - 对话历史

### 分类管理
- `GET /api/categories/list` - 分类列表
- `POST /api/categories` - 新增分类
- `PUT /api/categories` - 更新分类
- `DELETE /api/categories/{id}` - 删除分类

## 核心功能

### 1. 文档处理流程
1. 用户上传文档（支持PDF、Word、Markdown、TXT）
2. 系统异步处理：解析 → 清洗 → 分片 → 向量化 → 入库
3. 文档状态：待处理 → 处理中 → 已就绪 → 处理失败

### 2. RAG问答流程
1. 用户提问
2. 向量检索相似分片（topK=3）
3. 构建Prompt（知识库内容 + 问题）
4. 调用大模型生成回答
5. 返回结果（包含引用来源）

### 3. 权限控制
- 公开：所有人可见
- 私有：仅上传人可见
- 部门：指定部门可见

## 部署说明

### 开发环境
```bash
# 启动MySQL
docker run --name mysql -e MYSQL_ROOT_PASSWORD=root1234 -p 3306:3306 -d mysql:8.0

# 启动Milvus（Standalone模式）
docker run -d --name milvus -p 19530:19530 -p 9091:9091 milvusdb/milvus:v2.3.0

# 启动项目
mvn spring-boot:run -Dspring.profiles.active=dev
```

### 生产环境
1. 配置生产环境数据库连接
2. 配置Milvus集群模式（可选）
3. 配置Nginx反向代理
4. 开启HTTPS
5. 配置日志轮转
6. 设置监控告警

## 参数调优建议

| 参数 | 默认值 | 调优建议 |
|------|--------|----------|
| chunk.max-size | 300字符 | 大模型上下文窗口大时可增至512-1024 |
| chunk.overlap | 30字符 | 建议为max-size的10%-15% |
| topK | 3 | 提高召回率可增至5-10 |
| similarityThreshold | 0.5 | 提高精度可增至0.7-0.8 |
| temperature | 0.7 | 问答用0.2-0.5 |

## 注意事项

1. **文件存储**：默认存储在`D:/rag/uploads`，建议使用NFS或对象存储
2. **向量维度**：确保与向量模型输出维度一致（bge-large-zh-v1.5为1024）
3. **Token限制**：注意大模型的上下文窗口限制
4. **权限控制**：生产环境建议集成AD/LDAP
5. **日志级别**：生产环境建议设为INFO或WARN

## 已知限制

1. Milvus Collection需手动创建或修改配置类
2. 文件解析依赖本地文件系统，分布式部署需考虑文件共享
3. 权限服务实现较为基础，生产环境建议完善RBAC模型
4. 未包含文件版本控制功能

## 扩展功能建议

1. **文件存储优化**：集成MinIO/S3对象存储
2. **权限系统完善**：集成LDAP/AD
3. **监控告警**：集成Prometheus + Grafana
4. **日志审计**：记录用户操作日志
5. **缓存优化**：Redis缓存热点问题
6. **异步任务**：使用Quartz实现复杂定时任务

## 联系方式

如有问题或建议，请提交Issue或联系开发团队。