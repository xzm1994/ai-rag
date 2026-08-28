package com.enterprise.rag.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.enterprise.rag.domain.ChatHistory;
import org.apache.ibatis.annotations.Mapper;

/**
 * 对话历史Mapper
 */
@Mapper
public interface ChatHistoryMapper extends BaseMapper<ChatHistory> {
}
