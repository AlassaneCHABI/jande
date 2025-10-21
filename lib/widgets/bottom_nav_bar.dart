import 'package:jande/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Color(0xFFDBC63C),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      onTap: onTap,
      items:  [
        BottomNavigationBarItem(icon: SvgPicture.asset('assets/icones/home.svg',width: 25,height: 25,color: Jaune,), label: "Accueil"),
        BottomNavigationBarItem(icon: SvgPicture.asset('assets/icones/cours.svg',width: 25,height: 25,color: Jaune,), label: "Cours"),
        BottomNavigationBarItem(icon: SvgPicture.asset('assets/icones/historique.svg',width: 25,height: 25,color: Jaune,), label: "Historique"),
        BottomNavigationBarItem(icon: SvgPicture.asset('assets/icones/profil.svg',width: 25,height: 25,color: Jaune,), label: "Profil"),
      ],
    );
  }
}
