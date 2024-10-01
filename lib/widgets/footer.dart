// footer.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'mobile_footer.dart';
import 'desktop_footer.dart';

class Footer extends StatelessWidget {
  Footer({super.key});

  final socials = [
    {
      'icon': const Icon(Icons.facebook, color: Colors.white),
      'url': 'https://www.facebook.com/people/Pinnket/61559929811699/'
    },
    {
      'icon': const FaIcon(FontAwesomeIcons.youtube, color: Colors.white),
      'url': 'https://www.youtube.com/@Pinnket-lx1lm'
    },
    {
      'icon': const FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
      'url': 'https://www.instagram.com/pinnket1/?hl=en'
    },
    {
      'icon': const FaIcon(FontAwesomeIcons.xTwitter, color: Colors.white),
      'url': 'https://twitter.com/PinnKET_'
    },
    {
      'icon': const FaIcon(FontAwesomeIcons.tiktok, color: Colors.white),
      'url': 'https://www.tiktok.com/@pinnket7'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > 600) {
          return DesktopFooter(socials: socials);
        } else {
          return MobileFooter(socials: socials);
        }
      },
    );
  }
}