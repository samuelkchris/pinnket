import 'dart:js' as js;

void callJavaScriptMethods() {
  Future.delayed(const Duration(milliseconds: 0), () {
    js.context.callMethod('onFlutterWidgetsLoaded');
    js.context.callMethod('hideLoadingElements');
  });
}
