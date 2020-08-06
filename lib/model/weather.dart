import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final double temp;
  final double humidity;
  final double windSpeed; // m/s
  final double windDeg;
  final String city;
  final dynamic dailyDayTemp;
  final dynamic hourlyTemp;
  final String currentWeatherIcon;

  Weather(
      {this.temp,
      this.humidity,
      this.windSpeed,
      this.windDeg,
      this.city,
      this.dailyDayTemp,
      this.hourlyTemp,
      this.currentWeatherIcon});

  factory Weather.fromJson(Map<String, dynamic> json, String city) {
    final x = Weather(
      temp: json["current"]['temp'].toDouble(),
      humidity: json["current"]['humidity'].toDouble(),
      windSpeed: json["current"]['wind_speed'].toDouble(),
      windDeg: json["current"]['wind_deg'].toDouble(),
      city: city,
      dailyDayTemp: json["daily"].map((day) => day["temp"]["day"]).toList(),
      hourlyTemp: json["hourly"].map((hour) => hour["temp"]).toList(),
      currentWeatherIcon: json["current"]["weather"][0]["icon"],
    );

    return x;
  }

  @override
  List<Object> get props => [
        this.temp,
        this.humidity,
        this.windSpeed,
        this.windDeg,
        this.city,
        this.dailyDayTemp,
        this.hourlyTemp,
        this.currentWeatherIcon,
      ];
}
