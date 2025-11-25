import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf_app/core/theme/app_theme.dart';
import 'package:pdf_app/core/widgets/root_screen.dart';
import 'package:pdf_app/features/files/blocs/pdf_editor/pdf_editor_bloc.dart';
import 'package:pdf_app/features/files/blocs/scan_to_pdf/scantopdf_bloc.dart';

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
      ],
      child: MaterialApp(home: RootScreen(), theme: AppTheme.lightTheme),
    );
  }
}
