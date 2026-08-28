package com.enterprise.rag;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

/**
 * 企业内部AI知识库RAG系统 - 启动类
 *
 * @author Enterprise RAG Team
 */
@SpringBootApplication
@EnableAsync  // 启用异步处理
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
        System.out.println("==========================================");
        System.out.println("✅ 企业AI知识库RAG系统启动成功！");
        System.out.println("🌐 访问地址：http://localhost:8080");
        System.out.println("📝 API文档：http://localhost:8080/swagger-ui.html");
        System.out.println("==========================================");
    }
}
