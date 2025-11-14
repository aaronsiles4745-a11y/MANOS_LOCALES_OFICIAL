import 'package:flutter/material.dart';
import '../screens/discover_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/home_dashboard_screen.dart';
import '../models/user_model.dart';

// ===================ss==== MODELO DE CONTACTO =======================
class UserModel {
  final String userId;
  final String name;
  final String photoUrl;
  final String bio;

  UserModel({
    required this.userId,
    required this.name,
    required this.photoUrl,
    required this.bio,
  });
}

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
      title: 'Simulador Chat',
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
  late List<UserModel> _contactos;
  int _selectedIndex = 1;
  @override
  void initState() {
    super.initState();
    _contactos = _crearContactosFake();
  }

  List<UserModel> _crearContactosFake() {
    return [
      UserModel(userId: "1", name: "Juan", photoUrl: "", bio: "Cortar pasto"),
      UserModel(userId: "2", name: "María", photoUrl: "", bio: "Arreglar casa"),
      UserModel(
          userId: "3", name: "Pedro", photoUrl: "", bio: "Pintar paredes"),
      UserModel(userId: "4", name: "Lucía", photoUrl: "", bio: "Mudanzas"),
      UserModel(
          userId: "5",
          name: "Carlos",
          photoUrl: "",
          bio: "Reparar computadoras"),
      UserModel(
          userId: "6", name: "Ana", photoUrl: "", bio: "Limpieza de casas"),
    ];
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
                Expanded(
                  child: ListView.builder(
                    itemCount: _contactos.length,
                    itemBuilder: (context, index) {
                      final contacto = _contactos[index];
                      return Card(
                        color: const Color(0xFF1B263B).withOpacity(0.8),
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: contacto.photoUrl.isEmpty
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(contacto.name,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text(contacto.bio,
                              style: const TextStyle(color: Colors.white70)),
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
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // NAV BAR CON ICONOS MASCULINOS
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

        // Navegación según el índice tocado
        switch (index) {
          case 0: // Inicio
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
            );
            break;

          case 1: // Chat
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatContactoScreen()),
            );

            break;

          case 2: // Buscar (Discover)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DiscoverScreen()),
            );
            break;

          case 3: // Perfil
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
  final UserModel contact; // contacto seleccionado

  const ChatScreen({super.key, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Mensajes iniciales simulando coordinación
    _messages.addAll([
      {
        "text":
            "Hola, me gustaría contratarte para ${widget.contact.bio.toLowerCase()}.",
        "isMe": false
      },
      {
        "text": "Hola! Sí, puedo ayudarte. ¿Cuándo quieres hacerlo?",
        "isMe": true
      },
    ]);
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"text": _controller.text.trim(), "isMe": true});
      _controller.clear();
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
                        child: widget.contact.photoUrl.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(widget.contact.name,
                          style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Divider(color: Colors.white54, height: 1),
                // Chat
                Expanded(
                  child: ListView.builder(
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
                          child: Text(
                            msg["text"],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Caja de mensaje
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Mensaje...",
                            hintStyle: const TextStyle(color: Colors.white60),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send,
                            color: Colors.lightBlueAccent),
                        onPressed: _send,
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
}
