import 'package:flutter/material.dart';

const String version_app = "1.0.0";

//Colors

const Jaune = Color(0xFFDBC63C);
const Rouge = Color(0xFFAF1414);
const Vert = Color(0xFF23A910);
const Bleu = Color(0xFF1133F5);



//URL API
const double kDefaultPadding = 20.0;

//const API_BASE_URL = 'http://192.168.242.109:8000/api';
const BASE_URL = 'https://jande-app.com/public';
//const BASE_URL = 'http://192.168.242.109:8000';
const API_BASE_URL = 'https://jande-app.com/api';


const Download_File_BASE_URL = 'https://jande-app.com/public/';
//const Download_File_BASE_URL = 'http://192.168.242.109:8000/';
// token
const TOKEN_KEY = 'acces_token';


//DialogBox
void displayDialog(
    BuildContext dialogCtx, String titre, String msg, String type) {
  if (type == "success") {
    showDialog(
      context: dialogCtx,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(titre),
          content: Text(msg),
          actions: [
            /*TextButton(
              onPressed: () => Navigator.pop(ctx, 'Fermer'),
              child: const Text('Fermer'),
            ),*/
            TextButton(
              onPressed: () => Navigator.pop(ctx),
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
  }
  else if (type == "warning") {
    showDialog(
      context: dialogCtx,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(titre),
          content: Text(msg),
          actions: [
            /*TextButton(
              onPressed: () => Navigator.pop(ctx, 'Fermer'),
              child: const Text('Fermer'),
            ),*/
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'OK'),
              child: const Text('OK'),
              style: ButtonStyle(
                  elevation: MaterialStateProperty.all(15),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor: MaterialStateProperty.all(Jaune),
                  shadowColor: MaterialStateProperty.all(Jaune),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(5)),
                  fixedSize: MaterialStateProperty.all(const Size(100, 40))),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
          icon: Image.asset(
            'assets/images/warning_img.png',
            width: 80,
            height: 80,
          ),
        );
      },
    );
  }
  else if (type == "error") {
    showDialog(
      context: dialogCtx,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(titre),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'OK'),
              child: const Text('OK'),
              style: ButtonStyle(
                  elevation: MaterialStateProperty.all(15),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor: MaterialStateProperty.all(Rouge),
                  shadowColor: MaterialStateProperty.all(Rouge),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(5)),
                  fixedSize: MaterialStateProperty.all(const Size(100, 40))),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
          icon: Image.asset(
            'assets/images/cancel_img.png',
            width: 80,
            height: 80,
          ),
        );
      },
    );
  }
  else if (type == "danger") {
    showDialog(
      context: dialogCtx,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(titre),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'OK'),
              child: const Text('OK'),
              style: ButtonStyle(
                  elevation: MaterialStateProperty.all(15),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor: MaterialStateProperty.all(Rouge),
                  shadowColor: MaterialStateProperty.all(Rouge),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(5)),
                  fixedSize: MaterialStateProperty.all(const Size(100, 40))),
            ),

            TextButton(
              onPressed: () => Navigator.pop(ctx, 'OK'),
              child: const Text('OK'),
              style: ButtonStyle(
                  elevation: MaterialStateProperty.all(15),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor: MaterialStateProperty.all(Rouge),
                  shadowColor: MaterialStateProperty.all(Rouge),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(5)),
                  fixedSize: MaterialStateProperty.all(const Size(100, 40))),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
          icon: Image.asset(
            'assets/images/cancel_img.png',
            width: 80,
            height: 80,
          ),
        );
      },
    );
  }
  else {
    showDialog(
      context: dialogCtx,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(titre),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'OK'),
              child: const Text('OK'),
              style: ButtonStyle(
                  elevation: MaterialStateProperty.all(15),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor: MaterialStateProperty.all(Bleu),
                  shadowColor: MaterialStateProperty.all(Bleu),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(5)),
                  fixedSize: MaterialStateProperty.all(const Size(100, 40))),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
          icon: Image.asset(
            'assets/images/info_img.png',
            width: 80,
            height: 80,
          ),
        );
      },
    );
  }
}

