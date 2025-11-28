import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf_app/core/theme/app_theme.dart';
import 'package:pdf_app/features/ai/widgets/screen.dart';
import 'package:pdf_app/features/files/blocs/converter/convert_bloc.dart';
import 'package:pdf_app/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';
import 'package:pdf_app/features/files/blocs/scan_to_pdf/scantopdf_bloc.dart';
import 'package:pdf_app/features/start/welcome_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ScantopdfBloc()),
        BlocProvider(create: (context) => PdfEditorBloc()),
        BlocProvider(create: (context) => PdfConverterBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WelcomeScreen(),
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
