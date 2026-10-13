
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'web_content_stub.dart'
    if (dart.library.html) 'web_content_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NutriBowlApp());

  // Test the Firestore connection without blocking the UI.
  _testFirestoreConnection();
}

Future<void> _testFirestoreConnection() async {
  try {
    final result = await FirebaseFirestore.instance
        .collection('food_items')
        .get();

    debugPrint(
      'Firebase connected successfully. '
      'Food documents found: ${result.docs.length}',
    );

    for (final doc in result.docs) {
      debugPrint('Food document: ${doc.id} -> ${doc.data()}');
    }
  } catch (error) {
    debugPrint('Firebase Firestore error: $error');
  }
}

class NutriBowlApp extends StatelessWidget {
  const NutriBowlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriBowl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF174D38),
        ),
        useMaterial3: true,
      ),
      home: kIsWeb
          ? const NutriBowlWebContent()
          : const NutriBowlWebView(),
    );
  }
}

class NutriBowlWebView extends StatefulWidget {
  const NutriBowlWebView({super.key});

  @override
  State<NutriBowlWebView> createState() =>
      _NutriBowlWebViewState();
}

class _NutriBowlWebViewState extends State<NutriBowlWebView> {
  late final WebViewController _controller;
  bool _loading = true;
  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() => _progress = progress);
            }
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _loading = true);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
          onWebResourceError: (error) {
            debugPrint(
              'NutriBowl WebView resource error: '
              '${error.description}',
            );
          },
        ),
      )
      ..loadFlutterAsset('assets/nutribowl/index.html');
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await _handleBack();

          if (shouldExit && context.mounted) {
            Navigator.of(context).maybePop();
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_loading)
                Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(
                    value: _progress / 100,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
