package com.enterprise.rag.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.enterprise.rag.domain.DocumentChunk;
import com.enterprise.rag.dto.request.QueryRagRequest;
import com.enterprise.rag.dto.response.RagResponse;
import com.enterprise.rag.dto.response.ChunkVO;
import com.enterprise.rag.exception.OpenAiException;
import com.enterprise.rag.repository.ChatHistoryMapper;
import com.enterprise.rag.service.api.ChatService;
import com.enterprise.rag.service.api.VectorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 聊天服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final ChatModel chatModel;
    private final VectorService vectorService;
    private final ChatHistoryMapper historyMapper;

    @Override
    public RagResponse answerWithRag(QueryRagRequest request) {
        try {
            List<DocumentChunk> similarChunks = vectorService.searchSimilar(
                    request.getQuestion(),
                    request.getTopK(),
                    request.getSimilarityThreshold()
            );

            if (similarChunks.isEmpty()) {
                log.warn("未检索到相关知识: question={}", request.getQuestion());
            }

            String context = buildContext(similarChunks);
            String promptTemplate = buildPrompt(context, request.getQuestion());

            List<Message> messages = Collections.singletonList(new UserMessage(promptTemplate));
            Prompt prompt = new Prompt(messages);
            ChatResponse response = chatModel.call(prompt);

            String answer = response.getResult().getOutput().getContent();

            RagResponse ragResponse = new RagResponse();
            ragResponse.setAnswer(answer);
            ragResponse.setSources(convertToChunkVOs(similarChunks));

            return ragResponse;

        } catch (Exception e) {
            log.error("RAG问答失败", e);
            throw new OpenAiException("大模型调用失败：" + e.getMessage());
        }
    }

    @Override
    public List<com.enterprise.rag.dto.response.ChatHistoryVO> getChatHistory(String sessionId, Long userId, int pageSize, int pageNum) {
        LambdaQueryWrapper<com.enterprise.rag.domain.ChatHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(com.enterprise.rag.domain.ChatHistory::getSessionId, sessionId)
                .eq(com.enterprise.rag.domain.ChatHistory::getUserId, userId)
                .orderByDesc(com.enterprise.rag.domain.ChatHistory::getCreatedAt);

        // TODO: 实现转换逻辑
        return new ArrayList<>();
    }

    private String buildContext(List<DocumentChunk> chunks) {
        if (chunks.isEmpty()) {
            return "无相关知识库内容";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("【知识库内容】\n");
        for (DocumentChunk chunk : chunks) {
            sb.append("分片 ").append(chunk.getChunkIndex()).append(":\n");
            sb.append(chunk.getContent()).append("\n\n");
        }
        return sb.toString();
    }

    private String buildPrompt(String context, String question) {
        return String.format(
                "你是一个企业知识库助手，请基于以下知识库内容回答问题。\n" +
                "如果知识库中没有相关信息，请如实回答'知识库中无相关信息。\n" +
                "【知识库内容】\n%s\n\n" +
                "【问题】\n%s\n\n" +
                "【回答】",
                context, question
        );
    }

    private List<ChunkVO> convertToChunkVOs(List<DocumentChunk> chunks) {
        return chunks.stream()
                .map(chunk -> {
                    ChunkVO vo = new ChunkVO();
                    vo.setId(chunk.getId());
                    vo.setDocumentId(chunk.getDocumentId());
                    vo.setContent(chunk.getContent());
                    vo.setChunkIndex(chunk.getChunkIndex());
                    return vo;
                })
                .collect(Collectors.toList());
    }
}
