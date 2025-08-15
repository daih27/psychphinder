import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

DatabaseConnection createConnection() {
  return DatabaseConnection(LazyDatabase(() async {
    final dbAsset = await rootBundle.load('assets/psychphinder.db');
    final dbBytes = dbAsset.buffer.asUint8List();
    
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'psychphinder.db'));
    await tempFile.writeAsBytes(dbBytes);
    
    return NativeDatabase(tempFile);
  }));
}
