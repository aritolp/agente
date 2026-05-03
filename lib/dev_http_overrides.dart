import 'dart:io';
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  }
}
