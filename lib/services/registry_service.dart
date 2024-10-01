import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

class Registries {
  static void registerRedDivFactory() {
    ui_web.platformViewRegistry.registerViewFactory(
        "video-capture",
        (int viewId, {Object? params}) => web.HTMLDivElement()
          ..append(web.HTMLVideoElement()
            ..setAttribute('autoplay', '')
            ..setAttribute('muted', '')
            ..setAttribute('playsinline', ''))
          ..append(web.HTMLButtonElement()
            ..text = 'Capture'
            ..onClick.listen((event) {
              final videoElement =
                  web.document.querySelector('video') as web.HTMLVideoElement;
              final canvasElement =
                  web.document.createElement('canvas') as web.HTMLCanvasElement
                    ..width = videoElement.videoWidth
                    ..height = videoElement.videoHeight;
              canvasElement.context2D.drawImage(videoElement, 0, 0);
              final imageDataUrl = canvasElement.toDataUrl('image/png');
              final anchorElement =
                  web.document.createElement('a') as web.HTMLAnchorElement
                    ..href = imageDataUrl
                    ..download = 'screenshot.png'
                    ..click();
              return;
            })));
  }
}
