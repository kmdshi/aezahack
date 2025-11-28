import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['OPENAI_API_KEY'];
  OpenAI.apiKey = apiKey ?? '';

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
