import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../theme/app_colors.dart';

class ChatWidget extends StatefulWidget {
  final bool isNightChat;
  final bool canAccessNightChat;

  const ChatWidget({
    super.key,
    this.isNightChat = false,
    this.canAccessNightChat = false,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent) {
      if (widget.isNightChat) {
        context.read<ChatProvider>().loadMoreNightMessages();
      } else {
        context.read<ChatProvider>().loadMoreGameMessages();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (widget.isNightChat && !widget.canAccessNightChat) {
          return const SizedBox.shrink();
        }

        final messages = widget.isNightChat
            ? chatProvider.getNightMessages(chatProvider.currentGameId ?? '')
            : chatProvider.getGameMessages(chatProvider.currentGameId ?? '');

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkContrast
                : AppColors.lightContrast,
            border: Border.all(
              color: widget.isNightChat
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.isNightChat ? 'Night Chat' : 'Game Chat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isNightChat
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  reverse: true,
                  itemCount: messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return widget.isNightChat
                          ? chatProvider.isLoadingNightMessages
                              ? const Center(child: CircularProgressIndicator())
                              : chatProvider.hasMoreNightMessages
                                  ? const SizedBox(height: 50)
                                  : const SizedBox()
                          : chatProvider.isLoadingGameMessages
                              ? const Center(child: CircularProgressIndicator())
                              : chatProvider.hasMoreGameMessages
                                  ? const SizedBox(height: 50)
                                  : const SizedBox();
                    }
                    final message = messages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.senderName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (widget.isNightChat
                                  ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.darkBackground
                                      : AppColors.lightBackground
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.darkContrast
                                      : AppColors.lightContrast),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkBackground
                                  : AppColors.lightBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            chatProvider.sendMessage(
                              value,
                              isNightChat: widget.isNightChat,
                            );
                            _messageController.clear();
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              _scrollToBottom,
                            );
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          chatProvider.sendMessage(
                            _messageController.text,
                            isNightChat: widget.isNightChat,
                          );
                          _messageController.clear();
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            _scrollToBottom,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
