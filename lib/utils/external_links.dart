import 'package:url_launcher/url_launcher.dart';

class ExternalLinks {
  Future openLink(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
