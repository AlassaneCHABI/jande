import 'dart:io';

import 'package:jande/features/cours/contenu_cours.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:flutter/material.dart';
import "package:jande/models/modules.dart" as ce_module;

class Modules extends StatefulWidget {
  int theme_id;
  String theme_name;
  Modules({super.key, required this.theme_id,required this.theme_name});

  @override
  State<Modules> createState() => _FromageCoursePageState();
}

class _FromageCoursePageState extends State<Modules> {

  ApiService api_service = ApiService();
  DbManager db_manager = DbManager();
  PreferenceManager pref_manager = PreferenceManager();

  List<ce_module.Modules> liste_module = [];
  late Future<List<ce_module.Modules>> future_module;

  final List<Map<String, String>> courseSteps = [
    {
      "title": "Pré-requis",
      "image": "assets/images/module.png", // Remplace avec tes images locales
      "index": "01",
    },
    {
      "title": "Filtrage du lait et mise\na feu doux",
      "image": "assets/images/module.png",
      "index": "02",
    },
    {
      "title": "Filtrage du lait et mise\na feu doux",
      "image": "assets/images/module.png",
      "index": "02",
    }
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDbLocalModule(widget.theme_id);
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.09,
            vertical: height * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE5E5E5),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),

              // Title
               Text(
                widget.theme_name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Cours",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),

              // Course steps
              Expanded(
                child: ListView.builder(
                  itemCount: liste_module.length,
                  itemBuilder: (context, index) {
                    final module = liste_module[index];
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 50, bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0C93C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Numéro du module
                                Text(
                                  "${index + 1 < 10 ? '0${index + 1}' : index + 1} ",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Titre du module
                                Expanded(
                                  child: Text(
                                    module.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),

                                // Icône play
                                 InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => ContenuCours(theme_id: module.theme_id,theme_name:module.theme_name)),
                                    );
                                  },
                                  child: Icon(
                                    Icons.play_circle,
                                    size: 30,
                                    color: Colors.black87,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        // Image en haut
                       Positioned(
                          top: 0,
                          left: 20,
                          right: 20,
                          child:InkWell(
                          onTap: () {
                          Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ContenuCours(theme_id: module.theme_id,theme_name:module.theme_name)),
                          );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child:Image.file(File(module.thumbnail_urls.first),height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,)
                          )),
                        ),
                      ],
                    );
                  },
                ),
              ),


              // Bottom button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ContenuCours(theme_id:widget.theme_id,theme_name:widget.theme_name)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0C93C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Commencer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  Future<List<ce_module.Modules>> getDbLocalModule(int theme_id) async {

    liste_module.clear();
    var curr_liste = await db_manager.getDbmodulebytheme(theme_id);
    print(curr_liste.length);

    setState(() {
      liste_module = curr_liste;
    });
    return liste_module;
  }

}
