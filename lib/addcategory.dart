import 'package:flutter/material.dart';

class AddCategory {
  // 아이콘 데이터를 배열로 관리
  final List<Map<String, IconData>> addIcons = [
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
