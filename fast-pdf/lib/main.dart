import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fast_pdf/core/widgets/app.dart';
import 'package:url_launcher/url_launcher.dart';

privacy() {
  launchUrl(
    Uri.parse(
      'https://docs.google.com/document/d/1I2f2O26bApsgd9oCMAG9k1JlYW7z6kjhIaceJeTKbnE/edit?usp=sharing',
    ),
  );
}

terms() {
  launchUrl(
    Uri.parse(
      'https://docs.google.com/document/d/1LdjWkT-RNmvl7reid8KQuLj2pmFCVoG4hAvBRoXts14/edit?usp=sharing',
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

  runApp(const App());
}
