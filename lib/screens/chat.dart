import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/discover_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/home_dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ¡Nueva importación!
import '../models/user_model.dart';
import '../services/chat_service.dart';

// ======================= INICIO DE LA APP =======================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat Real',
      home: HomeDashboardScreen(),
    );
  }
}

// ======================= HOME =======================
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background_pattern.png',
              fit: BoxFit.cover,
            ),
          ),
          // Degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text("Ir a Chat"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChatContactoScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= LISTA DE CONTACTOS =======================
class ChatContactoScreen extends StatefulWidget {
  const ChatContactoScreen({super.key});

  @override
  State<ChatContactoScreen> createState() => _ChatContactoScreenState();
}

class _ChatContactoScreenState extends State<ChatContactoScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late List<UserModel> _contactos;
  List<Map<String, dynamic>> _chatsReales = [];
  int _selectedIndex = 1;
  bool _cargandoChats = true;

  @override
  void initState() {
    super.initState();
    _contactos = _crearContactosDemo();
    _cargarChatsReales();
  }

  // ✅ MANTENER CONTACTOS DEMO COMO FALLBACK
  List<UserModel> _crearContactosDemo() {
    return [
      UserModel(
        userId: "user_demo_1",
        name: "Juan Pérez",
        photoUrl: "",
        bio: "Especialista en plomería y reparaciones del hogar",
        email: "juan@demo.com",
        phone: "+549112345678",
        createdAt: DateTime.now(),
      ),
      UserModel(
        userId: "user_demo_2",
        name: "María González",
        photoUrl: "",
        bio: "Experta en limpieza y organización de espacios",
        email: "maria@demo.com",
        phone: "+549119876543",
        createdAt: DateTime.now(),
      ),
      UserModel(
        userId: "user_demo_3",
        name: "Carlos Rodríguez",
        photoUrl: "",
        bio: "Electricista certificado con 10 años de experiencia",
        email: "carlos@demo.com",
        phone: "+549113456789",
        createdAt: DateTime.now(),
      ),
    ];
  }

  // ✅ CARGAR CHATS REALES DESDE FIREBASE
  void _cargarChatsReales() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() => _cargandoChats = false);
      return;
    }

    _chatService.getUserChats(currentUser.uid).listen((chatsSnapshot) {
      final chats = chatsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final participants = List<String>.from(data['participants'] ?? []);
        final participantNames =
            Map<String, String>.from(data['participantNames'] ?? {});
        final participantPhotos =
            Map<String, String>.from(data['participantPhotos'] ?? {});

        // Encontrar el otro participante
        final otherUserId = participants.firstWhere(
          (id) => id != currentUser.uid,
          orElse: () => '',
        );

        return {
          'chatId': doc.id,
          'otherUserId': otherUserId,
          'otherUserName': participantNames[otherUserId] ?? 'Usuario',
          'otherUserPhotoUrl': participantPhotos[otherUserId] ?? '',
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageAt': data['lastMessageAt'],
        };
      }).toList();

      setState(() {
        _chatsReales = chats;
        _cargandoChats = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo y degradado igual que Home
          SizedBox.expand(
            child: Image.asset('assets/images/background_pattern.png',
                fit: BoxFit.cover),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Contactos",
                  style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (_cargandoChats)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                        color: Colors.lightBlueAccent),
                  )
                else
                  Expanded(
                    child: ListView(
                      children: [
                        // ✅ CHATS REALES (SI EXISTEN)
                        if (_chatsReales.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              "Chats activos",
                              style: TextStyle(
                                color: Colors.lightBlueAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ..._chatsReales
                              .map((chat) => _buildChatRealItem(chat)),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              "Contactos disponibles",
                              style: TextStyle(
                                color: Colors.lightBlueAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],

                        // ✅ CONTACTOS DEMO (SIEMPRE DISPONIBLES)
                        ..._contactos.map(
                            (contacto) => _buildContactoDemoItem(contacto)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _buildChatRealItem(Map<String, dynamic> chat) {
    return Card(
      color: const Color(0xFF1B263B).withOpacity(0.8),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[800],
          child: chat['otherUserPhotoUrl']?.isNotEmpty == true
              ? ClipOval(
                  child: Image.network(
                    chat['otherUserPhotoUrl'],
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                )
              : const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(chat['otherUserName'],
            style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          chat['lastMessage']?.isNotEmpty == true
              ? chat['lastMessage']
              : "Iniciar conversación",
          style: const TextStyle(color: Colors.white70),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          final contacto = UserModel(
            userId: chat['otherUserId'],
            name: chat['otherUserName'],
            photoUrl: chat['otherUserPhotoUrl'] ?? '',
            bio: '',
            email: '',
            phone: '',
            createdAt: DateTime.now(),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChatScreen(contact: contacto, chatId: chat['chatId']),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactoDemoItem(UserModel contacto) {
    return Card(
      color: const Color(0xFF1B263B).withOpacity(0.8),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[800],
          child: contacto.photoUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    contacto.photoUrl,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                )
              : const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(contacto.name, style: const TextStyle(color: Colors.white)),
        subtitle:
            Text(contacto.bio, style: const TextStyle(color: Colors.white70)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(contact: contacto),
            ),
          );
        },
      ),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0D1B2A),
      selectedItemColor: Colors.lightBlueAccent,
      unselectedItemColor: Colors.white70,
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
            );
            break;
          case 1:
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DiscoverScreen()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: "Perfil"),
      ],
    );
  }
}

// ======================= CHAT INDIVIDUAL =======================
class ChatScreen extends StatefulWidget {
  final UserModel contact;
  final String? chatId;

  const ChatScreen({super.key, required this.contact, this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentChatId;
  List<Map<String, dynamic>> _messages = [];
  bool _cargandoMensajes = true;

  @override
  void initState() {
    super.initState();
    _inicializarChat();
  }

  Future<void> _inicializarChat() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _cargarMensajesDemo();
      return;
    }

    try {
      // ✅ USAR CHAT EXISTENTE O CREAR UNO NUEVO
      _currentChatId = widget.chatId ??
          await _chatService.getOrCreateChat(
            currentUserId: currentUser.uid,
            contactId: widget.contact.userId,
            currentUserName: currentUser.displayName ?? 'Usuario',
            contactName: widget.contact.name,
            currentUserPhotoUrl: currentUser.photoURL ?? '',
            contactPhotoUrl: widget.contact.photoUrl,
          );

      // ✅ CARGAR MENSAJES REALES EN TIEMPO REAL
      _cargarMensajesReales();
    } catch (e) {
      print("❌ Error inicializando chat: $e");
      _cargarMensajesDemo();
    }
  }

  void _cargarMensajesReales() {
    if (_currentChatId == null) {
      _cargarMensajesDemo();
      return;
    }

    _chatService.getChatMessages(_currentChatId!).listen((messagesSnapshot) {
      final mensajes = messagesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final currentUser = _auth.currentUser;
        final isMe = data['senderId'] == currentUser?.uid;

        return {
          'id': doc.id,
          'text': data['text'] ?? '',
          'isMe': isMe,
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
          'senderName': data['senderName'] ?? 'Usuario',
          'read': data['read'] ?? false,
        };
      }).toList();

      setState(() {
        _messages = mensajes;
        _cargandoMensajes = false;
      });

      // ✅ MARCAR MENSAJES COMO LEÍDOS
      _chatService.markMessagesAsRead(_currentChatId!, _auth.currentUser!.uid);
    });
  }

  void _cargarMensajesDemo() {
    // ✅ MANTENER MENSAJES DEMO COMO FALLBACK
    setState(() {
      _messages = [
        {
          "text":
              "Hola, me gustaría contratarte para ${widget.contact.bio.toLowerCase()}.",
          "isMe": false,
          "timestamp": DateTime.now().subtract(const Duration(minutes: 5)),
          "senderName": widget.contact.name,
          "read": true,
        },
        {
          "text": "Hola! Sí, puedo ayudarte. ¿Cuándo quieres hacerlo?",
          "isMe": true,
          "timestamp": DateTime.now().subtract(const Duration(minutes: 4)),
          "senderName": "Tú",
          "read": true,
        },
      ];
      _cargandoMensajes = false;
    });
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // ✅ AGREGAR MENSAJE LOCAL SI NO HAY USUARIO AUTENTICADO
      _agregarMensajeLocal(_controller.text.trim(), true);
      _controller.clear();
      return;
    }

    if (_currentChatId == null) {
      await _inicializarChat();
    }

    try {
      // ✅ ENVIAR MENSAJE REAL A FIREBASE
      await _chatService.sendMessage(
        chatId: _currentChatId!,
        text: _controller.text.trim(),
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? 'Usuario',
      );
      _controller.clear();
    } catch (e) {
      print("❌ Error enviando mensaje: $e");
      // ✅ FALLBACK: AGREGAR MENSAJE LOCAL
      _agregarMensajeLocal(_controller.text.trim(), true);
      _controller.clear();
    }
  }

  void _agregarMensajeLocal(String text, bool isMe) {
    setState(() {
      _messages.add({
        "text": text,
        "isMe": isMe,
        "timestamp": DateTime.now(),
        "senderName": isMe ? "Tú" : widget.contact.name,
        "read": true,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo igual que Home
          SizedBox.expand(
            child: Image.asset('assets/images/background_pattern.png',
                fit: BoxFit.cover),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar simulado
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue[800],
                        child: widget.contact.photoUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  widget.contact.photoUrl,
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                ),
                              )
                            : const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.contact.name,
                              style: const TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          Text(widget.contact.bio,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white54, height: 1),

                // ✅ CHAT - MANTIENE EXACTAMENTE LA MISMA UI
                Expanded(
                  child: _cargandoMensajes
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.lightBlueAccent))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            return Align(
                              alignment: msg["isMe"]
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: msg["isMe"]
                                      ? Colors.lightBlueAccent.withOpacity(0.6)
                                      : Colors.blueGrey.shade700,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg["text"],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(msg["timestamp"]),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // ✅ CAJA DE MENSAJE - MANTIENE EXACTAMENTE LA MISMA UI
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Escribe un mensaje...",
                            hintStyle: const TextStyle(color: Colors.white60),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send,
                            color: Colors.lightBlueAccent),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }
}
