import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class _Message {
  final String text;
  final bool isUser;

  const _Message({required this.text, required this.isUser});
}

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() =>
      _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Message> _messages = [
    const _Message(
      text:
          'Hello! I\'m your dairy assistant. Ask me about your deliveries, pending payments, or business insights.',
      isUser: false,
    ),
  ];
  bool _isThinking = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _isThinking = true;
    });
    _scrollToBottom();

    final response = await _getResponse(text);

    setState(() {
      _isThinking = false;
      _messages.add(_Message(text: response, isUser: false));
    });
    _scrollToBottom();
  }

  Future<String> _getResponse(String question) async {
    final q = question.toLowerCase();
    try {
      if (q.contains('payment') ||
          q.contains('pending') ||
          q.contains('due')) {
        final res = await SupabaseService.client
            .from('bills')
            .select('amount_due')
            .eq('vendor_id', SupabaseService.currentUserId ?? '')
            .eq('is_paid', false);
        double total = 0;
        for (final b in (res as List)) {
          total += (b['amount_due'] as num).toDouble();
        }
        return 'You have ₹${total.toStringAsFixed(0)} in pending payments from ${(res as List).length} customers.';
      } else if (q.contains('customer') || q.contains('active')) {
        final res = await SupabaseService.client
            .from('customers')
            .select('id')
            .eq('vendor_id', SupabaseService.currentUserId ?? '')
            .eq('is_active', true);
        return 'You currently have ${(res as List).length} active customers.';
      } else if (q.contains('delivery') || q.contains('today')) {
        final today = DateTime.now().toIso8601String().split('T')[0];
        final res = await SupabaseService.client
            .from('deliveries')
            .select('id, is_delivered')
            .eq('vendor_id', SupabaseService.currentUserId ?? '')
            .eq('delivery_date', today);
        final total = (res as List).length;
        final done = (res).where((d) => d['is_delivered'] == true).length;
        return "Today you have $total deliveries. $done completed, ${total - done} remaining.";
      } else if (q.contains('revenue') || q.contains('income')) {
        final firstOfMonth = DateTime(
                DateTime.now().year, DateTime.now().month, 1)
            .toIso8601String()
            .split('T')[0];
        final res = await SupabaseService.client
            .from('deliveries')
            .select('total_amount')
            .eq('vendor_id', SupabaseService.currentUserId ?? '')
            .gte('delivery_date', firstOfMonth);
        double total = 0;
        for (final d in (res as List)) {
          total += (d['total_amount'] as num).toDouble();
        }
        return 'This month\'s revenue so far is ₹${total.toStringAsFixed(0)}.';
      } else {
        return 'I can help you with pending payments, customer count, today\'s deliveries, and monthly revenue. What would you like to know?';
      }
    } catch (e) {
      return 'I could not fetch that information. Please check your connection.';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  color: AppColors.secondary, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('AI Assistant'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (context, i) {
                if (_isThinking && i == _messages.length) {
                  return const _TypingIndicator();
                }
                final msg = _messages[i];
                return _MessageBubble(message: msg);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border:
                  const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask about your business...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  onPressed: _isThinking
                      ? null
                      : () => _sendMessage(_controller.text),
                  icon: Icon(
                    Icons.send_rounded,
                    color: _isThinking
                        ? AppColors.textTertiary
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
          border: message.isUser
              ? null
              : Border.all(color: AppColors.border),
        ),
        child: Text(
          message.text,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: message.isUser
                ? AppColors.surface
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 8,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.border,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
