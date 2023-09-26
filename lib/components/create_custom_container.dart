import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget child; // Adicionando a propriedade child

  CustomContainer({required this.child}); // Construtor que recebe o child

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(70),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}
