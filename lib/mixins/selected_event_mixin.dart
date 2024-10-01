import 'package:hive/hive.dart';
import 'dart:convert';
import '../models/event_models.dart';

mixin HivePersistenceMixin {
  static const String _boxName = 'selected_event_box';
  static const String _eventKey = 'selected_event';

  Future<void> initHive() async {
    await Hive.openBox(_boxName);
  }

  Future<void> saveSelectedEvent(Event event) async {
    final box = await Hive.openBox(_boxName);
    final eventJsonString = jsonEncode(event.toJson());
    await box.put(_eventKey, eventJsonString);
  }

  Future<Event?> loadSelectedEvent() async {
    final box = await Hive.openBox(_boxName);
    final eventJsonString = box.get(_eventKey);
    if (eventJsonString != null) {
      print('Retrieved event JSON: $eventJsonString'); // Debug log
      final eventJson = jsonDecode(eventJsonString);
      print('Decoded event JSON: $eventJson'); // Debug log
      try {
        return Event.fromJson(eventJson);
      } catch (e) {
        print('Error parsing event: $e'); // Debug log
        return null;
      }
    }
    return null;
  }

  Future<void> clearSavedEvent() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_eventKey);
  }
}