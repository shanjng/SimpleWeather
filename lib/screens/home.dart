import 'dart:ui';
import 'package:first_test/bloc/weather_bloc.dart';
import 'package:first_test/constants.dart';
import 'package:first_test/helpers/directionsHelper.dart';
import 'package:first_test/helpers/sharedPreferencesHelper.dart';
import 'package:first_test/model/weather.dart';
import 'package:first_test/services/httpService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:core';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _displayMoreWeather = false;
  bool _editingLocations = false;
  int _locationIndex = 0;
  int _dayOfWeek = 0;
  int _currentHour = 0;
  final List<String> _daysOfWeek = [];
  final PageController _pageController = PageController();
  final IHttpService _httpService = HttpService();
  List<String> _citySearchList = [];
  TextEditingController _editingController = TextEditingController();
  String filter;
  WeatherBloc _weatherBloc;

  @override
  void initState() {
    super.initState();

    _getDaysOfWeek();

    _weatherBloc = BlocProvider.of<WeatherBloc>(context);

    _weatherBloc.add(LoadInitialData());
    // _getDaysOfWeek();
    // _loadData();
    // _loadCities();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _editingController.dispose();
    super.dispose();
  }

  String _getWeatherIcon(Weather weather) {
    switch (weather.currentWeatherIcon) {
      case 'sunny':
      case 'Mildlycloudy':
        return '/asswets/asdjkhgasd.pn';
        break;
    }
  }

  void _getDaysOfWeek() {
    final now = DateTime.now();
    _dayOfWeek = now.weekday - 1;
    _currentHour = now.hour;

    _daysOfWeek.clear();
    _daysOfWeek.addAll(WEEKDAYS.getRange(_dayOfWeek, WEEKDAYS.length));
    _daysOfWeek.addAll(WEEKDAYS.getRange(0, _dayOfWeek));
  }

  void filterSearchResults(String query, List<String> cities) {
    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(cities);
    if (query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {
        if (item.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        _citySearchList.clear();
        _citySearchList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _citySearchList.clear();
        _citySearchList.addAll(cities);
      });
    }
  }

  void _emptySearchResults(List<String> cities) {
    setState(() {
      _editingController.clear();
      _citySearchList.clear();
      _citySearchList.addAll(cities);
    });
  }

  Widget _getGeneralWeather(List<Weather> weatherData, List<String> locations) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              locations.length == 0
                  ? Container()
                  : Image.asset(
                      'assets/images/cloud_icon.png',
                      scale: 2,
                    ),
              Text(
                weatherData.length != 0 ? '${weatherData.first.temp}°' : '',
                style: TextStyle(
                  fontSize: 60,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: locations.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => setState(() {
                _locationIndex = index;
                _displayMoreWeather = true;
              }),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                    child: Container(
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          IntrinsicHeight(
                            child: Row(
                              children: <Widget>[
                                Text(
                                  weatherData[index].city,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30),
                                ),
                                VerticalDivider(color: Colors.white),
                                Text(
                                  '${weatherData[index].temp}°',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30),
                                ),
                              ],
                            ),
                          ),
                          IntrinsicHeight(
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Humidity: ${weatherData[index].humidity}%',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                VerticalDivider(color: Colors.white),
                                Text(
                                  DirectionsHelper.instance
                                      .toTextualDescription(
                                          weatherData[index].windDeg),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                VerticalDivider(color: Colors.white),
                                Text(
                                  '${weatherData[index].windSpeed} m/s',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getMoreWeatherCard(List<Weather> weatherData) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/cloud_icon.png',
              scale: 2,
            ),
            Text('${weatherData[_locationIndex].temp}°',
                style: TextStyle(fontSize: 60, color: Colors.white)),
          ],
        ),
        Stack(
          overflow: Overflow.clip,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    constraints: BoxConstraints.loose(Size(
                        MediaQuery.of(context).size.width * 0.9,
                        MediaQuery.of(context).size.height / 2)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            children: [
                              ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                  color: Colors.white,
                                ),
                                itemCount: WEEKDAYS.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(_daysOfWeek[index],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 30)),
                                      Text(
                                        '${weatherData[_locationIndex].dailyDayTemp[index]}°',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 30),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              ListView.separated(
                                shrinkWrap: true,
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                  color: Colors.white,
                                ),
                                itemCount: 24,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                          '${(_currentHour + index) % 12 != 0 ? (_currentHour + index) % 12 : 12} ${(_currentHour + index - 12) < 0 ? ' AM' : ' PM'}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 30)),
                                      Text(
                                        '${weatherData[_locationIndex].hourlyTemp[index]}°',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: 2,
                          effect: WormEffect(activeDotColor: Colors.blue),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 19,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _displayMoreWeather = false;
                  });
                },
                child: Icon(
                  Icons.cancel,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          valueColor:
              new AlwaysStoppedAnimation<Color>(const Color(0xff36454f)),
        ));
  }

  Widget _buildLoaded(
      List<Weather> weatherData, List<String> locations, List<String> cities) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Simple Weather'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        drawer: Drawer(
          child: SafeArea(
            child: !_editingLocations
                ? Column(
                    children: <Widget>[
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(locations[index]),
                            ),
                          );
                        },
                      ),
                      Card(
                        child: ListTile(
                          title: Text(
                            "Add a New Location!",
                            style: TextStyle(color: Color(0xff36454f)),
                          ),
                          trailing: Icon(Icons.add, color: Color(0xff36454f)),
                          onTap: () {
                            setState(() {
                              _editingLocations = true;
                            });
                          },
                        ),
                      ),
                    ],
                  )
                : Container(
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        if (details.delta.dx > 0) {
                          _emptySearchResults(cities);
                          setState(
                            () {
                              _editingLocations = false;
                            },
                          );
                        }
                      },
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {
                                filterSearchResults(value, cities);
                              },
                              controller: _editingController,
                              decoration: InputDecoration(
                                  labelText: "Search",
                                  hintText: "Search",
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)))),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: _citySearchList == null
                                    ? 0
                                    : _citySearchList.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        _citySearchList[index],
                                        style:
                                            TextStyle(color: Color(0xff36454f)),
                                      ),
                                      trailing: Icon(
                                        Icons.add,
                                        color: Color(0xff36454f),
                                      ),
                                      onTap: () {
                                        _weatherBloc.add(AddCity(
                                            _citySearchList[index],
                                            weatherData,
                                            cities));

                                        _emptySearchResults(cities);

                                        setState(() {
                                          _editingLocations = false;
                                        });
                                      },
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/cloudy_wallpaper_edit.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: !_displayMoreWeather
                ? _getGeneralWeather(weatherData, locations)
                : _getMoreWeatherCard(weatherData),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocListener<WeatherBloc, WeatherState>(
        listener: (context, state) {
          if (state is WeatherInitial) {}
        },
        child: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            if (state is WeatherLoading) {
              return _buildLoading();
            } else if (state is WeatherInitial) {
              return _buildLoaded(
                  state.weatherData, state.locations, state.cities);
            }
          },
        ),
      ),
    );
  }
}
