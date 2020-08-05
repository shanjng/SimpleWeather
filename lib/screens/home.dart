import 'dart:ui';
import 'package:first_test/constants.dart';
import 'package:first_test/helpers/directionsHelper.dart';
import 'package:first_test/helpers/getCities.dart';
import 'package:first_test/helpers/sharedPreferencesHelper.dart';
import 'package:first_test/model/weather.dart';
import 'package:first_test/services/httpService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  List<Weather> _weatherData;
  bool _isLoading = true;
  bool _isLoadingCities = true;
  List<String> _cities;
  List<String> _citySearchList = [];
  TextEditingController _editingController = TextEditingController();
  String filter;
  List<String> _locations = [];

  @override
  void initState() {
    super.initState();
    // SharedPreferencesHelper.instance.clearLocations();
    _getDaysOfWeek();
    _loadData();
    _loadCities();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _editingController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

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

    if (mounted) {
      setState(() {
        _isLoading = false;
        _locations = locations == null ? [] : locations;
        _weatherData = weatherData;
      });
    }
  }

  Future<void> _loadCities() async {
    if (mounted) {
      setState(() {
        _isLoadingCities = true;
      });
    }

    _cities = await GetCitiesHelper.instance.getCities();

    _citySearchList.addAll(_cities);

    if (mounted) {
      setState(() {
        _isLoadingCities = false;
      });
    }
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

  void filterSearchResults(String query) {
    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(_cities);
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
        _citySearchList.addAll(_cities);
      });
    }
  }

  Widget _getGeneralWeather() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/cloud_icon.png',
                // _getWeatherIcon(_weatherData.first),
                scale: 2,
              ),
              Text(
                _weatherData.length != 0 ? '${_weatherData.first.temp}°' : '',
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
            itemCount: _locations.length,
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
                                  _weatherData[index].city,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30),
                                ),
                                VerticalDivider(color: Colors.white),
                                Text(
                                  '${_weatherData[index].temp}°',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30),
                                ),
                                // VerticalDivider(color: Colors.white),
                                // Container(
                                //   decoration: BoxDecoration(
                                //     image: DecorationImage(
                                //         image: NetworkImage(
                                //             'http://openweathermap.org/img/wn/${_weatherData[_locationIndex].currentWeatherIcon}@2x.png'),
                                //         fit: BoxFit.cover),
                                //   ),
                                // )
                              ],
                            ),
                          ),
                          IntrinsicHeight(
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Humidity: ${_weatherData[index].humidity}%',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                VerticalDivider(color: Colors.white),
                                Text(
                                  DirectionsHelper.instance
                                      .toTextualDescription(
                                          _weatherData[index].windDeg),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                VerticalDivider(color: Colors.white),
                                Text(
                                  '${_weatherData[index].windSpeed} m/s',
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

  Widget _getMoreWeatherCard() {
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
            Text('${_weatherData[_locationIndex].temp}°',
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
                                        '${_weatherData[_locationIndex].dailyDayTemp[index]}°',
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
                                        '${_weatherData[_locationIndex].hourlyTemp[index]}°',
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
                          effect: WormEffect(),
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

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Simple Weather'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        drawer: Drawer(
          child: SafeArea(
            child: !_isLoadingCities
                ? (!_editingLocations
                    ? Column(
                        children: <Widget>[
                          ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: _locations.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  title: Text(_locations[index]),
                                ),
                              );
                            },
                          ),
                          Card(
                            child: Container(
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: Icon(Icons.add, color: Colors.black),
                                onPressed: () {
                                  setState(() {
                                    _editingLocations = true;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      )
                    : Container(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                onChanged: (value) {
                                  filterSearchResults(value);
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
                                        title: Text(_citySearchList[index]),
                                        trailing: Icon(Icons.add,
                                            color: Colors.black),
                                        onTap: () async {
                                          final location =
                                              _citySearchList[index]
                                                  .split(',')
                                                  .first
                                                  .trim();

                                          final locations = [..._locations];
                                          print(locations);
                                          if (!locations.contains(location)) {
                                            await SharedPreferencesHelper
                                                .instance
                                                .writeLocation(
                                                    _citySearchList[index]);

                                            locations.add(location);

                                            final weather = await _httpService
                                                .getWeather(location);

                                            final weatherData = [
                                              ..._weatherData
                                            ];
                                            weatherData.add(weather);

                                            setState(() {
                                              _weatherData = weatherData;
                                            });
                                          }

                                          print(locations);

                                          setState(() {
                                            _editingLocations = false;
                                            _locations = locations;
                                          });
                                        },
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ))
                : CircularProgressIndicator(),
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
          child: _isLoading
              ? CircularProgressIndicator()
              : SafeArea(
                  child: !_displayMoreWeather
                      ? _getGeneralWeather()
                      : _getMoreWeatherCard(),
                ),
        ),
      ),
    );
  }
}
