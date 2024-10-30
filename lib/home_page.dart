import 'package:flutter/material.dart';

class TryOnPage extends StatelessWidget {
  const TryOnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F9), // Light background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            print(' button 1 ');
            // Handle back button
          },
        ),
        title: const Text('Provar', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Selecione a peça de roupa desejada',
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          CustomButton(
            text: 'Carregar\nda galeria',
            color: const Color(0xFF6B4C7A),
            onPressed: () {
              print(' press button 2');
              // Handle "Carregar da galeria" button press
            },
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Carregar\ndo guarda roupa',
            color: const Color(0xFF4C3F58),
            onPressed: () {
              // Handle "Carregar do guarda roupa" button press
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'MyCloset',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const CustomButton(
      {super.key,
      required this.text,
      required this.color,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
