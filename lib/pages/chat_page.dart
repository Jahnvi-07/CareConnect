import 'package:flutter/material.dart';
import '../utils/chat_store.dart';
import '../utils/constants.dart';
import '../utils/session.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String orgName = ModalRoute.of(context)!.settings.arguments as String;
    final thread = InMemoryChatStore.getThread(orgName);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat • $orgName'),
        backgroundColor: kPrimary,
        actions: [
          if (Session.currentRole == 'org' && !thread.isPaymentConfirmed)
            IconButton(
              tooltip: 'Confirm payment',
              icon: const Icon(Icons.verified),
              onPressed: () {
                InMemoryChatStore.addMessage(
                  orgName,
                  ChatMessage(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    senderRole: 'org',
                    text: 'Payment confirmed. Thank you!',
                    timestamp: DateTime.now(),
                    isConfirmation: true,
                  ),
                );
                setState(() {});
              },
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              reverse: true,
              itemCount: thread.messages.length,
              itemBuilder: (_, index) {
                final msg = thread.messages[thread.messages.length - 1 - index];
                final isMine = msg.senderRole == Session.currentRole;
                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMine ? kPrimary.withOpacity(0.12) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.isConfirmation)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.verified, size: 16, color: Colors.green),
                              SizedBox(width: 6),
                              Text('Payment confirmed', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        if (msg.isConfirmation) const SizedBox(height: 4),
                        Text(msg.text),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Type a message...'),
                      onSubmitted: (_) => _send(orgName),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _send(orgName),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _send(String orgName) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    InMemoryChatStore.addMessage(
      orgName,
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderRole: Session.currentRole,
        text: text,
        timestamp: DateTime.now(),
      ),
    );
    _controller.clear();
    setState(() {});
  }
}


