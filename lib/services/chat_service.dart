import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============== OBTENER CHATS DEL USUARIO ==============
  Stream<QuerySnapshot> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  // ============== OBTENER MENSAJES DE UN CHAT ==============
  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // ============== ENVIAR MENSAJE ==============
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required String senderName,
  }) async {
    try {
      final messageData = {
        'text': text,
        'senderId': senderId,
        'senderName': senderName,
        'timestamp': Timestamp.now(),
        'type': 'text',
        'read': false,
      };

      // 1. Agregar mensaje a la subcolección
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);

      // 2. Actualizar último mensaje en el chat
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageAt': Timestamp.now(),
        'lastSenderId': senderId,
      });
    } catch (e) {
      throw 'Error al enviar mensaje: $e';
    }
  }

  // ============== CREAR NUEVO CHAT ==============
  Future<String> createChat({
    required String user1Id,
    required String user2Id,
    required String user1Name,
    required String user2Name,
    String user1PhotoUrl = '',
    String user2PhotoUrl = '',
  }) async {
    try {
      // Crear ID único para el chat
      final participants = [user1Id, user2Id]..sort();
      final chatId = participants.join('_');

      final chatData = {
        'chatId': chatId,
        'participants': participants,
        'participantNames': {
          user1Id: user1Name,
          user2Id: user2Name,
        },
        'participantPhotos': {
          user1Id: user1PhotoUrl,
          user2Id: user2PhotoUrl,
        },
        'lastMessage': '',
        'lastMessageAt': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'status': 'active',
      };

      // Verificar si el chat ya existe
      final existingChat =
          await _firestore.collection('chats').doc(chatId).get();

      if (!existingChat.exists) {
        await _firestore.collection('chats').doc(chatId).set(chatData);
      }

      return chatId;
    } catch (e) {
      throw 'Error al crear chat: $e';
    }
  }

  // ============== OBTENER O CREAR CHAT ==============
  Future<String> getOrCreateChat({
    required String currentUserId,
    required String contactId,
    required String currentUserName,
    required String contactName,
    String currentUserPhotoUrl = '',
    String contactPhotoUrl = '',
  }) async {
    try {
      final participants = [currentUserId, contactId]..sort();
      final chatId = participants.join('_');

      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        await createChat(
          user1Id: currentUserId,
          user2Id: contactId,
          user1Name: currentUserName,
          user2Name: contactName,
          user1PhotoUrl: currentUserPhotoUrl,
          user2PhotoUrl: contactPhotoUrl,
        );
      }

      return chatId;
    } catch (e) {
      throw 'Error al obtener/crear chat: $e';
    }
  }

  // ============== MARCAR MENSAJES COMO LEÍDOS ==============
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marcando mensajes como leídos: $e');
    }
  }

  // ============== ELIMINAR CHAT ==============
  Future<void> deleteChat(String chatId) async {
    try {
      // Primero eliminar todos los mensajes
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Luego eliminar el chat
      await _firestore.collection('chats').doc(chatId).delete();
    } catch (e) {
      throw 'Error al eliminar chat: $e';
    }
  }
}
