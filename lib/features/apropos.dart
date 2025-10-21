import 'package:jande/features/home.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading:Padding(
        padding: EdgeInsets.only(left: width * 0.05),
        child:  IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFE5E5E5),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(10),
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Home()),
                    (route) => false);
          },
        )),
        title: const Text(
          'A Propos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.09,
          vertical: height * 0.03,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                children: const [
                  Text(
                    'Information sur l’éditeur',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text("Nom de l'organisation : POTAL MEN"),
                  Text("Site web : https://ong-potalmen.org/"),
                  Text("Email : contact@ong-potalmen.org"),
                  Text("Téléphone : +229 01 96 67 40 94"),
                  Text("Adresse : Natitingou, Quartier Kantaborifa"),
                  SizedBox(height: 20),
                  Divider(thickness: 1),
                  SizedBox(height: 10),
                  Text(
                    'Cette application a été conçue et développée par :',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'DYRA',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text('00229 01 64 09 23 20'),
                  Text('dyra.benin@dyra.bj'),
                  Text('dyra.bj'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'Jande App V 1.0.0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
