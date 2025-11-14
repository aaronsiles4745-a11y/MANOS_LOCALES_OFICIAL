import 'package:flutter/material.dart';
import 'package:manos_locales/services/user_service.dart';
import 'package:manos_locales/models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimuladorApp();
  }
}

class SimuladorApp extends StatelessWidget {
  const SimuladorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simulador',
      home: ChatContactoScreen(),
    );
  }
}

// ===================== PANTALLA DE LISTA DE CONTACTOS =====================
class ChatContactoScreen extends StatefulWidget {
  const ChatContactoScreen({super.key});

  @override
  State<ChatContactoScreen> createState() => _ChatContactoScreenState();
}

class _ChatContactoScreenState extends State<ChatContactoScreen> {
  final UserService _userService = UserService();
  List<UserModel> _contactos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarContactos();
  }

  Future<void> _cargarContactos() async {
    try {
      final usuarios = await _userService.getUsersByRole('provider');
      setState(() {
        _contactos = usuarios;
        _cargando = false;
      });
    } catch (e) {
      print('Error al cargar contactos: $e');
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'manos_locales\assets\images\background_pattern.png',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: const Color.fromARGB(94, 33, 86, 244),
          appBar: AppBar(
            title: const Text('Chat'),
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
            elevation: 0,
          ),
          body: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _contactos.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay contactos disponibles',
                        style: TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _contactos.length,
                      itemBuilder: (context, index) {
                        final contacto = _contactos[index];
                        return Card(
                          color: const Color(0xFF1B263B).withOpacity(0.8),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple,
                              backgroundImage: contacto.photoUrl.isNotEmpty
                                  ? NetworkImage(contacto.photoUrl)
                                  : null,
                              child: contacto.photoUrl.isEmpty
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null,
                            ),
                            title: Text(
                              contacto.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              contacto.bio.isNotEmpty
                                  ? contacto.bio
                                  : 'Sin mensaje',
                              style: const TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: contacto.ratingAvg > 0
                                ? Text(
                                    '⭐ ${contacto.ratingAvg}',
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(179, 255, 255, 255)),
                                  )
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatScreen(userId: contacto.userId),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: const Color(0xFF1B263B).withOpacity(0.8),
            selectedItemColor: const Color.fromARGB(255, 254, 254, 254),
            unselectedItemColor: Colors.white70,
            currentIndex: 1,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Buscar'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: 'Alertas'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Perfil'),
            ],
            onTap: (index) {
              // Navegación entre pantallas (a implementar)
            },
          ),
        ),
      ],
    );
  }
}

// ===================== PANTALLA DE CHAT =====================
class ChatScreen extends StatefulWidget {
  final String userId;

  const ChatScreen({super.key, required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hola, cuando podría pasar para hacer el trabajo.',
      'isMe': false,
    },
    {
      'text': 'Hola, podría ser este martes, la dirección es Mar arabigo 1489.',
      'isMe': true,
    },
  ];

  final UserService _userService = UserService();
  UserModel? _usuario;
  bool _cargandoUsuario = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    try {
      final user = await _userService.getUserById(widget.userId);
      setState(() {
        _usuario = user;
        _cargandoUsuario = false;
      });
    } catch (e) {
      print('Error al obtener usuario: $e');
      setState(() => _cargandoUsuario = false);
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'text': _controller.text.trim(), 'isMe': true});
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00134E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00134E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _cargandoUsuario
            ? const Text('Cargando...', style: TextStyle(color: Colors.white))
            : Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    backgroundImage: _usuario?.photoUrl.isNotEmpty == true
                        ? NetworkImage(_usuario!.photoUrl)
                        : null,
                    child: _usuario?.photoUrl.isEmpty == true
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _usuario?.name ?? 'Usuario',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'] as bool;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF6C63FF).withOpacity(0.2)
                          : Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00134E),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Mensaje',
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(137, 234, 232, 232)),
                      filled: true,
                      fillColor: const Color(0xFF001B80),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.purple),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
