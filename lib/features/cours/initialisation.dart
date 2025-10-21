import 'package:jande/features/cours/modules.dart';
import 'package:jande/utils/constants.dart';
import 'package:flutter/material.dart';

class Initialisation extends StatefulWidget {
  const Initialisation({Key? key}) : super(key: key);

  @override
  State<Initialisation> createState() => _InitialisationState();
}

class _InitialisationState extends State<Initialisation> {
  @override
  Widget build(BuildContext context) {
    //final width = MediaQuery.of(context).size.width;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.09,
            vertical: height * 0.03,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton retour
              Container(
                width: 40, // Nouvelle largeur plus petite
                height: 40, // Nouvelle hauteur plus petite
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,// Couleur de fond du cercle
                  shape: BoxShape.circle, // Forme circulaire
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black,size: 20,),
                  padding: EdgeInsets.zero, // Padding pour que l'icône soit bien centrée
                  constraints: BoxConstraints(), // Supprime les contraintes par défaut
                ),
              ),


              const SizedBox(height: 10),

              // Titre
              const Text(
                "Transformation du\nsavon de moringa",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/savon.png',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 20),

              // Sous-titre
              const Text(
                "Principe / Objectif",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              // Texte descriptif
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    "Le savon au moringa est obtenu par la méthode de saponification à froid. "
                        "En effet, la lessive de soude est préparée puis versée dans un mélange d’huiles "
                        "(déjà apprêtée). Toute la solution est ensuite remuée dans un seul sens pendant "
                        "au moins 15 min afin d’obtenir la trace. Elle est enfin versée dans les moules en "
                        "silicone ou en bois après l’ajout de la poudre des feuilles de moringa. C’est ainsi "
                        "que l’on obtient le savon après démoulage. Pour 1,5 L d’huile, il faut 750ml d’huile "
                        "de palme, 750ml de beurre de karité, 560ml d’eau, 250g de soude et 45g de poudre des "
                        "feuilles de moringa.",
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bouton Suivant
              SizedBox(
                width: width * 0.9,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    /*Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Modules(theme_id: ,),
                      ),
                    );*/
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Jaune,
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text(
                    "Suivant",
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
