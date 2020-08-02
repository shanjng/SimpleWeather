class UnixTimeStampConvert {
  static const UnixTimeStampConvert instance = const UnixTimeStampConvert();
  const UnixTimeStampConvert();

  int toDateTime(String string) {
    var timestamp = 1549312452; // in milliseconds
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var day = date.weekday;
    var hours = date.hour;

    return day;
  }
}
