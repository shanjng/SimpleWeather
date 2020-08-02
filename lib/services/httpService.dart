import 'dart:convert';
import 'package:first_test/helpers/fileDataHelper.dart';
import 'package:http/http.dart' as http;
import 'package:first_test/model/weather.dart';
import 'package:first_test/constants.dart';

abstract class IHttpService {
  Future<Weather> fetchWeather(String city);
}

class HttpService implements IHttpService {
  @override
  Future<Weather> fetchWeather(String city) async {
    // final decodedCity = city.split(', ')[0];
    final jsonString =
        await FileDataHelper.instance.getFileData('assets/maps/city.list.json');
    final data = json.decode(jsonString);
    var lat;
    var lon;

    for (var obj in data) {
      if (obj["name"] == city) {
        lat = obj["coord"]["lat"];
        lon = obj["coord"]["lon"];
      }
    }

    final response = await http.get(
        '$BASE_URL?lat=$lat&lon=$lon&units=imperial&exclude=minutely&appid=$API_KEY');

    if (response.statusCode == 200) {
      final jsonDecoded = json.decode(response.body);
      final weather = Weather.fromJson(jsonDecoded, city);
      return weather;
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
