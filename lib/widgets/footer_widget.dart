import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import '../providers/footer_provider.dart';
import '../utils/external_links.dart';

class FooterWidget extends StatelessWidget {
  final double fontSize;
  final Uri url;
  final Uri url1;

  const FooterWidget({
    super.key,
    required this.fontSize,
    required this.url,
    required this.url1,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final year = DateTime.now().year;
    final theme = Theme.of(context);

    return Consumer<FooterStateModel>(
      builder: (context, provider, child) {
        return Container(
          width: size.width,
          height: 20,
          alignment: Alignment.center,
          color: theme.primaryColor, // Use theme color here
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              text: '© Copyright PinnKET $year. All Rights Reserved ',
              children: [
                TextSpan(
                  text: 'PinniTAGS from ',
                  style: TextStyle(
                    fontFamily: 'Segoe UI',
                    color: theme.colorScheme.surface,
                    fontSize: fontSize,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      ExternalLinks().openLink(url);
                    },
                ),
                TextSpan(
                  text: 'PinniSOFT',
                  style: TextStyle(
                    fontFamily: 'Segoe UI',
                    color: theme.colorScheme.surface,
                    fontSize: fontSize,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      ExternalLinks().openLink(url1);
                    },
                ),
              ],
            ),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
            ),
          ),
        );
      },
    );
  }
}