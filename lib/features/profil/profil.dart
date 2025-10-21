import 'package:jande/features/choix_langue.dart';
import 'package:jande/features/home.dart';
import 'package:jande/models/users.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:flutter/material.dart';

class ComptePage extends StatefulWidget {
  const ComptePage({super.key});

  @override
  State<ComptePage> createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  bool isEditing = false;
  ApiService api_service = ApiService();
  DbManager db_manager = DbManager();
  PreferenceManager pref_manager = PreferenceManager();
  late User user;
  var _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocalUser();
  }

  Future<void> _getLocalUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<User> users = await db_manager.getAllDbUser();
      if (users.isNotEmpty) {
        user = users.first;

        // Initialise les champs avec les données de l'utilisateur
        nomController.text = user.first_name ?? '';
        prenomController.text = user.last_name ?? '';
        orgaController.text = 'POTAL MEN';
        phoneController.text = user.contact ?? '';
        emailController.text = user.email ?? '';

        setState(() {}); // Pour refléter les nouvelles valeurs dans l'UI
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur : $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController orgaController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ← Retour
              Row(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFE5E5E5),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                // Titre
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Compte',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
              ],),


              const SizedBox(height: 20),

              // Avatar + nom + email + bouton éditer
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar avec icône
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/images/profil.png'), // Remplace par ta vraie image
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        padding: const EdgeInsets.all(5),
                        child: const Icon(Icons.lock, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Nom, email, bouton
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${nomController.text} ${prenomController.text}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(emailController.text),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isEditing = !isEditing;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(isEditing ? 'Enregistrer' : 'Editer'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 30),

              // Champs modifiables

              InputField(label: 'Nom', controller: nomController, enabled: isEditing),
              InputField(label: 'Prénoms', controller: prenomController, enabled: isEditing),
              InputField(label: 'Organisation', controller: orgaController, enabled: isEditing),
              InputField(label: 'Téléphone', controller: phoneController, enabled: isEditing),
              InputField(label: 'Email', controller: emailController, enabled: isEditing),

              const Spacer(),

              // Bouton déconnexion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    pref_manager.removeAllPrefItem();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChoixLangue(),
                      ),
                    );
                    //db_manager.removeAllDbRows();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    "Déconnexion",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          TextField(
            controller: controller,
            enabled: enabled,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
