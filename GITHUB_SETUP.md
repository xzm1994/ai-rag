# 企业内部AI知识库RAG系统 - GitHub仓库创建指南

## 📋 仓库创建步骤

### 步骤1：登录GitHub

访问 https://github.com 并登录您的账户。

### 步骤2：创建新仓库

1. 点击右上角 `+` 号
2. 选择 "New repository"

### 步骤3：填写仓库信息

| 字段 | 值 |
|------|-----|
| **Repository name** | `rag-enterprise-knowledge-base` |
| **Description** | `Enterprise Internal AI Knowledge Base RAG System` |
| **Repository type** | ☑️ Private (私有) |
| **Initialize with README** | ☑️ |
| **Add .gitignore** | ☑️ Java |
| **Choose a license** | ☑️ MIT |

### 步骤4：创建仓库

点击 "Create repository" 按钮。

---

## 🔧 代码提交步骤

### 方法一：命令行提交（推荐）

```bash
# 1. 进入项目目录
cd Z:\myworkspace\ai-rag

# 2. 初始化Git仓库
git init

# 3. 添加远程仓库（替换YOUR_USERNAME为您自己的GitHub用户名）
git remote add origin https://github.com/YOUR_USERNAME/rag-enterprise-knowledge-base.git

# 4. 添加所有文件
git add .

# 5. 提交代码
git commit -m "Initial commit: Enterprise AI Knowledge Base RAG System"

# 6. 推送到GitHub
git branch -M main
git push -u origin main
```

### 方法二：使用GitHub Desktop

1. 下载 [GitHub Desktop](https://desktop.github.com/)
2. 打开 → File → Add Local Repository
3. 选择 `Z:\myworkspace\ai-rag`
4. Publish repository

---

## 🎯 完整的Git命令

```bash
# 创建项目目录（如果还没有）
cd Z:\myworkspace

# 进入项目
cd ai-rag

# 初始化Git
git init

# 配置用户信息（一次性）
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/rag-enterprise-knowledge-base.git

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: Enterprise AI Knowledge Base RAG System"

# 推送
git branch -M main
git push -u origin main
```

---

## 📝 重要提示

### 1. 敏感信息处理

**请在提交前移除以下敏感信息**：

**application.yml**:
```yaml
# 替换这些占位符
api-key: sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  # 实际的API密钥
password: root1234  # 实际的数据库密码
```

**创建 .env.local 文件**:
```bash
# 创建 .env.local（不提交到Git）
OPENAI_API_KEY=sk-xxxxx
MYSQL_PASSWORD=xxxxx
MILVUS_PASSWORD=xxxxx
```

### 2. 创建 .gitignore

请创建 `.gitignore` 文件，内容如下：

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

# IDE
.idea/
*.iml
.settings/
.project
.classpath

# Upload files
D:/rag/uploads/
upload/
*.upload

# Environment files
.env
.env.local
.env.*.local
```

---

## 🔍 验证提交

提交后，访问以下地址验证：

```
https://github.com/YOUR_USERNAME/rag-enterprise-knowledge-base
```

---

## 📚 文件清单

以下文件已准备提交：

```
ai-rag/
├── src/main/
│   ├── java/com/enterprise/rag/     # 48个Java文件
│   └── resources/                     # 配置文件
├── pom.xml                            # Maven配置
├── README.md                          # 项目说明
├── PATCH_NOTES.md                     # 补丁说明
├── GITHUB_GUIDE.md                    # 本指南
├── rag_database.sql                   # 数据库脚本
└── .gitignore                         # Git忽略配置
```

---

## ⚠️ 注意事项

1. **文件权限问题**：如果遇到写权限问题，请以管理员身份运行命令行
2. **敏感信息**：务必替换API密钥和密码
3. **.gitignore**：建议创建防止敏感文件提交
4. **分支策略**：推荐使用 main 分支作为主分支

---

## 🆘 常见问题

### Q: Git push 失败
A: 
```bash
git pull origin main --allow-unrelated-histories
git push
```

### Q: 忘记提交某些文件
A:
```bash
git add <file>
git commit -m "Add missing files"
git push
```

### Q: 如何回滚提交
A:
```bash
git reset --hard HEAD~1
git push -f
```

---

## 🎉 完成！

提交成功后，您的代码将保存在：
```
https://github.com/YOUR_USERNAME/rag-enterprise-knowledge-base
```

如有任何问题，请参考 [GitHub Help](https://help.github.com/)。
