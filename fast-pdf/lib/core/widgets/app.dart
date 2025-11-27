import 'package:fast_pdf/core/widgets/root_screen.dart';
import 'package:fast_pdf/features/files/blocs/converter/convert_bloc.dart';
import 'package:fast_pdf/features/files/blocs/scan/scan_bloc.dart';
import 'package:fast_pdf/features/start/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fast_pdf/core/theme/app_theme.dart';
import 'package:fast_pdf/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';

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
        BlocProvider(create: (context) => PdfEditorBloc()),
        BlocProvider(create: (context) => ScanBloc()),
        BlocProvider(create: (context) => PdfConverterBloc()),
      ],
      child: MaterialApp(home: WelcomeScreen(), theme: AppTheme.lightTheme),
    );
  }
}
