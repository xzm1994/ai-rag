package com.enterprise.rag.exception;

import lombok.Getter;

/**
 * 文件解析异常
 */
@Getter
public class FileParseException extends RuntimeException {
    public FileParseException(String message) {
        super(message);
    }

    public FileParseException(String message, Throwable cause) {
        super(message, cause);
    }
}
