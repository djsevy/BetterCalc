import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class HistoryStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/betterCalcEquationHistory.txt');
  }

  Future<String> readHistory() async {
    // print("Trying to find file");
    try {
      final file = await _localFile;
      // print("found it");
      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If enhistorying an error, return 0; will happen the first time it's created; used to return 0. should be empty, I think
      return ""; //RIP, your file is gone
    }
  }

  Future<File> writeToHistory(String history) async {
    final file = await _localFile;
    // print("writing to file");
    // Write the file
    return file.writeAsString('$history');
  }

  clearHistory() async {
    try {
      final file = await _localFile;

      await file.delete();
    } catch (e) {
      //No file, hey, at least it's already gone
    }
  }
}
