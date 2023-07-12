import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class NotesStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/bettercalc_notes.txt');
  }

  Future<String> readNotes() async {
    // print("Trying to find file");
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If enhistorying an error, return 0; will happen the first time it's created; used to return 0. should be empty, I think
      return ""; //RIP, your file is gone
    }
  }

  Future<File> writeToNotes(String notes) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(notes);
  }
}
