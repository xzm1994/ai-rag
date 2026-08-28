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
