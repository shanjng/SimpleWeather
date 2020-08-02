import 'dart:convert';

import 'fileDataHelper.dart';

class GetCitiesHelper {
  static const GetCitiesHelper instance = const GetCitiesHelper();
  const GetCitiesHelper();

  Future<List<String>> getCities() async {
    final jsonString =
        await FileDataHelper.instance.getFileData('assets/maps/city.list.json');
    final data = json.decode(jsonString);

    List<String> cities = [];

    for (var obj in data) {
      String city = obj['name'];
      if (obj['state'] != '') {
        city += ", " + obj['state'];
      }
      if (obj['country'] != '') {
        city += ", " + obj['country'];
      }

      cities.add(city);
    }

    return cities;
  }
}
