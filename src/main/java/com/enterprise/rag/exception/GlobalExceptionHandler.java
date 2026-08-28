package com.enterprise.rag.exception;

import com.enterprise.rag.util.Result;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import java.util.List;
import java.util.Set;

/**
 * 全局异常处理器
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<String> handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        List<FieldError> fieldErrors = e.getBindingResult().getFieldErrors();
        String msg = fieldErrors.stream()
                .map(FieldError::getDefaultMessage)
                .findFirst().orElse("参数校验失败");
        log.warn("[参数校验失败] {}", msg, e);
        return Result.error(400, msg);
    }

    @ExceptionHandler(BindException.class)
    public Result<String> handleBindException(BindException e) {
        List<FieldError> fieldErrors = e.getFieldErrors();
        String msg = fieldErrors.stream()
                .map(FieldError::getDefaultMessage)
                .findFirst().orElse("参数绑定失败");
        log.warn("[参数绑定失败] {}", msg, e);
        return Result.error(400, msg);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public Result<String> handleConstraintViolationException(ConstraintViolationException e) {
        Set<ConstraintViolation<?>> violations = e.getConstraintViolations();
        String msg = violations.stream()
                .map(ConstraintViolation::getMessage)
                .findFirst().orElse("参数校验失败");
        log.warn("[参数校验失败] {}", msg, e);
        return Result.error(400, msg);
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public Result<String> handleMissingServletRequestParameterException(MissingServletRequestParameterException e) {
        String msg = "缺少必要参数: " + e.getParameterName();
        log.warn("[缺少参数] {}", msg, e);
        return Result.error(400, msg);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public Result<String> handleHttpMessageNotReadableException(HttpMessageNotReadableException e) {
        String msg = "请求体格式错误";
        log.warn("[请求体格式错误] {}", msg, e);
        return Result.error(400, msg);
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public Result<String> handleMaxUploadSizeExceededException(MaxUploadSizeExceededException e) {
        String msg = "文件大小超出限制（最大 200MB）";
        log.warn("[文件过大] {}", msg, e);
        return Result.error(413, msg);
    }

    @ExceptionHandler(BusinessException.class)
    public Result<String> handleBusinessException(BusinessException e) {
        log.warn("[业务异常] {}", e.getMessage(), e);
        return Result.error(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(FileParseException.class)
    public Result<String> handleFileParseException(FileParseException e) {
        log.error("[文件解析失败] {}", e.getMessage(), e);
        return Result.error(400, "文件解析失败：" + e.getMessage());
    }

    @ExceptionHandler(VectorDatabaseException.class)
    public Result<String> handleVectorDatabaseException(VectorDatabaseException e) {
        log.error("[向量数据库异常] {}", e.getMessage(), e);
        return Result.error(503, "向量服务暂时不可用");
    }

    @ExceptionHandler(OpenAiException.class)
    public Result<String> handleOpenAiException(OpenAiException e) {
        log.error("[大模型调用异常] {}", e.getMessage(), e);
        return Result.error(504, "大模型服务调用失败");
    }

    @ExceptionHandler(org.springframework.web.servlet.resource.NoResourceFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public Result<String> handleNoResourceFoundException() {
        return Result.error(404, "资源不存在");
    }

    @ExceptionHandler(Exception.class)
    public Result<String> handleException(Exception e) {
        log.error("[系统异常] ", e);
        return Result.error(500, "系统异常，请联系管理员");
    }
}
