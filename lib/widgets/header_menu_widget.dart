import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:jande/features/apropos.dart';
import 'package:jande/features/home.dart';
import 'package:jande/models/audio_page.dart';
import 'package:jande/models/themes.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/exam_questions.dart';
import '../models/modules.dart';


class HeaderMenuWidget extends StatefulWidget implements PreferredSizeWidget {


  HeaderMenuWidget({Key? key,}) : super(key: key);

  @override
  State<HeaderMenuWidget> createState() => _HeaderMenuWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _HeaderMenuWidgetState extends State<HeaderMenuWidget> {

  String messageAlert="Actualisation en cours...";

  ApiService api_service = ApiService();
  DbManager db_manager = DbManager();
  PreferenceManager pref_manager = PreferenceManager();
  StateSetter? _setStateDialog;


  void initState(){
    super.initState();
  }


  Future<bool> hasInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com/generate_204'))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }


  void showAlertDialog(BuildContext context, String message) {
    messageAlert = message;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _setStateDialog = setState; // Pour mettre à jour le message plus tard
            return AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(color: Jaune,),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text("$messageAlert..."),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  getDbLocalTheme() async {
    showAlertDialog(context, "Actualisation en cours");

    _setStateDialog?.call(() {
      messageAlert = "Chargement des Thèmes";
    });


    int? taille_theme=0;
    try {
      db_manager.countDbthemes().then((value) {
        setState(() {
          taille_theme = value;
        });
      });

      print("**********-----Api_service: getDbLocaltheme : taille ");
      print(taille_theme);

      if (await hasInternetConnection()) {
        print('connected');
        db_manager.removeAllDbthemes();
        taille_theme=0;
        List<Themes> cette_liste = [];

        api_service.getApi('themes').then((value) {
          List<dynamic> responseData = value['data'];
          if(!responseData.isEmpty){
            responseData.forEach((element) {
              Themes ce_item = Themes.fromJson(element);
              db_manager.insertDbTheme(ce_item);
              cette_liste.add(ce_item) ;
            });

            getDbLocalModule();
          }

        });
      }else{
        print('Pas de connexion internet');
        Navigator.of(context).pop();
        displayDialog(context, "Actualisation", "Une erreur s’est produite lors de l’actualisation des données. Vérifiez votre connexion Internet et réessayez.", "warning");

      }
    } catch (e) {
      print("*********----ERROR getDbLocalTheme------");
      print(e.toString());
    } finally {
      /*setState(() {
        _isLoading = false;
      });*/
    }
  }


  getDbLocalModule() async {
    _setStateDialog?.call(() {
      messageAlert = "Chargement des Modules";
    });
    print("Je suis ici");
    try {
      int? tailleModule = await db_manager.countDbmodules();

      if (await hasInternetConnection()){
        await db_manager.removeAllDbModule();
        final response = await api_service.getApi('modules');

        if (response['data'] != null && response['data'].isNotEmpty) {
          List<dynamic> responseData = response['data'];
          List<Modules> modules = [];

          for (var element in responseData) {
            Modules module = Modules.fromJson(element);

            // Téléchargement de l'image dans le dossier dédié
            // Téléchargement des images
            if (module.thumbnail_urls.isNotEmpty) {
              List<String> localImages = [];
              int index = 0;

              for (var imageUrl in module.thumbnail_urls) {
                final imagePath = await downloadAndSaveFile(
                  Download_File_BASE_URL+imageUrl, // ⚡ déjà propre
                  'module_${module.id}_$index.png',
                );
                localImages.add(imagePath);
                index++;
              }

              module.thumbnail_urls = localImages; // ✅ remplacer par chemins locaux
            }


            // Téléchargement de l'audio dans le dossier dédié
            if (module.audio_content_url != null) {
              final audioPath = await downloadAndSaveFile(
                Download_File_BASE_URL + module.audio_content_url!,
                'module_${module.id}.mp3',
              );

              module.audio_content_url = audioPath;

            }

            await db_manager.insertDbModule(module);
            modules.add(module);
          }
          getDbLocalquestion();
          //return modules;
        }


      } else {
        getDbLocalquestion();
        //return await db_manager.getAllDbmodules();
      }
    } catch (e) {
      print("❌ Erreur : $e");
      return [];
    }
  }


  /*getDbLocalModule() async {
    _setStateDialog?.call(() {
      messageAlert = "Chargement des Modules";
    });

    print("Je suis ici");
    try {
      int? tailleModule = await db_manager.countDbmodules();

      if (await hasInternetConnection()) {
        await db_manager.removeAllDbModule();
        final response = await api_service.getApi('modules');

        if (response['data'] != null && response['data'].isNotEmpty) {
          List<dynamic> responseData = response['data'];
          List<Modules> modules = [];

          for (var element in responseData) {
            Modules module = Modules.fromJson(element);

            // Téléchargement de l'image dans le dossier dédié
            // Téléchargement des images
            if (module.thumbnail_urls.isNotEmpty) {
              List<String> localImages = [];
              int index = 0;

              for (var imageUrl in module.thumbnail_urls) {
                final imagePath = await downloadAndSaveFile(
                  imageUrl, // ⚡ déjà propre
                  'module_${module.id}_$index.png',
                );
                localImages.add(imagePath);
                index++;
              }

              module.thumbnail_urls = localImages; // ✅ remplacer par chemins locaux
            }



            // Téléchargement de l'audio dans le dossier dédié
            if (module.audio_content_url != null) {
              final audioPath = await downloadAndSaveFile(
                Download_File_BASE_URL + module.audio_content_url!,
                'module_${module.id}.mp3',
              );

              module.audio_content_url = audioPath;

            }

            await db_manager.insertDbModule(module);
            modules.add(module);
          }
          getDbLocalquestion();
          //return modules;
        }


      } else {
       // getDbLocalquestion();
        //return await db_manager.getAllDbmodules();
      }
    } catch (e) {
      print("❌ Erreur : $e");
      return [];
    }
  }
*/

  getDbLocalquestion() async {
    _setStateDialog?.call(() {
      messageAlert = "Chargement des Question";
    });

    int? taille_examquestion=0;
    try {
      db_manager.countDbexamquestions().then((value) {
        setState(() {
          taille_examquestion = value;
        });
      });

      print("**********-----Api_service: getDbLocalquestion : taille ");
      print(taille_examquestion);

      if (await hasInternetConnection())
      {
        db_manager.removeAllDbexamquestions();
        taille_examquestion=0;
        List<ExamQuestions> cette_liste = [];

        api_service.getApi('questions').then((value) {
          List<dynamic> responseData = value['data'];
          if(!responseData.isEmpty){
            responseData.forEach((element) {
              ExamQuestions ce_item = ExamQuestions.fromJson(element);
              db_manager.insertDbquestion(ce_item);
              cette_liste.add(ce_item) ;
            });

            // getDbLocalModule();
          }

        });

       await getDbLocalIntroduction();

        Navigator.of(context).pop();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home()),
                (route) => false);
      }else{
        Navigator.of(context).pop();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home()),
                (route) => false);
      }
    } catch (e) {
      print("*********----ERROR getDbLocalTheme------");
      print(e.toString());
    } finally {
      /*setState(() {
        _isLoading = false;
      });*/
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



  Future<String> downloadAndSaveFile(String url, String filename) async {
    try {
      final dir = await getModulesAssetsDirectory(); // utilise le dossier dédié
      final filePath = p.join(dir.path, filename);

      final dio = Dio();
      final response = await dio.download(url, filePath);

      if (response.statusCode == 200) {
        print("✅ Fichier téléchargé : $filePath");
        return filePath;
      } else {
        throw Exception('Erreur téléchargement');
      }
    } catch (e) {
      print("❌ Erreur téléchargement fichier : $e");
      return '';
    }
  }

  /// Crée  et retourne le chemin vers le dossier `modules_assets`
  Future<Directory> getModulesAssetsDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final modulesDir = Directory(p.join(baseDir.path, 'modules_assets'));

    if (!await modulesDir.exists()) {
      await modulesDir.create(recursive: true);
    }

    return modulesDir;
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
          padding: EdgeInsets.only(right: width * 0.09),
          child:PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'apropos',
                  child: Text('A propos'),
                ),
                PopupMenuItem<String>(
                  value: 'update',
                  child: Text('Mettre à jour les données'),
                ),
              ];
            },
            //icon: Image.asset("assets/images/projet.png",color: Colors.white,width: 22,),
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value =="apropos")
              {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AboutScreen(),
                  ),
                );
              }
              if (value =="update")
              {
                showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text("Actualiser"),
                      content: Text("Voulez-vous actualiser vos données ? "
                          "\n\nCette opération nécessite une connexion internet."),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await getDbLocalTheme();
                          },
                          child: const Text('Oui'),
                          style: ButtonStyle(
                            // elevation: MaterialStateProperty.all(5),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                            backgroundColor: MaterialStateProperty.all(Jaune),
                            shadowColor: MaterialStateProperty.all(Jaune),
                            padding: MaterialStateProperty.all(const EdgeInsets.all(5)),
                            fixedSize: MaterialStateProperty.all(const Size(100, 40)),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // Ajustez cette valeur selon vos préférences
                            )),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Annuler',style: TextStyle(color: Colors.black),),
                          style: ButtonStyle(
                            // elevation: MaterialStateProperty.all(5),
                            foregroundColor: MaterialStateProperty.all(Jaune),
                            backgroundColor: MaterialStateProperty.all(Color(0xFFDBC63C).withOpacity(0.2),),
                            shadowColor: MaterialStateProperty.all(Colors.black),
                            padding: MaterialStateProperty.all(const EdgeInsets.all(5)),
                            fixedSize: MaterialStateProperty.all(const Size(100, 40)),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // Ajustez la valeur pour réduire le borderRadius
                            )),
                          ),
                        ),

                      ],
                      actionsAlignment: MainAxisAlignment.spaceBetween,
                      icon: Image.asset(
                        'assets/images/info_img.png',
                        width: 80,
                        height: 80,
                      ),
                    );
                  },
                );
              }
            },
          )),

          /*Padding(
            padding: EdgeInsets.only(right: width * 0.09),
            child: InkWell(
              onTap: (){
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => AboutScreen()),
                        (route) => false);

              },
              child:Icon(Icons.more_vert, color: Colors.black),
            ),
          )*/
        ],
        title:Padding(
          padding: EdgeInsets.only(left: width * 0.04),
          child: Text(
            "Jande",
            style: TextStyle(
              fontSize: width * 0.06,
              fontFamily: 'Poppins',
              color: Jaune,
            ),
          ),
        )
    );
  }
}
