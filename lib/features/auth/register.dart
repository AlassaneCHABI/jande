import 'dart:io';

import 'package:jande/features/auth/login.dart';
import 'package:jande/models/audio_page.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/auth_service.dart';
import 'package:jande/utils/db_manager.dart';
import "package:flutter/material.dart";
import 'package:just_audio/just_audio.dart';
import '../../utils/constants.dart';

class Register extends StatefulWidget {
  Register({Key? key}) : super(key: key);

  @override
  _RegisterUIState createState() => new _RegisterUIState();
}

class _RegisterUIState extends State<Register> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController _nomController= TextEditingController();
  TextEditingController _prenomController= TextEditingController();
  TextEditingController _telephoneController= TextEditingController();
  TextEditingController _emailController= TextEditingController();
  TextEditingController _passwordController= TextEditingController();
  TextEditingController _confirmController= TextEditingController();

  bool passwordVisible = true;
  bool confirm_passwordVisible = true;
  ApiService api_service = ApiService();
  DbManager db_manager = DbManager();

  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Introduction? introAudio; // l'introduction à jouer


  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    // Écoute les changements de position et durée pour le Slider
    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });

    _audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    // ✅ Gérer la fin de lecture
    _audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await _audioPlayer.seek(Duration.zero); // retour au début
        await _audioPlayer.pause();             // stoppe la lecture
        setState(() {
          _position = Duration.zero;
        });
      }
    });

    loadIntroductionAndPlay();
  }


  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


  Future<Introduction?> getIntroductionByCode(String codeTitre) async {
    try {
      final db = await DbManager.db();
      final List<Map<String, dynamic>> result = await db.query(
        'introductions',          // nom de ta table
        where: 'code_titre = ?',  // condition
        whereArgs: [codeTitre],   // valeur du code
        limit: 1,                 // on veut un seul résultat
      );

      if (result.isNotEmpty) {
        return Introduction.fromMap(result.first);
      } else {
        return null; // Aucun résultat trouvé
      }
    } catch (e) {
      print("❌ Erreur getIntroductionByCode : $e");
      return null;
    }
  }


  /// Charger l'introduction "cl" et jouer l'audio
  Future<void> loadIntroductionAndPlay() async {
    introAudio = await getIntroductionByCode('cc');

    if (introAudio != null && introAudio!.pathAudio.isNotEmpty) {
      if (File(introAudio!.pathAudio).existsSync()) {
        await _audioPlayer.setFilePath(introAudio!.pathAudio);
        await _audioPlayer.play(); // joue automatiquement
      } else {
        print("⚠️ Fichier audio introuvable : ${introAudio!.pathAudio}");
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return
      Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Titres fixes en haut
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.09, vertical: height * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Créer un compte",
                      style: TextStyle(
                        fontSize: width * 0.11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        height: 1,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      "Commencer votre voyage d'apprentissage !",
                      style: TextStyle(
                        fontSize: width * 0.050,
                      ),
                    ),
                  ],
                ),
              ),

              // Formulaire scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.09),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Tous tes TextFormField ici comme avant
                        SizedBox(height: height * 0.02),
                        TextFormField(
                          controller: _nomController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.black)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(width: 1.5, color: Colors.black),
                            ),
                            hintText: "Nom",
                            hintStyle: const TextStyle(color: Colors.black),
                            alignLabelWithHint: false,
                            //fillColor: Bleu,
                            filled: true,
                            fillColor: Color(0xFFDBC63C).withOpacity(0.10),
                          ),
                          validator: (value) => value!.isEmpty?"Champ incorrect":null,
                        ),
                        SizedBox(height: height * 0.02),
                        TextFormField(
                          controller: _prenomController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.black)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(width: 1.5, color: Colors.black),
                            ),
                            hintText: "Prénom",
                            hintStyle: const TextStyle(color: Colors.black),
                            alignLabelWithHint: false,
                            //fillColor: Bleu,
                            filled: true,
                            fillColor: Color(0xFFDBC63C).withOpacity(0.10),
                          ),
                          validator: (value) => value!.isEmpty?"Champ incorrect":null,
                        ),

                        SizedBox(height: height * 0.02),
                        TextFormField(
                          controller: _telephoneController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.black)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(width: 1.5, color: Colors.black),
                            ),
                            hintText: "Téléphone",
                            hintStyle: const TextStyle(color: Colors.black),
                            alignLabelWithHint: false,
                            //fillColor: Bleu,
                            filled: true,
                            fillColor: Color(0xFFDBC63C).withOpacity(0.10),
                          ),
                          validator: (value) => value!.isEmpty?"Champ incorrect":null,
                        ),

                        SizedBox(height: height * 0.02),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.black)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(width: 1.5, color: Colors.black),
                            ),
                            hintText: "Email",
                            hintStyle: const TextStyle(color: Colors.black),
                            alignLabelWithHint: false,
                            //fillColor: Bleu,
                            filled: true,
                            fillColor: Color(0xFFDBC63C).withOpacity(0.10),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre adresse e-mail';
                            } else if (!value.contains('@')) {
                              return 'Veuillez entrer une adresse e-mail valide';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: height * 0.02),
                        TextFormField(
                          controller: _passwordController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.black)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(width: 1.5, color: Colors.black),
                            ),
                            hintText: "Mot de passe",
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Jaune,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible ? Icons.visibility_off : Icons.visibility,
                                color: Jaune,
                              ),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),

                            hintStyle: const TextStyle(color: Colors.black),
                            alignLabelWithHint: false,
                            //fillColor: Bleu,
                            filled: true,
                            fillColor: Color(0xFFDBC63C).withOpacity(0.10),
                          ),
                          obscureText: passwordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty || value.length<8) {
                              return 'Mot de passe incomplet (min. 8 caractères requis)';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: height * 0.02),
                        TextFormField(
                          controller: _confirmController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.black)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(width: 1.5, color: Colors.black),
                            ),
                            hintText: "Confirmer mot de passe",
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Jaune,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                confirm_passwordVisible ? Icons.visibility_off : Icons.visibility,
                                color: Jaune,
                              ),
                              onPressed: () {
                                setState(() {
                                  confirm_passwordVisible = !confirm_passwordVisible;
                                });
                              },
                            ),
                            hintStyle: const TextStyle(color: Colors.black),
                            alignLabelWithHint: false,
                            //fillColor: Bleu,
                            filled: true,
                            fillColor: Color(0xFFDBC63C).withOpacity(0.10),
                          ),
                          obscureText: confirm_passwordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty || value.length<8) {
                              return 'Mot de passe incomplet (min. 8 caractères requis)';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.02),

                        // ... ton contenu UI
                        if (introAudio != null)
                          Column(
                            children: [
                              Slider(
                                activeColor: Colors.black,
                                inactiveColor: Colors.grey.shade300,
                                value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
                                max: _duration.inSeconds.toDouble(),
                                onChanged: (value) {
                                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _audioPlayer.playing ? Icons.pause_circle : Icons.play_circle,
                                      size: 42,
                                    ),
                                    onPressed: () async {
                                      if (_audioPlayer.playing) {
                                        await _audioPlayer.pause();
                                      } else {
                                        await _audioPlayer.play();
                                      }
                                    },
                                  ),

                                ],
                              ),
                            ],
                          ),

                        // Lien de connexion
                        SizedBox(height: height * 0.04),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Déjà un compte ?'),
                            SizedBox(width: width * 0.04),
                            InkWell(
                              onTap: () async {
                                await _audioPlayer.stop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  ),
                                );
                              },
                              child: Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: Colors.black, // facultatif : pour style de lien
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),

                        SizedBox(height: height * 0.02),

                        Center(
                          child: SizedBox(
                            width: width * 0.9,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () async {
                                await _audioPlayer.stop();
                                if (_formKey.currentState!.validate()) {
                                  registerUserToServer();

                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Jaune,
                                textStyle: const TextStyle(fontSize: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: const Text(
                                'Créer son compte ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.9),
                      ],
                    ),
                  ),
                ),
              ),

              // Bouton fixé en bas
              /*Padding(
                padding: EdgeInsets.only(
                  left: width * 0.09,
                  right: width * 0.09,
                  bottom: height * 0.03,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        registerUserToServer();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Jaune,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: const Text(
                      'Créer son compte',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),*/
            ],
          ),
        ),
      );

  }


  showAlertDialog(BuildContext context,String message){
    AlertDialog alert=AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 5),child:Text("$message...." )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }


  registerUserToServer() async {
    showAlertDialog(context,"Création en cours");
    print(_nomController.text,);
    print(_prenomController.text,);
    print(_emailController.text,);
    print(_passwordController.text,);
    print(_telephoneController.text,);

    final data = {
      'first_name': _nomController.text,
      'last_name': _prenomController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'contact': _telephoneController.text,
    };

    print(data);

    var response = await AuthService().registerUserProfile(data);

    print("****-------RESPONSE REGISTER----");
    print(response);

    if (response == "succes") {
      Navigator.of(context).pop();
      showDialog(
        context: this.context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text("Création de compte"),
            content: Text("Votre compte a été créé avec succès!", textAlign: TextAlign.center,),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                          (route) => false);
                },
                child: const Text('OK'),
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(15),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(Vert),
                    shadowColor: MaterialStateProperty.all(Vert),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(5)),
                    fixedSize: MaterialStateProperty.all(const Size(100, 40))),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
            icon: Image.asset(
              'assets/images/checked_img.png',
              width: 80,
              height: 80,
            ),
          );
        },
      );

      /*displayDialog(context,
          "Enregistrement",
          "Votre compte a été créé avec succès! "
              "\nVeuillez vous connecter après validation du compte par un administrateur",
          "success");*/


    }
    else {
      Navigator.of(context).pop();
      displayDialog(context,
          "Erreur d'enregistrement",
          "${response}",
          "warning");
    }
  }

}
