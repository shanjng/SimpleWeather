import 'package:flutter/services.dart';

class FileDataHelper {
  static const FileDataHelper instance = const FileDataHelper();
  const FileDataHelper();

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path, cache: true);
  }
}
