import 'package:flutter/material.dart';

class DropdownWidget extends StatelessWidget {
  final Widget child;
  const DropdownWidget(
      {required Key key,
        required this.child,
        required TextEditingController controller
      }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top:5, left:0, right:0, bottom: 0),
      padding: EdgeInsets.only(top:0, bottom: 2),
      child: child,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
    );
  }
}