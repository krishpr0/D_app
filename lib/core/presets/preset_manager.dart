import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'preset_model.dart';

class PresetManager {
  static Future<String> get _path async {
        final dir = await getApplicationDocumentsDirectory();
        return "${dir.path}/presets.json";
  }

  static Future<List<Preset>> load() async {
    try {
      final file = File(await _path);
      if (!await file.exists()) return [];
      final json = jsonDecode(await file.readAsString());
      return (json as List).map((e) => Preset.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> save(List<Preset> presets) async {
    final file = File(await _path);
    await file.writeAsString(jsonEncode(presets.map((p) => p.toJson()).toList()));
  }
}