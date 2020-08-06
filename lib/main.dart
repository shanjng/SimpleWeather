import 'package:first_test/services/httpService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/weather_bloc.dart';
import 'screens/home.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Weather',
      theme: ThemeData(
        fontFamily: 'Filson',
      ),
      home: BlocProvider.value(
        value: WeatherBloc(HttpService()),
        child: Home(),
      ),
    );
  }
}
