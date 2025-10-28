import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepository {
  final SupabaseClient client;
  ChatRepository(this.client);

  Future<void> sendMessage({required String chatId, required String senderRole, required String text, bool isConfirmation = false}) async {
    await client.from('messages').insert({
      'chat_id': chatId,
      'sender_role': senderRole,
      'text': text,
      'is_confirmation': isConfirmation,
    });
  }

  Stream<List<Map<String, dynamic>>> subscribeMessages(String chatId) {
    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at')
        .map((rows) => rows);
  }
}


