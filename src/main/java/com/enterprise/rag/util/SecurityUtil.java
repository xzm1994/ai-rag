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
        // TODO: 从 SecurityContext 或 ThreadLocal 获取
        return 1L;
    }

    /**
     * 获取当前用户部门ID
     */
    public Long getCurrentUserDeptId() {
        // TODO: 从 SecurityContext 或 ThreadLocal 获取
        return 1L;
    }
}
