import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/event_models.dart';

mixin TicketSelectionPersistenceMixin on ChangeNotifier {
  static const String _boxName = 'ticketSelectionBox';
  static const String _key = 'ticketSelectionState';

  late Box<Map> _box;

  String? _selectedZoneId;
  String? _selectedZoneName;
  int _ticketCount = 1;
  int _selectedCategoryCost = 0;
  int _selectedZoneTotalCost = 0;
  EventZone? _selectedZone;

  String? get selectedZoneId => _selectedZoneId;
  String? get selectedZoneName => _selectedZoneName;
  int get ticketCount => _ticketCount;
  int get selectedCategoryCost => _selectedCategoryCost;
  int get selectedZoneTotalCost => _selectedZoneTotalCost;
  EventZone? get selectedZone => _selectedZone;

  Future<void> initHive() async {
    _box = await Hive.openBox<Map>(_boxName);
    _loadState();
  }

  void _loadState() {
    final savedState = _box.get(_key);
    if (savedState != null) {
      setFromJson(savedState.cast<String, dynamic>());
    }
  }

  void _saveState() {
    _box.put(_key, toJson());
  }

  void setSelectedZoneName(String zoneName) {
    _selectedZoneName = zoneName;
    _saveState();
    notifyListeners();
  }

  void setSelectedZoneId(String zoneId) {
    _selectedZoneId = zoneId;
    _updateTotalCost();
    _saveState();
    notifyListeners();
  }

  void setTicketCount(int count) {
    _ticketCount = count;
    _updateTotalCost();
    _saveState();
    notifyListeners();
  }

  void setSelectedCategoryCost(int cost) {
    _selectedCategoryCost = cost;
    _updateTotalCost();
    _saveState();
    notifyListeners();
  }

  void _updateTotalCost() {
    _selectedZoneTotalCost = _selectedCategoryCost * _ticketCount;
  }

  void setSelectedZone(EventZone zone) {
    _selectedZone = zone;
    _saveState();
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedZoneId': _selectedZoneId,
      'selectedZoneName': _selectedZoneName,
      'ticketCount': _ticketCount,
      'selectedCategoryCost': _selectedCategoryCost,
      'selectedZoneTotalCost': _selectedZoneTotalCost,
      'selectedZone': _selectedZone?.toJson(),
    };
  }

  void reset() {
    _selectedZoneId = null;
    _selectedZoneName = null;
    _ticketCount = 1;
    _selectedCategoryCost = 0;
    _selectedZoneTotalCost = 0;
    _selectedZone = null;
    _saveState();
    notifyListeners();
  }

  void setFromJson(Map<String, dynamic> json) {
    _selectedZoneId = json['selectedZoneId'] as String?;
    _selectedZoneName = json['selectedZoneName'] as String?;
    _ticketCount = json['ticketCount'] as int;
    _selectedCategoryCost = json['selectedCategoryCost'] as int;
    _selectedZoneTotalCost = json['selectedZoneTotalCost'] as int;
    _selectedZone = json['selectedZone'] != null
        ? EventZone.fromJson(json['selectedZone'] as Map<String, dynamic>)
        : null;
    notifyListeners();
  }
}