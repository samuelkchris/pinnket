import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:html' as html;

Future<void> generateAndDownloadShareImage(
    BuildContext context,
    String title,
    String eventUrl,
    String bannerImageUrl,
    bool isDonate,
    String eventNumber, {
      bool? isDonateOnly,
    }) async {
  // Define image size (1:1 aspect ratio)
  const double size = 1080;

  // Create a PictureRecorder and Canvas
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  // Load and draw background image with blur effect
  final backgroundImage = await _loadNetworkImage(bannerImageUrl);
  if (backgroundImage != null) {
    canvas.drawImageRect(
      backgroundImage,
      Rect.fromLTWH(0, 0, backgroundImage.width.toDouble(), backgroundImage.height.toDouble()),
      const Rect.fromLTWH(0, 0, size, size),
      Paint()..filterQuality = FilterQuality.high,
    );

    // Add a semi-transparent overlay to ensure text visibility
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, size, size),
      Paint()..color = Colors.black.withOpacity(0.4),
    );
  } else {
    print('Background image is null, filling with solid color.');
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, size, size),
      Paint()..color = Colors.black,
    );
  }

  // Draw title
  final titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 48,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.5), offset: const Offset(2, 2)),
    ],
  );
  _drawText(canvas, title.toUpperCase(), titleStyle, size * 0.9, const Offset(size * 0.05, size * 0.05));

  // Draw "SCAN TO BOOK/DONATE" text
  final actionStyle = TextStyle(
    color: Colors.white,
    fontSize: 36,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.5), offset: const Offset(2, 2)),
    ],
  );
  final actionText = isDonate ? 'SCAN TO DONATE NOW' : 'SCAN TO BOOK NOW';
  _drawText(canvas, actionText, actionStyle, size * 0.9, const Offset(size * 0.05, size * 0.3));

  // Generate and draw QR code with white background
  const qrSize = size * 0.45;
  const qrBackgroundSize = qrSize + 20; // Add some padding
  final qrBackgroundRect = Rect.fromCenter(
    center: const Offset(size / 2, size * 0.6),  // Moved down to accommodate the action text
    width: qrBackgroundSize,
    height: qrBackgroundSize,
  );

  // Draw white background for QR code
  canvas.drawRect(
    qrBackgroundRect,
    Paint()..color = Colors.white,
  );

  final qrCode = await QrPainter(
    data: eventUrl,
    version: QrVersions.auto,
    color: Colors.black,
    emptyColor: Colors.white,
    gapless: false,
    embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(80, 80)),
  ).toImage(qrSize.toInt().toDouble());

  canvas.drawImage(qrCode, const Offset(size / 2 - qrSize / 2, size * 0.6 - qrSize / 2), Paint());

  // Define the dial text style
  final dialTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    shadows: [
      Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.5), offset: const Offset(2, 2)),
    ],
  );

  // Draw the container and text for dialing instructions
  final primaryColor = Theme.of(context).colorScheme.primary;
  final dialText = 'OR DIAL *217*413# \nUSE $eventNumber AS EVENT ID';
  final textSpan = TextSpan(text: dialText, style: dialTextStyle);
  final textPainter = TextPainter(
    text: textSpan,
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout(minWidth: qrSize, maxWidth: qrSize);
  final double textHeight = textPainter.height;
  const double yPosition = size * 0.85;

  canvas.drawRect(
    Rect.fromLTWH(size * 0.1, yPosition - 10, size * 0.8, textHeight + 20),
    Paint()..color = primaryColor,
  );

  _drawText(canvas, dialText, dialTextStyle, size * 0.8, const Offset(size * 0.1, yPosition));

  // Draw "WWW.PINNKET.COM" text
  final websiteTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    shadows: [
      Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.5), offset: const Offset(2, 2)),
    ],
  );
  _drawText(canvas, 'www.pinnket.com', websiteTextStyle, size * 0.8, const Offset(size * 0.1, size * 0.95));

  // Convert canvas to image
  final img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
  final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

  // Trigger download
  final blob = html.Blob([pngBytes!.buffer.asUint8List()], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "${title.replaceAll(' ', '_')}.png")
    ..click();
  html.Url.revokeObjectUrl(url);
}

void _drawText(Canvas canvas, String text, TextStyle style, double maxWidth, Offset offset) {
  final textSpan = TextSpan(text: text, style: style);
  final textPainter = TextPainter(
    text: textSpan,
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout(minWidth: maxWidth, maxWidth: maxWidth);
  textPainter.paint(canvas, offset);
}

Future<ui.Image?> _loadNetworkImage(String url) async {
  final Completer<ui.Image> completer = Completer();
  final NetworkImage image = NetworkImage(url);
  image.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener((ImageInfo info, bool _) {
      print('Image loaded successfully: $url');
      completer.complete(info.image);
    }, onError: (dynamic error, StackTrace? stackTrace) {
      print('Error loading image: $error');
      completer.completeError(error);
    }),
  );
  return completer.future;
}