package com.enterprise.rag.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 分类VO
 */
@Data
@Schema(description = "分类VO")
public class CategoryVO {
    private Long id;
    private String name;
    private Long parentId;
    private String description;
    private Integer sort;
}
