import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class NutriBowlWebContent extends StatelessWidget {
  const NutriBowlWebContent({super.key});

  static bool _registered = false;
  static const String _viewType = 'nutribowl-html-content';

  static void _registerView() {
    if (_registered) return;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final frame = html.IFrameElement()
        ..src = 'assets/assets/nutribowl/index.html'
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'geolocation; clipboard-read; clipboard-write';
      return frame;
    });
    _registered = true;
  }

  @override
  Widget build(BuildContext context) {
    _registerView();
    return const Scaffold(
      body: SafeArea(
        child: SizedBox.expand(child: HtmlElementView(viewType: _viewType)),
      ),
    );
  }
}
