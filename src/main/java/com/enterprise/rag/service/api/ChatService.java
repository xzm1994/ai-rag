package com.enterprise.rag.service.api;

import com.enterprise.rag.dto.request.QueryRagRequest;
import com.enterprise.rag.dto.response.RagResponse;
import com.enterprise.rag.dto.response.ChatHistoryVO;

import java.util.List;

/**
 * 聊天/问答服务接口
 */
public interface ChatService {
    RagResponse answerWithRag(QueryRagRequest request);
    List<ChatHistoryVO> getChatHistory(String sessionId, Long userId, int pageSize, int pageNum);
}
