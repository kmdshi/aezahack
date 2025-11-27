// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:camera_web/camera_web.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner_web.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:ios_color_picker/ios_color_picker_web.dart';
import 'package:pdfx/src/renderer/web/pdfx_plugin.dart';
import 'package:share_plus/src/share_plus_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  CameraPlugin.registerWith(registrar);
  FilePickerWeb.registerWith(registrar);
  FlutterDocScannerWeb.registerWith(registrar);
  ImagePickerPlugin.registerWith(registrar);
  IosColorPickerWeb.registerWith(registrar);
  PdfxPlugin.registerWith(registrar);
  SharePlusWebPlugin.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
