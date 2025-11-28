import 'package:shared_preferences/shared_preferences.dart';


class RecentFilesService {
  static const _key = 'recent_files';

  static Future<void> add(String path) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> recent = prefs.getStringList(_key) ?? [];

    recent.remove(path);

    recent.insert(0, path);

    if (recent.length > 20) {
      recent = recent.sublist(0, 20);
    }

    await prefs.setStringList(_key, recent);
  }

  static Future<List<String>> getRecent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}