import 'package:flutter/material.dart';

class FavoriteModel extends ChangeNotifier {
  final List<int> ids = [];

  void addID(int id) {
    ids.add(id);
    notifyListeners();
  }

  void removeID(int id) {
    ids.remove(id);
    notifyListeners();
  }
}
