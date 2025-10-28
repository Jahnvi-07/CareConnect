import 'dart:collection';

class ChatMessage {
  final String id;
  final String senderRole; // 'user' or 'org'
  final String text;
  final DateTime timestamp;
  final bool isConfirmation; // true if org confirms payment

  ChatMessage({
    required this.id,
    required this.senderRole,
    required this.text,
    required this.timestamp,
    this.isConfirmation = false,
  });
}

class ChatThread {
  final String orgName;
  final List<ChatMessage> messages;
  bool isPaymentConfirmed;

  ChatThread({required this.orgName})
      : messages = [],
        isPaymentConfirmed = false;
}

class InMemoryChatStore {
  static final Map<String, ChatThread> _threadsByOrg = HashMap();

  static ChatThread getThread(String orgName) {
    return _threadsByOrg.putIfAbsent(orgName, () => ChatThread(orgName: orgName));
  }

  static void addMessage(String orgName, ChatMessage message) {
    final thread = getThread(orgName);
    thread.messages.add(message);
    if (message.isConfirmation) {
      thread.isPaymentConfirmed = true;
    }
  }
}


