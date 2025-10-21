import 'dart:io';

import 'package:jande/features/apropos.dart';
import 'package:jande/features/cours/initialisation.dart';
import 'package:jande/features/cours/modules.dart';
import 'package:jande/features/historique.dart';
import 'package:jande/features/home.dart';
import 'package:jande/features/profil/profil.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:jande/widgets/bottom_nav_bar.dart';
import 'package:jande/widgets/header_menu_widget.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import "package:jande/models/themes.dart" as ce_theme;

class ListeCours extends StatefulWidget {
  const ListeCours({super.key});

  @override
  State<ListeCours> createState() => _ListeCoursState();
}

class _ListeCoursState extends State<ListeCours> {
  int _currentIndex = 1;
  List<ce_theme.Themes> liste_theme = [];
  late Future<List<ce_theme.Themes>> future_theme;

  ApiService api_service = ApiService();
  DbManager db_manager = DbManager();
  PreferenceManager pref_manager = PreferenceManager();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDbLocalTheme();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ListeCours()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Historique()),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  ComptePage()),
          );
          break;
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HeaderMenuWidget(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.09,
          vertical: height * 0.03,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Liste des cours",
                style: TextStyle(
                  fontSize: width * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.015),
              SizedBox(
                height: height*9,
                child: SizedBox(
                    height: height*0.23,
                    child:liste_theme.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        :  GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: width * 0.03,
                      mainAxisSpacing: height * 0.02,
                      childAspectRatio: 0.85,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: liste_theme.map((theme) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Modules(theme_id: theme.online_id,theme_name: theme.title,)),
                            );
                          },
                          child: _courseCard(theme.title ?? "Thème", theme.icon_name, size,theme.nbr_modules.toString()),
                        );
                      }).toList(),
                    ))
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }



  Widget _courseCard(String title, String icon, Size size,String nbr_cours) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFDBC63C).withOpacity(0.2),
        borderRadius: BorderRadius.circular(size.width * 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ← ajoute juste ça
        children: [
          icon != null &&
              File(icon)
                  .existsSync()
              ? Image.file(File(icon),
            width: size.width * 0.1,)
              : const Icon(Icons.play_arrow,
              size: 40, color: const Color(0xFFDBC63C)),
          //Icon(icon, size: size.width * 0.1, color: const Color(0xFFDBC63C)),
          SizedBox(height: size.height * 0.015),
          Text(
            title.length > 25 ? '${title.substring(0, 25)}...' : title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.045,
              height: 1.1,
            ),
          ),
          SizedBox(height: size.height * 0.010),
          Row(
            children: [
              Icon(Icons.menu_book_outlined, size: size.width * 0.05),
              SizedBox(width: size.width * 0.01),
              Text("$nbr_cours leçons", style: TextStyle(fontSize: size.width * 0.035)),
            ],
          )
        ],
      ),
    );
  }

  Future<List<ce_theme.Themes>> getDbLocalTheme() async {

    liste_theme.clear();
    var curr_liste = await db_manager.getAllDbthemes();

    setState(() {
      liste_theme = curr_liste;
    });
    return liste_theme;
  }

}
