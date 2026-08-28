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
