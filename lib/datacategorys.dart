import 'package:flutter/material.dart';

class AddCategory {
  final List<Map<String, IconData>> addIcons = [
    {'월급': Icons.wallet_outlined},
    {'용돈': Icons.money},
    {'기타': Icons.eject_outlined},
  ];
}

class MinusCategory {
  final List<Map<String, IconData>> MinusIcons = [
    {'식비': Icons.fastfood},
    {'생활용품': Icons.shopping_cart_outlined},
    {'교통우류비': Icons.directions_bus_outlined},
    {'문화생활비': Icons.library_books_outlined},
    {'의류미용비': Icons.face_2_outlined},
    {'의료/건강': Icons.health_and_safety_outlined},
    {'경조비': Icons.account_balance_wallet_outlined},
    {'기타': Icons.add_chart},
  ];
}
