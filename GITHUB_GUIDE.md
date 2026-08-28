# 企业内部AI知识库RAG系统 - GitHub仓库创建与代码提交指南

## 📋 创建GitHub仓库步骤

### 第一步：登录GitHub并创建新仓库

1. 访问 https://github.com
2. 登录您的GitHub账户
3. 点击右上角 `+` 号 → 选择 "New repository"
4. 填写仓库信息：

**Repository name**: `rag-enterprise-knowledge-base`

**Description**: `Enterprise Internal AI Knowledge Base RAG System`

**Repository type**: 
- ☑️ Private（私有仓库）或
- ☐ Public（公开仓库）

**初始化选项**：
- ☑️ Add a README file
- ☑️ Add .gitignore: Java
- ☑️ Choose a license: MIT

5. 点击 "Create repository" 按钮

---

## 🔧 代码提交步骤

### 方式一：使用命令行提交（推荐）

#### 1. 初始化Git仓库

```bash
# 进入项目目录
cd Z:\myworkspace\ai-rag

# 初始化Git仓库
git init

# 添加远程仓库地址
git remote add origin https://github.com/YOUR_USERNAME/rag-enterprise-knowledge-base.git

# 添加所有文件
git add .

# 提交代码
git commit -m "Initial commit: Enterprise AI Knowledge Base RAG System"
```

#### 2. 推送代码到GitHub

```bash
# 推送主分支
git branch -M main
git push -u origin main
```

---

### 方式二：使用GitHub Desktop（图形界面）

1. 下载并安装 [GitHub Desktop](https://desktop.github.com/)
2. 打开GitHub Desktop
3. 点击 "File" → "Add Local Repository"
4. 选择项目目录：`Z:\myworkspace\ai-rag`
5. 点击 "Publish repository"
6. 选择仓库类型（公开/私有）
7. 点击 "Publish repository"

---

## 📁 项目文件清单

以下是需要提交到GitHub的文件结构：

```
ai-rag/
├── src/
│   └── main/
│       ├── java/com/enterprise/rag/
│       │   ├── Application.java
│       │   ├── config/
│       │   ├── controller/
│       │   ├── service/
│       │   │   ├── api/
│       │   │   └── impl/
│       │   ├── domain/
│       │   ├── repository/
│       │   ├── dto/
│       │   │   ├── request/
│       │   │   └── response/
│       │   ├── exception/
│       │   ├── constant/
│       │   └── util/
│       └── resources/
│           ├── application.yml
│           ├── application-dev.yml
│           ├── application-prod.yml
│           └── mapper/
├── pom.xml
├── README.md
├── PATCH_NOTES.md
├── rag_database.sql
├── sql/
│   └── rag_database.sql
└── .gitignore
```

---

## 🎯 推荐的 .gitignore 内容

请在项目根目录创建 `.gitignore` 文件，内容如下：

```
# Compiled class file
*.class

# Log file
*.log
logs/

# Package Files
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar

# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
buildNumber.properties
.mvn/timing.properties

# IDE
.idea/
*.iml
*.iws
*.ipr
.settings/
.project
.classpath

# Environment variables
.env
.env.local
.env.*.local

# Temporary files
*.tmp
*.temp
*.swp
*~

# IDE specific files
.vscode/
.idea/

# OS specific files
.DS_Store
Thumbs.db

# Upload files (建议使用对象存储，本地上传文件不提交)
D:/rag/uploads/
upload/
*.upload

# Database files
*.db
*.sqlite
```

---

## 🔍 验证提交

提交完成后，您可以通过以下方式验证：

### 1. 网页验证
访问 `https://github.com/YOUR_USERNAME/rag-enterprise-knowledge-base`

### 2. 命令行验证
```bash
git log
git remote -v
```

### 3. 拉取验证
```bash
cd ..
git clone https://github.com/YOUR_USERNAME/rag-enterprise-knowledge-base.git
```

---

## 📝 关于敏感信息保护

请务必在提交前移除或替换以下敏感信息：

### 1. application.yml
```yaml
# 将这些占位符替换为实际值
api-key: sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  # 替换为实际API密钥
password: root1234  # 替换为实际密码
```

### 2. 创建 .env.local 文件
```bash
# 创建 .env.local 文件（不提交到Git）
OPENAI_API_KEY=sk-xxxxx
MYSQL_PASSWORD=xxxxx
MILVUS_PASSWORD=xxxxx
```

### 3. 更新 .gitignore
```
# 环境配置文件
.env
.env.local
.env.*.local
```

---

## 🎉 提交成功

提交成功后，您将获得：

1. ✅ GitHub 仓库地址
2. ✅ 完整的项目代码
3. ✅ 文档说明
4. ✅ 数据库脚本
5. ✅ 配置文件

---

## 📚 后续操作

### 1. 配置CI/CD（可选）
- 集成 GitHub Actions 自动构建
- 配置测试覆盖率检查

### 2. 添加分支策略
- 创建 `main` 分支（保护）
- 创建 `develop` 分支
- 创建 `feature/*` 分支

### 3. 设置协作者
- 添加团队成员作为协作者
- 设置合适的权限

---

## 🆘 常见问题

### Q: 如何处理文件权限问题？
A: 在Windows上，可能需要以管理员身份运行命令行，或者将项目移动到非系统盘。

### Q: Git push 失败怎么办？
A: 
1. 先执行 `git pull origin main`
2. 解决冲突后再次执行 `git push`

### Q: 忘记添加某些文件怎么办？
A: 
```bash
git add <file>
git commit -m "Add missing files"
git push
```

---

如有任何问题，请参考 [GitHub Help](https://help.github.com/) 或随时联系我。
