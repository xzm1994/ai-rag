package com.enterprise.rag.exception;

import lombok.Getter;

/**
 * 向量数据库异常
 */
@Getter
public class VectorDatabaseException extends RuntimeException {
    public VectorDatabaseException(String message) {
        super(message);
    }

    public VectorDatabaseException(String message, Throwable cause) {
        super(message, cause);
    }
}
