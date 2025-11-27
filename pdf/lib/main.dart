import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_app/core/widgets/app.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

privacy() {
  launchUrl(
    Uri.parse(
      'https://docs.google.com/document/d/1dZBRwz6RAPKlCr8Vx_lv_RBnfNuaZ0sQjYZYWlUX4wA/edit?usp=sharing',
    ),
  );
}

terms() {
  launchUrl(
    Uri.parse(
      'https://docs.google.com/document/d/17O-9eCc3wivaRSKnaqeB6S7ltSEPsmSf1hQjZe5k7GA/edit?usp=sharing',
    ),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(ToastificationWrapper(child: const App()));
}
