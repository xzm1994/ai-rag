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
