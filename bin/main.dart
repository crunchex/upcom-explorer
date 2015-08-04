import 'dart:isolate';
import 'package:upcom-api/tab_backend.dart';
import '../lib/explorer.dart';

void main(List args, SendPort interfacesSendPort) {
  Panel.main(interfacesSendPort, args, (port, args) => new CmdrExplorer(port, args));
}