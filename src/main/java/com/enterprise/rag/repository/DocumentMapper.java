package com.enterprise.rag.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.enterprise.rag.domain.Document;
import org.apache.ibatis.annotations.Mapper;

/**
 * 文档Mapper
 */
@Mapper
public interface DocumentMapper extends BaseMapper<Document> {
}
