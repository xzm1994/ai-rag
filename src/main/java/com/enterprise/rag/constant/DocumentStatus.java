package com.enterprise.rag.constant;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 文档状态枚举
 */
@Getter
@AllArgsConstructor
public enum DocumentStatus {
    PENDING(0, "待处理"),
    PROCESSING(1, "处理中"),
    READY(2, "已就绪"),
    FAILED(3, "处理失败");

    private final int code;
    private final String desc;
}
