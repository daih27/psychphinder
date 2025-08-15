import 'package:drift/drift.dart';

DatabaseConnection createConnection() {
  throw UnsupportedError('No suitable database implementation was found on this platform.');
}