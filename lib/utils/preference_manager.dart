import 'package:shared_preferences/shared_preferences.dart';
import 'package:jande/utils/constants.dart';

class PreferenceManager {
  SharedPreferences? _prefs;
  static final PreferenceManager _instance = PreferenceManager._internal();
  factory PreferenceManager() => _instance;

  PreferenceManager._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  setPrefItem(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future getPrefItem(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key);
    return value;
  }

  setFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  removeAllPrefItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
