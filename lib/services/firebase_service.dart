import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static Future<void> logPageView(String pageName) async {
    await analytics.logEvent(
      name: 'page_view',
      parameters: {'page_name': pageName},
    );
  }
}
