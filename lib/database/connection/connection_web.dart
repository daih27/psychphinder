import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/services.dart';

DatabaseConnection createConnection() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'psychphinder_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
      initializeDatabase: () async {
        final data = await rootBundle.load('assets/psychphinder.db');
        return data.buffer.asUint8List();
      },
    );

    return DatabaseConnection(result.resolvedExecutor);
  }));
}
