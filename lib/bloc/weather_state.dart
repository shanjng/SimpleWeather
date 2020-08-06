part of 'weather_bloc.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();
}

class WeatherInitial extends WeatherState {
  final List<String> locations;
  final List<Weather> weatherData;
  final List<String> cities;

  const WeatherInitial(this.locations, this.weatherData, this.cities);

  @override
  List<Object> get props => [locations, weatherData];
}

class WeatherLoading extends WeatherState {
  @override
  List<Object> get props => [];
}
