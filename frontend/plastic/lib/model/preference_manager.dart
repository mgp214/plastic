import 'package:shared_preferences/shared_preferences.dart';

class PreferenceManager {
  static final PreferenceManager _singleton = PreferenceManager._internal();

  factory PreferenceManager() {
    return _singleton;
  }

  SharedPreferences _preferences;

  PreferenceManager._internal();

  Future<void> loadPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  SharedPreferences get() => _preferences;
}
