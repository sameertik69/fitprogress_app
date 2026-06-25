import 'report_print_launcher_stub.dart'
    if (dart.library.html) 'report_print_launcher_web.dart'
    as platform_launcher;

bool openPrintableReport(String html) {
  return platform_launcher.openPrintableReport(html);
}
