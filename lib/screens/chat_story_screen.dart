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

    if (chapters.isEmpty) {
      setState(() {
        isLoading = false;
      });

      return;
    }

    currentChapter = chapters.first;

    await loadMessages();
  }

  Future<void> loadMessages() async {
    if (currentChapter == null) return;

    messages = await _messageService.getMessages(
      widget.storyId,
      currentChapter!.chapterId,
    );
    visibleMessageCount = messages.isEmpty ? 0 : 1;

    setState(() {
      isLoading = false;
    });
    final raw = await _messageService.getMessages(
      widget.storyId,
      currentChapter!.chapterId,
    );

    debugPrint("Message length = ${raw.length}");

    for (var m in raw) {
      debugPrint(
        "sender=${m.sender} | text=${m.text} | senderType=${m.senderType}",
      );
    }

    messages = raw;
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
    // Đang typing thì không cho bấm tiếp
    if (isTyping) return;

    // Nếu vẫn còn message
    if (visibleMessageCount < messages.length) {
      final nextMessage = messages[visibleMessageCount];

      setState(() {
        isTyping = true;
        typingMessage = nextMessage;
      });

      // Chờ 2 giây
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        isTyping = false;

        typingMessage = null;

        visibleMessageCount++;
      });

      scrollToBottom();

      return;
    }

    // TODO:
    // Sang chapter mới
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(currentChapter?.title ?? "Đang tải...")),

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
                      if (index < visibleMessageCount) {
                        return ChatBox(message: messages[index]);
                      }

                      return ChatBubble(
                        isRight: typingMessage?.senderType == "right",
                      );
                    },
                  ),
                ),
                GlassBottomBar(onTap: showNextMessage),
              ],
            ),
    );
  }
}
