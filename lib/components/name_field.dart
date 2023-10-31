import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  final TextEditingController controller;

  NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Seu nome',
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        prefixIcon: Icon(Icons.person),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
      ),
      controller: controller,
    );
  }
}
