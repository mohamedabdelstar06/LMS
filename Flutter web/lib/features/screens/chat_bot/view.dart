import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/chat_bot/state_managments/chat_cubit.dart';
import 'package:lms/features/screens/chat_bot/state_managments/chat_state.dart';
import 'package:lms/features/screens/chat_bot/state_managments/chat_model.dart';

class LearnMateChat extends StatefulWidget {
  const LearnMateChat({super.key});

  @override
  State<LearnMateChat> createState() => _LearnMateChatState();
}

class _LearnMateChatState extends State<LearnMateChat> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _sidebarExpanded = true;
  bool _isSearching = false;
  String _searchQuery = '';


  String? _pendingConfirm;

  @override
  void dispose() {
    _inputController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    context.read<ChatCubit>().sendMessage(text);
    _scrollToBottom();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

 

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(child: _buildChatArea()),
      ],
    );
  }

 

  Widget _buildSidebar() {
    final w = _sidebarExpanded ? 220.0 : 56.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      width: w,
      color: const Color(0xFFDEECFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebarHeader(),
          const SizedBox(height: 8),
          _buildSidebarNav(),
          if (_sidebarExpanded) ...[
            const SizedBox(height: 12),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _isSearching
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: _buildSearchField(),
              secondChild: const SizedBox(height: 0),
            ),
            if (_isSearching) const SizedBox(height: 8),
            _buildHistoryPanel(),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 4, 0),
      child: Row(
        children: [
          if (_sidebarExpanded)
            const Expanded(
              child: Text(
                'Mofeed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A237E),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              _sidebarExpanded
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: Colors.blueGrey,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _sidebarExpanded = !_sidebarExpanded),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNav() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _sidebarExpanded ? 10 : 6),
      child: Column(
        children: [
        
          _buildActionTile(
            icon: Icons.add_circle_outline_rounded,
            label: 'New Chat',
            color: const Color(0xFF1565C0),
            onTap: () => setState(() => _pendingConfirm = 'new'),
          ),
          const SizedBox(height: 3),
   
          _buildActionTile(
            icon: Icons.search_rounded,
            label: 'Search',
            color: _isSearching
                ? const Color(0xFF1565C0)
                : Colors.blueGrey.shade600,
            isActive: _isSearching,
            onTap: _toggleSearch,
          ),
          const SizedBox(height: 3),
      
          _buildActionTile(
            icon: Icons.history_rounded,
            label: 'History',
            color: Colors.blueGrey.shade600,
            onTap: () => context.read<ChatCubit>().loadChatHistory(),
          ),
          const SizedBox(height: 3),
       
          _buildActionTile(
            icon: Icons.delete_outline_rounded,
            label: 'Clear All',
            color: Colors.red.shade400,
            onTap: () => setState(() => _pendingConfirm = 'clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _sidebarExpanded ? 12 : 14,
              vertical: 9,
            ),
            child: Row(
              mainAxisAlignment: _sidebarExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: _searchController,
        
        autofocus: false,
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search messages…',
          hintStyle: TextStyle(fontSize: 12, color: Colors.blueGrey.shade400),
          prefixIcon: Icon(
            Icons.search,
            size: 16,
            color: Colors.blueGrey.shade400,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.blueGrey.shade400,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return Expanded(
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          List<ChatMessage> messages = [];

          if (state is ChatLoaded) {
            messages = state.messages.where((m) => m.isUser).toList();

            if (_searchQuery.isNotEmpty) {
              messages = messages
                  .where((m) => m.content.toLowerCase().contains(_searchQuery))
                  .toList();
            }

            messages = messages.reversed.toList();
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isSearching && _searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${messages.length} result${messages.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'History',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isNotEmpty
                                ? 'No results for "$_searchQuery"'
                                : 'No chats yet',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey.shade400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          itemCount: messages.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 2),
                          itemBuilder: (_, i) => _buildHistoryTile(messages[i]),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTile(ChatMessage msg) {
    
    final query = _searchQuery;
    final text = msg.content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: _scrollToBottom,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 12,
                color: Colors.blue.shade300,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    query.isNotEmpty
                        ? _buildHighlightedText(text, query)
                        : Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blueGrey.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                    if (msg.timestamp != null)
                      Text(
                        _formatTime(msg.timestamp!),
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    final lowerText = text.toLowerCase();
    final idx = lowerText.indexOf(query);
    if (idx == -1) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade800),
      );
    }
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade800),
        children: [
          if (idx > 0) TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: TextStyle(
              backgroundColor: Colors.yellow.shade300,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey.shade900,
            ),
          ),
          if (idx + query.length < text.length)
            TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  

  Widget _buildChatArea() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (!mounted) return;
          if (state is ChatLoaded) _scrollToBottom();
        },
        builder: (context, state) {
          return Column(
            children: [
              
              if (_pendingConfirm != null)
                _buildConfirmBanner(_pendingConfirm!),

              if (state is ChatLoaded && state.errorMessage != null)
                _buildErrorBanner(state.errorMessage!),
              Expanded(
                child: () {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ChatError) {
                    return _buildFullError(state.message);
                  }
                  if (state is ChatLoaded && state.messages.isNotEmpty) {
                    return _buildMessageList(state.messages);
                  }
                  return _buildWelcomeScreen();
                }(),
              ),
              if (state is ChatLoaded && state.isSending)
                _buildTypingIndicator(),
              _buildInputBar(disabled: state is ChatLoaded && state.isSending),
            ],
          );
        },
      ),
    );
  }

  

  Widget _buildConfirmBanner(String type) {
    final isNew = type == 'new';
    final color = isNew ? const Color(0xFF1565C0) : Colors.red.shade600;
    final bgColor = isNew ? Colors.blue.shade50 : Colors.red.shade50;
    final icon = isNew
        ? Icons.add_circle_outline_rounded
        : Icons.delete_outline_rounded;
    final title = isNew ? 'Start a new chat?' : 'Delete all history?';
    final subtitle = isNew
        ? 'Current chat will be saved.'
        : 'This cannot be undone.';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: color.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => setState(() => _pendingConfirm = null),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
            ),
          ),
          const SizedBox(width: 4),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () {
              setState(() => _pendingConfirm = null);
              if (isNew) {
                context.read<ChatCubit>().newSession();
              } else {
                context.read<ChatCubit>().clearChat();
              }
            },
            child: Text(
              isNew ? 'New Chat' : 'Delete',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Material(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 14, color: Colors.red.shade400),
              onPressed: () => context.read<ChatCubit>().dismissError(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 40, color: Colors.red.shade300),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade400, fontSize: 13),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => context.read<ChatCubit>().loadChatHistory(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/chatbot image.png', width: 64, height: 64),
          const SizedBox(height: 16),
          const Text(
            'Welcome! 👋',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about your courses.',
            style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade500),
          ),
          const SizedBox(height: 24),
          _buildSuggestionChips(),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    const suggestions = [
      '📚 Show my progress',
      '📝 Upcoming quizzes',
      '🗓️ Assignment deadlines',
      '💡 Study tips',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((s) {
        return ActionChip(
          label: Text(s, style: const TextStyle(fontSize: 12)),
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.blue.shade200),
          onPressed: () {
            _inputController.text = s.replaceAll(
              RegExp(r'^[^\w\u0600-\u06FF]+'),
              '',
            );
            _sendMessage();
          },
        );
      }).toList(),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    return RefreshIndicator(
      onRefresh: () => context.read<ChatCubit>().loadChatHistory(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final showDate =
              index == 0 ||
              !_sameDay(
                messages[index - 1].timestamp ?? DateTime.now(),
                msg.timestamp ?? DateTime.now(),
              );
          return Column(
            children: [
              if (showDate && msg.timestamp != null)
                _buildDateDivider(msg.timestamp!),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: msg.isUser
                    ? _buildUserBubble(msg)
                    : _buildAssistantBubble(msg),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDateDivider(DateTime dt) {
    final label =
        '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.blueGrey.shade100)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.blueGrey.shade400),
            ),
          ),
          Expanded(child: Divider(color: Colors.blueGrey.shade100)),
        ],
      ),
    );
  }

  Widget _buildAssistantBubble(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: const AssetImage(
              'assets/images/chatbot image.png',
            ),
            radius: 18,
            backgroundColor: Colors.blue.shade100,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: msg.content.isEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 14,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Empty response',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade300,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      msg.content,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.blueGrey.shade800,
                        height: 1.55,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBubble(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade700],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                msg.content,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Colors.white,
                  height: 1.55,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundImage: const AssetImage('assets/images/chatbot man.png'),
            radius: 18,
            backgroundColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: const AssetImage(
                'assets/images/chatbot image.png',
              ),
              radius: 16,
              backgroundColor: Colors.blue.shade100,
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const _TypingDots(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar({required bool disabled}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                onSubmitted: disabled ? null : (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
                maxLines: null,
                enabled: !disabled,
                decoration: InputDecoration(
                  hintText: 'Ask anything…',
                  hintStyle: TextStyle(
                    color: Colors.blueGrey.shade300,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: disabled ? null : _sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: disabled
                      ? Colors.blueGrey.shade200
                      : Colors.blueGrey.shade900,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_ctrl.value - i * 0.18).clamp(0.0, 1.0);
            final scale = 0.6 + 0.4 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7 * scale,
              height: 7 * scale,
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
