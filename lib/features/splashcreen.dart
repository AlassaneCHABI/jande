import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jande/features/choix_langue.dart';
import 'package:jande/models/audio_page.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ApiService api_service = ApiService();
  DbManager db_manager = DbManager();
  PreferenceManager pref_manager = PreferenceManager();

  double _progress = 0.0; // ✅ progression globale
  String _status = "Chargement en cours...";

  getDbLocalIntroduction() async {
    try {
      int? tailleIntro = await db_manager.countIntroductions();

      if (tailleIntro == 0) {
        await db_manager.clearAllIntroductions();

        final response = await api_service.getApi('introductions');

        if (response['data'] != null && response['data'].isNotEmpty) {
          List<dynamic> responseData = response['data'];
          List<Introduction> introductions = [];

          int total = responseData.length;
          int current = 0;

          for (var element in responseData) {
            Introduction intro = Introduction.fromJson(element);

            // Image
            if (intro.pathImage != null && intro.pathImage!.isNotEmpty) {
              final imagePath = await downloadAndSaveIntroductionFile(
                Download_File_BASE_URL + intro.pathImage!,
                'intro_${intro.id}.jpg',
              );
              intro.pathImage = imagePath;
            }

            // Audio
            if (intro.pathAudio != null && intro.pathAudio!.isNotEmpty) {
              final audioPath = await downloadAndSaveIntroductionFile(
                Download_File_BASE_URL + intro.pathAudio!,
                'intro_${intro.id}.mp3',
              );
              intro.pathAudio = audioPath;
            }

            await db_manager.insertIntroduction(intro);
            introductions.add(intro);

            // ✅ progression globale
            current++;
            setState(() {
              _progress = current / total;
              _status = "Chargement $current / $total";
            });
          }

          print("✅ ${introductions.length} introductions chargées et stockées.");
          return introductions;
        }
      } else {
        return await db_manager.getAllIntroductions();
      }
    } catch (e) {
      print("❌ Erreur getDbLocalIntroduction : $e");
      return [];
    }
  }

  Future<String> downloadAndSaveIntroductionFile(String url, String filename) async {
    try {
      final dir = await getIntroductionAssetsDirectory();
      final filePath = p.join(dir.path, filename);

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
              _status = "Téléchargement fichier...";
            });
          }
        },
      );

      return filePath;
    } catch (e) {
      print("❌ Erreur téléchargement fichier : $e");
      return '';
    }
  }

  Future<Directory> getIntroductionAssetsDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final modulesDir = Directory(p.join(baseDir.path, 'introduction_assets'));

    if (!await modulesDir.exists()) {
      await modulesDir.create(recursive: true);
    }

    return modulesDir;
  }

  Future<void> _initializeApp() async {
    await getDbLocalIntroduction();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ChoixLangue()),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/logo_.png',
                width: size.width * 0.5,
              ),
              const SizedBox(height: 40),

              // ✅ Barre de progression
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 10),

              // ✅ Texte + Pourcentage
              Text(
                "${(_progress * 100).toStringAsFixed(0)}% - $_status",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              Column(
                children: [
                  const Text(
                    "Une application de l’ONG POTAL MEN",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Image.asset(
                    'assets/images/logo_potal.png',
                    width: size.width * 0.25,
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
