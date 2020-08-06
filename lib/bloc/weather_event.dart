part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
}

class LoadInitialData extends WeatherEvent {
  const LoadInitialData();

  @override
  List<Object> get props => [];
}

class AddCity extends WeatherEvent {
  final String cityString;
  final List<Weather> weatherData;
  final List<String> cities;

  const AddCity(this.cityString, this.weatherData, this.cities);

  @override
  List<Object> get props => [cityString, weatherData, cities];
}
