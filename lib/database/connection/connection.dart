import 'package:drift/drift.dart';

import 'connection_stub.dart'
    if (dart.library.io) 'connection_native.dart'
    if (dart.library.js) 'connection_web.dart';

DatabaseConnection connect() {
  return createConnection();
}