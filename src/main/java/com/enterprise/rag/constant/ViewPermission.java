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
