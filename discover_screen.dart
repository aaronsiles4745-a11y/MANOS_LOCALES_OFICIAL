import 'package:flutter/material.dart';
import '../widgets/discover_profile_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  bool mostrarPuestos = true;

  // ============================
  // LISTA DE PUESTOS (SIMULADOS)
  // ============================
  final List<Map<String, dynamic>> puestos = [
    {
      "titulo": "Electricista para urgencias",
      "descripcion": "Reparación inmediata de cortocircuitos y fallas.",
      "precio": "\$10.000",
      "ubicacion": "Zona Norte",
      "foto": "assets/images/inicio1.png",
    },
    {
      "titulo": "Profesor de Matemáticas",
      "descripcion": "Clases particulares para secundaria.",
      "precio": "\$5.000",
      "ubicacion": "Zona Sur",
      "foto": "assets/images/inicio2.png",
    },
  ];

  // ============================
  // LISTA DE CANDIDATOS (SIMULADOS)
  // ============================
  final List<Map<String, dynamic>> candidatos = [
    {
      "nombre": "Juan Rodríguez",
      "profesion": "Plomero Profesional",
      "experiencia": "5 años de experiencia",
      "ubicacion": "Zona Oeste",
      "foto": "assets/images/inicio3.png",
    },
    {
      "nombre": "María López",
      "profesion": "Niñera con referencias",
      "experiencia": "3 años de experiencia",
      "ubicacion": "Zona Este",
      "foto": "assets/images/inicio1.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ============================
            // TITULO
            // ============================
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Descubrir",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ),

            // ============================
            // TABS: Puestos / Candidatos
            // ============================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab("Puestos", true),
                const SizedBox(width: 12),
                _buildTab("Candidatos", false),
              ],
            ),

            const SizedBox(height: 20),

            // ============================
            // CONTENIDO (LISTA)
            // ============================
            Expanded(
              child: mostrarPuestos ? _buildPuestos() : _buildCandidatos(),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------
  // TABs
  // -----------------------------------------
  Widget _buildTab(String label, bool isPuestosTab) {
    final isActive = (isPuestosTab && mostrarPuestos) ||
        (!isPuestosTab && !mostrarPuestos);

    return GestureDetector(
      onTap: () {
        setState(() => mostrarPuestos = isPuestosTab);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.white,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // LISTA DE PUESTOS
  // ----------------------------
  Widget _buildPuestos() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: puestos.map((item) {
        return DiscoverProfileCard(
          data: item,
          isPuesto: true,
          onTapAvatar: () {
            Navigator.pushNamed(
              context,
              "/detalle_puesto",
              arguments: item,
            );
          },
          onTapCard: () {
            Navigator.pushNamed(
              context,
              "/detalle_puesto",
              arguments: item,
            );
          },
        );
      }).toList(),
    );
  }

  // ----------------------------
  // LISTA DE CANDIDATOS
  // ----------------------------
  Widget _buildCandidatos() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: candidatos.map((item) {
        return DiscoverProfileCard(
          data: item,
          isPuesto: false,
          onTapAvatar: () {
            Navigator.pushNamed(
              context,
              "/detalle_candidato",
              arguments: item,
            );
          },
          onTapCard: () {
            Navigator.pushNamed(
              context,
              "/detalle_candidato",
              arguments: item,
            );
          },
        );
      }).toList(),
    );
  }
}
