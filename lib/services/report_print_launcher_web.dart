import 'dart:convert';

import 'package:web/web.dart' as web;

bool openPrintableReport(String html) {
  final uri = Uri.dataFromString(html, mimeType: 'text/html', encoding: utf8);

  web.window.open(uri.toString(), '_blank');
  return true;
}
