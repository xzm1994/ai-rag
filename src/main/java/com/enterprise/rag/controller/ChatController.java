package com.enterprise.rag.controller;

import com.enterprise.rag.dto.request.QueryRagRequest;
import com.enterprise.rag.dto.response.RagResponse;
import com.enterprise.rag.service.api.ChatService;
import com.enterprise.rag.util.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 聊天/问答控制器
 */
@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
@Tag(name = "智能问答", description = "RAG问答相关接口")
public class ChatController {

    private final ChatService chatService;

    @PostMapping("/rag")
    @Operation(summary = "RAG问答")
    public Result<RagResponse> ragQuery(@Validated @RequestBody QueryRagRequest request) {
        RagResponse response = chatService.answerWithRag(request);
        return Result.success(response);
    }

    @GetMapping("/history")
    @Operation(summary = "对话历史")
    public Result<List<com.enterprise.rag.dto.response.ChatHistoryVO>> getHistory(@RequestParam String sessionId,
                                                  @RequestParam Long userId,
                                                  @RequestParam(defaultValue = "10") int pageSize,
                                                  @RequestParam(defaultValue = "1") int pageNum) {
        return Result.success(chatService.getChatHistory(sessionId, userId, pageSize, pageNum));
    }
}
