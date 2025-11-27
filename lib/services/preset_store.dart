import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PresetStore {
  static const _keyCurrent = 'eq_current_bands';
  static const _keyPresets = 'eq_presets';

  final SharedPreferences _prefs;

  PresetStore(this._prefs);

  List<double> loadCurrent(int bandsCount) {
    final s = _prefs.getString(_keyCurrent);
    if (s == null) return List<double>.filled(bandsCount, 0.0);
    final List<dynamic> arr = jsonDecode(s);
    return List<double>.generate(bandsCount, (i) => (i < arr.length ? (arr[i] as num).toDouble() : 0.0));
  }

  Future<void> saveCurrent(List<double> bands) async {
    await _prefs.setString(_keyCurrent, jsonEncode(bands));
  }

  Future<void> savePreset(String name, List<double> bands) async {
    final map = _prefs.getString(_keyPresets);
    final m = map == null ? <String, dynamic>{} : jsonDecode(map) as Map<String, dynamic>;
    m[name] = bands;
    await _prefs.setString(_keyPresets, jsonEncode(m));
  }

  Map<String, List<double>> loadPresets() {
    final map = _prefs.getString(_keyPresets);
    if (map == null) return {};
    final decoded = jsonDecode(map) as Map<String, dynamic>;
    final out = <String, List<double>>{};
    decoded.forEach((k, v) {
      final arr = v as List<dynamic>;
      out[k] = arr.map((e) => (e as num).toDouble()).toList();
    });
    return out;
  }

  /// Convenience: return the preset names in storage.
  Future<List<String>> getPresetNames() async {
    final map = loadPresets();
    return map.keys.toList();
  }

  /// Load a single preset by name. Returns empty list if not found.
  Future<List<double>> loadPreset(String name) async {
    final map = loadPresets();
    return map[name] ?? [];
  }

  /// Delete a preset by name.
  Future<void> deletePreset(String name) async {
    final map = loadPresets();
    if (map.containsKey(name)) {
      map.remove(name);
      await _prefs.setString(_keyPresets, jsonEncode(map));
    }
  }

  // Animated background preference
  static const _keyBgEnabled = 'eq_bg_enabled';

  bool loadBgEnabled() {
    return _prefs.getBool(_keyBgEnabled) ?? true;
  }

  Future<void> saveBgEnabled(bool enabled) async {
    await _prefs.setBool(_keyBgEnabled, enabled);
  }

  // Low power mode preference
  static const _keyLowPower = 'eq_low_power';

  bool loadLowPower() {
    return _prefs.getBool(_keyLowPower) ?? false;
  }

  Future<void> saveLowPower(bool enabled) async {
    await _prefs.setBool(_keyLowPower, enabled);
  }
}
