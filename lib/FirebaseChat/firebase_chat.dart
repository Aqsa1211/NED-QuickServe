import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseChat {
  FirebaseFirestore db = FirebaseFirestore.instance;

  // Collection references
  late CollectionReference chats = db.collection('Chats');
  late CollectionReference lastChat = db.collection('LastChats');
  late CollectionReference users = db.collection('Users'); // Users collection

  /// Creates a new user in the Firestore `Users` collection.
  Future<void> createUser({
    required String user_id,
    required String name,
    required String image,
  }) async {
    await users.doc(user_id).set({
      "user_id": user_id,
      "name": name,
      "image": image,
      "created_at": DateTime.now().millisecondsSinceEpoch, // Timestamp
    });
  }

  /// Creates a new chat message in Firestore.
  Future<void> createChat({
    required String chat_id,
    required String sender_id,
    required String reciever_id,
    required String msg,
    required String type,
  }) async {
    final userChats = chats.doc(chat_id).collection('user_chats');

    await userChats.add({
      "sender": sender_id,
      "receiver": reciever_id,
      "msg": msg,
      "time": DateTime.now().millisecondsSinceEpoch, // System time
      "type": type,
    });

    await _updateLastChat(
      chat_id: chat_id,
      sender_id: sender_id,
      reciever_id: reciever_id,
      msg: msg,
    );
  }

  /// Updates the last chat data for both sender and receiver in Firestore.
  Future<void> _updateLastChat({
    required String chat_id,
    required String sender_id,
    required String reciever_id,
    required String msg,
  }) async {
    await lastChat.doc(sender_id).collection("chats").doc(reciever_id).set({
      "chat_id": chat_id,
      "msg": msg,
      "doc_id": reciever_id,
      "time": DateTime.now().millisecondsSinceEpoch, // System time
    });

    await lastChat.doc(reciever_id).collection("chats").doc(sender_id).set({
      "chat_id": chat_id,
      "msg": msg,
      "doc_id": sender_id,
      "time": DateTime.now().millisecondsSinceEpoch, // System time
    });
  }
}
