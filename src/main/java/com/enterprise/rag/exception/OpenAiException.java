package com.enterprise.rag.exception;

import lombok.Getter;

/**
 * OpenAI 调用异常
 */
@Getter
public class OpenAiException extends RuntimeException {
    public OpenAiException(String message) {
        super(message);
    }

    public OpenAiException(String message, Throwable cause) {
        super(message, cause);
    }
}
