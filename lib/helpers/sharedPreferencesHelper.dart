import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const SharedPreferencesHelper instance =
      const SharedPreferencesHelper();
  const SharedPreferencesHelper();

  Future<List<String>> readLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'locations';
    final value = prefs.getStringList(key);

    return value;
  }

  Future<bool> writeLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'locations';
    List<String> list = List<String>();

    list = prefs.getStringList(key) ?? [];

    list.add(location);

    return await prefs.setStringList(key, list);
  }

  Future<void> clearLocations() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
