package com.enterprise.rag.util;

import lombok.experimental.UtilityClass;

/**
 * 文件工具类
 */
@UtilityClass
public class FileUtil {

    /**
     * 获取文件扩展名
     */
    public String getExtension(String filename) {
        if (filename == null) return "";
        int lastDot = filename.lastIndexOf('.');
        return lastDot > 0 ? filename.substring(lastDot + 1).toLowerCase() : "";
    }

    /**
     * 校验文件类型
     */
    public boolean isValidFileType(String type) {
        String[] validTypes = {"pdf", "doc", "docx", "md", "txt"};
        for (String validType : validTypes) {
            if (validType.equals(type.toLowerCase())) {
                return true;
            }
        }
        return false;
    }
}
