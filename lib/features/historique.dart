import 'package:jande/features/apropos.dart';
import 'package:jande/features/home.dart';
import 'package:jande/features/cours/liste_cours.dart';
import 'package:jande/features/profil/profil.dart';
import 'package:jande/models/historique.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:jande/widgets/bottom_nav_bar.dart';
import 'package:jande/widgets/header_menu_widget.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import "package:jande/models/historique.dart" as ce_resulat;

class Historique extends StatefulWidget {
  const Historique({super.key});

  @override
  State<Historique> createState() => _HistoriqueState();
}

class _HistoriqueState extends State<Historique> {
  int _currentIndex = 2;

  ApiService api_service = ApiService();
  DbManager db_manager = DbManager();
  PreferenceManager pref_manager = PreferenceManager();
  List<ce_resulat.Result> liste_resultat = [];

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
  void initState() {
    super.initState();
    _loadHistorique();
  }

  Future<void> _loadHistorique() async {
    await getDbLocalResultat();
  }

  Future<List<ce_resulat.Result>> getDbLocalResultat() async {
    liste_resultat.clear();
    var curr_liste = await db_manager.getAllDbexamresults();

    setState(() {
      liste_resultat = curr_liste;
    });

    return liste_resultat;
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
                "Historique",
                style: TextStyle(
                  fontSize: width * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.015),
              liste_resultat.isEmpty
                  ? const Center(child: Text("Aucun historique disponible."))
                  : Wrap(
                spacing: width * 0.03,
                runSpacing: height * 0.02,
                children: liste_resultat.map((result) {
                  return _historyCard(
                    result.theme_name ?? "Module inconnu",
                    result.created_at ?? "Date inconnue",
                    result.time ?? "Heure inconnue",
                    "${result.score}/${result.nbr_question}",
                    size,
                  );
                }).toList(),
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

  Widget _historyCard(String title, String date, String heure, String note, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        color: const Color(0xFFDBC63C).withOpacity(0.2),
        borderRadius: BorderRadius.circular(size.width * 0.04),
      ),
      child: Row(
        children: [
          Icon(Icons.pets, size: size.width * 0.1, color: const Color(0xFFDBC63C)),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.length > 45 ? '${title.substring(0, 45)}...' : title,
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.005),
                Row(
                  children: [
                    Text(date, style: TextStyle(fontSize: size.width * 0.03)),
                    SizedBox(width: size.width * 0.02),
                    Text("|", style: TextStyle(fontSize: size.width * 0.03)),
                    SizedBox(width: size.width * 0.02),
                    Text(heure, style: TextStyle(fontSize: size.width * 0.03)),
                    SizedBox(width: size.width * 0.02),
                    Text("|", style: TextStyle(fontSize: size.width * 0.03)),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      note,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.035,
                        color: Colors.green,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
