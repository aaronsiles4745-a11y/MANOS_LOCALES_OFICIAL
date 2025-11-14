import 'package:flutter/material.dart';
import 'package:manos_locales/app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/service_service.dart';
import '../models/user_model.dart';
import '../models/service_model.dart';



class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final _userService = UserService();
  final _serviceService = ServiceService();
  
  UserModel? _currentUser;
  List<ServiceModel> _myServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Usamos Firebase directamente para evitar posibles problemas con el provider
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // DEBUG 1: ver si hay uid
      print("DEBUG: UID Firebase -> $userId");

      if (userId == null) {
        print("DEBUG: No hay usuario logueado (userId == null).");
        return;
      }

      // DEBUG 2: leer documento directamente desde Firestore
      print("DEBUG: Buscando usuario en Firestore...");
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      // DEBUG 3: mostrar el contenido crudo del documento
      print("DEBUG: Datos Firestore -> ${doc.data()}");

      // Si existe el documento, convertirlo con tu servicio (opcional)
      if (doc.exists) {
        final user = await _userService.getUserById(userId);
        print("DEBUG: Usuario desde UserService -> ${user?.name}");

        final services = await _serviceService.getProviderServices(userId);

        setState(() {
          _currentUser = user;
          _myServices = services.take(2).toList();
        });
      } else {
        print("DEBUG: Documento no encontrado en users/$userId");
      }
    } catch (e) {
      print("DEBUG: Error en _loadData -> $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000B1F),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_pattern.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.blue))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con saludo
                        Row(
                          children: [
                            Text(
                              '¡Hola ${(_currentUser != null && _currentUser!.name.isNotEmpty)
                                  ? _currentUser!.name.split(" ").first
                                  : "Usuario"}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: _currentUser?.photoUrl.isNotEmpty == true
                                  ? NetworkImage(_currentUser!.photoUrl)
                                  : null,
                              child: _currentUser?.photoUrl.isEmpty == true
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Tabs de servicios
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildServiceTab('Mis servicios', isActive: true),
                              const SizedBox(width: 8),
                              _buildServiceTab('Lavado de auto'),
                              const SizedBox(width: 8),
                              _buildServiceTab('Busco personal...'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Mis trabajos
                        _buildSection(
                          title: 'Mis trabajos',
                          child: Column(
                            children: [
                              _buildJobCard(
                                'Reparación de ...',
                                'Busco niñera',
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Últimos mensajes
                        _buildSection(
                          title: 'Últimos mensajes',
                          child: Column(
                            children: [
                              _buildMessageCard('Lucia', 'ahoig plod croozpé oduooiupm'),
                              _buildMessageCard('Mario', 'ahoig plod croozpé oduooiupm'),
                              _buildMessageCard('Jorge', 'ahoig plod croozpé oduooiupm'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Próximos trabajos
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF001F3F),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Próximos trabajos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No tienes próximos trabajos asignados para hoy. Alguno ahora?',
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Cerca de tu zona
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF001F3F),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cerca de tu zona',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Por el momento no hay trabajos cerca de tu zona. Vuelve pronto o ofrece tuum trabajo!',
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Botón Hacer publicación
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/create-service');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Hacer publicacion',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildServiceTab(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : const Color(0xFF001F3F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.blue : Colors.grey[700]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[400],
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF001F3F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildJobCard(String job1, String job2) {
    return Column(
      children: [
        _buildServiceChip(job1),
        const SizedBox(height: 8),
        _buildServiceChip(job2),
      ],
    );
  }

  Widget _buildServiceChip(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildMessageCard(String name, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF001F3F),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, isSelected: true),
              _buildNavItem(Icons.chat_bubble_outline),
              _buildNavItem(Icons.description_outlined),
              _buildNavItem(Icons.person_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, {bool isSelected = false}) {
    return Icon(
      icon,
      color: isSelected ? Colors.blue : Colors.grey[600],
      size: 28,
    );
  }
}