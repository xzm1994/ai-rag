package com.enterprise.rag.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.enterprise.rag.domain.DocumentChunk;
import org.apache.ibatis.annotations.Mapper;

/**
 * 文档分片Mapper
 */
@Mapper
public interface DocumentChunkMapper extends BaseMapper<DocumentChunk> {
}
