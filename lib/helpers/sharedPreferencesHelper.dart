import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const SharedPreferencesHelper instance =
      const SharedPreferencesHelper();
  const SharedPreferencesHelper();

  Future<List<String>> readLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'locations';
    final locations = prefs.getStringList(key) ?? [];

    return locations;
  }

  Future<List<String>> writeLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'locations';
    List<String> locations = List<String>();

    locations = prefs.getStringList(key) ?? [];

    locations.add(location);

    await prefs.setStringList(key, locations);

    return locations;
  }

  Future<void> clearLocations() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
