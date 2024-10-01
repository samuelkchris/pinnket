import 'package:flutter/foundation.dart';
import '../mixins/selected_event_mixin.dart';
import '../models/event_models.dart';

class SelectedEventProvider extends ChangeNotifier with HivePersistenceMixin {
  Event? _selectedEvent;

  SelectedEventProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await initHive();
    await _loadSelectedEvent();
  }

  Event? get selectedEvent => _selectedEvent;

  Future<void> setSelectedEvent(Event event) async {
    _selectedEvent = event;
    await saveSelectedEvent(event);
    notifyListeners();
  }

  Future<void> clearSelectedEvent() async {
    _selectedEvent = null;
    await clearSavedEvent();
    notifyListeners();
  }

  bool isEventSelected(String eventId) {
    return _selectedEvent?.eid == eventId;
  }

  Future<void> _loadSelectedEvent() async {
    _selectedEvent = await loadSelectedEvent();
    notifyListeners();
  }
}
