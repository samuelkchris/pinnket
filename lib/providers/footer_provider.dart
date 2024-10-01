import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pinnket/screens/profile/ticket_purchases_screen.dart';

import '../mixins/footer_state_persistence_mixin.dart';

class FooterStateModel extends ChangeNotifier with FooterStatePersistenceMixin {
  String? _selectedDoc;
  int _selectedNavItem = 0;
  String _title = '';

  Widget  _selectedProfilePage = const TicketPurchasesScreen();

  String? get selectedDoc => _selectedDoc;
  int get selectedNavItem => _selectedNavItem;
  String get title => _title;

  Widget get selectedProfilePage => _selectedProfilePage;

  FooterStateModel() {
    _loadState();
  }

  Future<void> _loadState() async {
    await initHive();
    final savedState = await loadFooterState();
    _selectedDoc = savedState['selectedDoc'];
    _selectedNavItem = savedState['selectedNavItem'];
    _title = savedState['title'];
    notifyListeners();
  }

  void setSelectedDoc(String doc) {
    _selectedDoc = doc;
    _saveState();
    notifyListeners();
  }

  void setSelectedNavItem(int index) {
    _selectedNavItem = index;
    _saveState();
    notifyListeners();
  }

  void setTitle(String newTitle) {
    _title = newTitle;
    _saveState();
    notifyListeners();
  }

  Future<void> _saveState() async {
    await saveFooterState(
      selectedDoc: _selectedDoc,
      selectedNavItem: _selectedNavItem,
      title: _title,
    );
  }

  Future<void> clearState() async {
    await clearFooterState();
    _selectedDoc = null;
    _selectedNavItem = 0;
    _title = '';
    notifyListeners();
  }

  void updateProfilePage(Widget page) {
    _selectedProfilePage = page;
    notifyListeners();
  }
}