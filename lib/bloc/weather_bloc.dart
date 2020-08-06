import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:first_test/helpers/getCities.dart';
import 'package:first_test/helpers/sharedPreferencesHelper.dart';
import 'package:first_test/model/weather.dart';
import 'package:first_test/services/httpService.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final IHttpService _httpService;

  WeatherBloc(this._httpService) : super(WeatherInitial([], [], []));

  @override
  Stream<WeatherState> mapEventToState(
    WeatherEvent event,
  ) async* {
    if (event is LoadInitialData) {
      yield WeatherLoading();
      final locations = await SharedPreferencesHelper.instance.readLocations();

      final List<Future<Weather>> requests = [];
      List<Weather> weatherData = [];

      if (locations != null) {
        for (String location in locations) {
          final splits = location.split(',').toList();
          requests.add(_httpService.getWeather(splits.first.trim()));
          location = splits.first.trim();
        }

        weatherData = await Future.wait(requests);
      }

      final cities = await GetCitiesHelper.instance.getCities();

      yield WeatherInitial(locations, weatherData, cities);
    } else if (event is AddCity) {
      final city = event.cityString.split(',').toList().first.trim();

      final locations = await SharedPreferencesHelper.instance
          .writeLocation(event.cityString);

      final weather = await _httpService.getWeather(city);
      final weatherDataUpdated = [...event.weatherData, weather];

      yield WeatherInitial(locations, weatherDataUpdated, event.cities);
    }
  }
}
