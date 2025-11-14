import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/service_service.dart';
import '../models/service_model.dart';

class MyServicesRequestsScreen extends StatefulWidget {
  const MyServicesRequestsScreen({Key? key}) : super(key: key);

  @override
  State<MyServicesRequestsScreen> createState() =>
      _MyServicesRequestsScreenState();
}

class _MyServicesRequestsScreenState extends State<MyServicesRequestsScreen> {
  final ServiceService _serviceService = ServiceService();
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyServices();
  }

  Future<void> _loadMyServices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Usuario no autenticado';
        _isLoading = false;
      });
      return;
    }

    try {
      final services = await _serviceService.getProviderServices(user.uid);
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar servicios: $e';
        _isLoading = false;
      });
    }
  }

  // MEJORA: Datos de ejemplo que se mantienen como fallback
  List<Map<String, dynamic>> _getExampleRequests() {
    return [
      {
        'name': 'Ludmila Gorriti',
        'status': 'Rechazado',
        'statusColor': Colors.red,
        'avatar': '',
      },
      {
        'name': 'Luciano Aguilera',
        'status': 'Enviado',
        'statusColor': Colors.orange,
        'avatar': '',
      },
      {
        'name': 'Pablo Carral',
        'status': 'Aceptado',
        'statusColor': Colors.green,
        'avatar': '',
      },
    ];
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Mis servicios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                )
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 50),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loadMyServices,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_services.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.work_outline,
                              color: Colors.grey, size: 60),
                          const SizedBox(height: 16),
                          const Text(
                            'No tenés servicios publicados',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Cuando crees servicios, aparecerán aquí',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Navegar a crear servicio
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                            ),
                            child: const Text('Crear primer servicio'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        '${_services.length} servicio${_services.length != 1 ? 's' : ''} encontrado${_services.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._services
                          .map((service) => _buildServiceCard(service))
                          .toList(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    final requests = _getExampleRequests(); // Mantenemos ejemplos visuales

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF001F3F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del servicio REAL
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (service.description.isNotEmpty)
                  Text(
                    service.description.length > 100
                        ? '${service.description.substring(0, 100)}...'
                        : service.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.category, color: Colors.blue[300], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      service.category,
                      style: TextStyle(color: Colors.blue[300], fontSize: 14),
                    ),
                    const Spacer(),
                    if (service.price != null)
                      Text(
                        service.formattedPrice,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // MEJORA: Información de rating real del servicio
          if (service.ratingCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${service.ratingAvg} (${service.ratingCount})',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Sección Solicitudes (mantenemos ejemplos visuales)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00264D),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: Colors.blue.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solicitudes de ejemplo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Estos son ejemplos visuales. Las solicitudes reales se conectarán cuando implementes el sistema de chats.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),

                // Lista de solicitudes (ejemplos visuales mantenidos)
                ...requests.map((request) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue[900],
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            request['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (request['statusColor'] as Color)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: request['statusColor'] as Color,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                request['status'] == 'Aceptado'
                                    ? Icons.check_circle
                                    : request['status'] == 'Rechazado'
                                        ? Icons.cancel
                                        : Icons.access_time,
                                size: 14,
                                color: request['statusColor'] as Color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                request['status'] as String,
                                style: TextStyle(
                                  color: request['statusColor'] as Color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
