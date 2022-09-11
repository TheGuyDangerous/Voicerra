import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

extension DateHelpers on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }
}

String getFileSize(int bytes, int decimals) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  int i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
}

Future<Directory> getDirectory() async {
  Directory? applicationDirectory = await getApplicationSupportDirectory();
  Directory audiosFolder = Directory("${applicationDirectory.path}/audios/");

  if (await audiosFolder.exists()) {
    return audiosFolder;
  } else {
    await audiosFolder.create(recursive: true);
    return audiosFolder;
  }
}

extension FileExtention on FileSystemEntity {
  String? get name {
    return path.split("/").last.split(".").first;
  }
}

String durationFormat(Duration duration) =>
    duration.toString().split('.').first.padLeft(8, "0");
