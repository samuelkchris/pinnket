import 'package:hive/hive.dart';

mixin FooterStatePersistenceMixin {
  static const String _boxName = 'footerStateBox';
  static const String _selectedDocKey = 'selectedDoc';
  static const String _selectedNavItemKey = 'selectedNavItem';
  static const String _titleKey = 'title';

  Future<void> initHive() async {
    await Hive.openBox(_boxName);
  }

  Future<void> saveFooterState({
    required String? selectedDoc,
    required int selectedNavItem,
    required String title,
  }) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_selectedDocKey, selectedDoc);
    await box.put(_selectedNavItemKey, selectedNavItem);
    await box.put(_titleKey, title);
  }

  Future<Map<String, dynamic>> loadFooterState() async {
    final box = await Hive.openBox(_boxName);
    return {
      'selectedDoc': box.get(_selectedDocKey),
      'selectedNavItem': box.get(_selectedNavItemKey, defaultValue: 0),
      'title': box.get(_titleKey, defaultValue: ''),
    };
  }

  Future<void> clearFooterState() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }
}