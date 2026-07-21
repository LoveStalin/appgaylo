import 'package:flutter/material.dart';

import '../models/chapter_model.dart';
import '../models/messages_model.dart';
import '../services/chapter_service.dart';
import '../services/messages_service.dart';
import '../widgets/chat_box.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/glass_bottom_bar.dart';

class ChatStoryScreen extends StatefulWidget {
  final String storyId;

  const ChatStoryScreen({super.key, required this.storyId});

  @override
  State<ChatStoryScreen> createState() => _ChatStoryScreenState();
}

class _ChatStoryScreenState extends State<ChatStoryScreen> {
  final ChapterService _chapterService = ChapterService();
  final MessageService _messageService = MessageService();
  final ScrollController _scrollController = ScrollController();

  ChapterModel? currentChapter;
  List<MessageModel> messages = [];
  int visibleMessageCount = 1;
  bool isTyping = false;
  MessageModel? typingMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFirstChapter();
  }

  Future<void> loadFirstChapter() async {
    final chapters = await _chapterService.getChapters(widget.storyId);
    if (!mounted) return;

    if (chapters.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    currentChapter = chapters.first;
    await loadMessages();
  }

  Future<void> loadMessages() async {
    if (currentChapter == null) return;

    final loadedMessages = await _messageService.getMessages(
      widget.storyId,
      currentChapter!.chapterId,
    );
    if (!mounted) return;

    setState(() {
      messages = loadedMessages;
      visibleMessageCount = loadedMessages.isEmpty ? 0 : 1;
      isLoading = false;
    });
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> showNextMessage() async {
    if (isTyping || visibleMessageCount >= messages.length) return;

    final nextMessage = messages[visibleMessageCount];
    setState(() {
      isTyping = true;
      typingMessage = nextMessage;
    });
    scrollToBottom();

    await Future.delayed(const Duration(seconds: 1)); // Giả lập thời gian "đang nhập" của nhân vật
    if (!mounted) return;

    setState(() {
      isTyping = false;
      typingMessage = null;
      visibleMessageCount++;
    });
    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentChapter?.title ?? '\u0110ang t\u1ea3i...'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleMessageCount + (isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      final isVisibleMessage = index < visibleMessageCount;
                      final message = isVisibleMessage
                          ? messages[index]
                          : typingMessage!;

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) => SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        ),
                        child: isVisibleMessage
                            ? ChatBox(
                                key: ValueKey('message-${message.messageId}'),
                                message: message,
                              )
                            : ChatBubble(
                                key: ValueKey('typing-${message.messageId}'),
                                isRight: message.senderType == 'right',
                              ),
                      );
                    },
                  ),
                ),
                GlassBottomBar(
                  onTap: isTyping ? null : showNextMessage,
                  text: isTyping
                      ? '\u0110ang nh\u1eadp...'
                      : 'Ch\u1ea1m \u0111\u1ec3 ti\u1ebfp t\u1ee5c',
                ),
              ],
            ),
    );
  }
}
