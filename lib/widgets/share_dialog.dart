import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/toast_service.dart';

class SlidingShareDrawer extends StatelessWidget {
  final String eventName;
  final String eventDescription;
  final String eventImageUrl;
  final String baseUrl;

  const SlidingShareDrawer({
    super.key,
    required this.eventName,
    required this.eventDescription,
    required this.eventImageUrl,
    required this.baseUrl,
  });

  String get eventUrl {
    final queryParams = {
      'name': eventName,
      'description': eventDescription,
      'image': eventImageUrl,
    };
    final encodedParams = queryParams.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$baseUrl?$encodedParams';
  }

  String get embedCode {
    return '''
<iframe 
  src="$baseUrl" 
  width="100%" 
  height="600" 
  frameborder="0">
</iframe>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 300,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share Event',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  eventName,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildShareButton(
                        context,
                        'Facebook',
                        FontAwesomeIcons.facebookF,
                        const Color(0xFF1877F2),
                        () => _shareToFacebook(eventUrl)),
                    _buildShareButton(
                        context,
                        'Twitter',
                        FontAwesomeIcons.twitter,
                        const Color(0xFF1DA1F2),
                        () => _shareToTwitter(eventName, eventUrl)),
                    _buildShareButton(
                        context,
                        'LinkedIn',
                        FontAwesomeIcons.linkedinIn,
                        const Color(0xFF0A66C2),
                        () => _shareToLinkedIn(eventUrl)),
                    _buildShareButton(
                        context,
                        'WhatsApp',
                        FontAwesomeIcons.whatsapp,
                        const Color(0xFF25D366),
                        () => _shareToWhatsApp(eventName, eventUrl)),
                    _buildShareButton(
                        context,
                        'Instagram',
                        FontAwesomeIcons.instagram,
                        const Color(0xFFE4405F),
                        () => _shareToInstagram(context, eventUrl)),
                    _buildShareButton(
                        context,
                        'Email',
                        FontAwesomeIcons.envelope,
                        Colors.red,
                        () => _shareViaEmail(eventName, eventUrl)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(text: eventUrl),
                      decoration: InputDecoration(
                        labelText: 'Share URL',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        suffixIcon: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.copy, size: 20),
                          onPressed: () => _copyToClipboard(context, eventUrl),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      maxLines: 4,
                      controller: TextEditingController(text: embedCode),
                      decoration: InputDecoration(
                        labelText: 'Embed Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        suffixIcon: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.copy, size: 20),
                          onPressed: () => _copyToClipboard(context, embedCode),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _copyToClipboard(context, embedCode),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Copy Embed Code'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _shareToFacebook(String url) async {
    final facebookUrl = 'https://www.facebook.com/sharer/sharer.php?u=$url';
    if (await canLaunch(facebookUrl)) {
      await launch(facebookUrl);
    }
  }

  void _shareToTwitter(String eventName, String url) async {
    final encodedEventName = Uri.encodeComponent(eventName);
    final encodedUrl = Uri.encodeComponent(url);
    final twitterUrl =
        'https://twitter.com/intent/tweet?text=Check%20out%20$encodedEventName&url=$encodedUrl';
    if (await canLaunch(twitterUrl)) {
      await launch(twitterUrl);
    }
  }

  void _shareToLinkedIn(String url) async {
    final encodedUrl = Uri.encodeComponent(url);
    final linkedInUrl =
        'https://www.linkedin.com/sharing/share-offsite/?url=$encodedUrl';
    if (await canLaunch(linkedInUrl)) {
      await launch(linkedInUrl);
    }
  }

  void _shareToWhatsApp(String eventName, String url) async {
    final encodedUrl = Uri.encodeComponent(url);
    final whatsappUrl =
        'https://api.whatsapp.com/send?text=Check%20out%20$eventName:%20$encodedUrl';
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    }
  }

  void _shareToInstagram(BuildContext context, String url) {
    _copyToClipboard(context, url);
    ToastManager().showInfoToast(context,
        'Link copied. Open Instagram and paste in your story or post.');
  }

  void _shareViaEmail(String eventName, String url) async {
    final emailUrl =
        'mailto:?subject=Check out this event: $eventName&body=I thought you might be interested in this event: $url';
    if (await canLaunch(emailUrl)) {
      await launch(emailUrl);
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ToastManager().showInfoToast(context, 'Copied to clipboard');
  }
}
