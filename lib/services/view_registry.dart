// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

void registerViewFactory(String viewId, html.Element Function(int) viewFactory) {
  ui_web.platformViewRegistry.registerViewFactory(viewId, viewFactory);
}
