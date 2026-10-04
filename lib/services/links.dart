import 'package:url_launcher/url_launcher.dart';

/// Opens web pages in the browser and mail links in the mail app. The app
/// uses `url_launcher`; tests use [RecordedLinks].
abstract interface class Links {
  factory Links() = _LaunchedLinks;

  /// False when nothing on the phone could open [url].
  Future<bool> open(Uri url);
}

final class _LaunchedLinks implements Links {
  @override
  Future<bool> open(Uri url) async {
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    }
  }
}

/// Keeps the links it was asked to open, and opens them or not.
final class RecordedLinks implements Links {
  RecordedLinks({this.opens = true});

  final bool opens;
  final opened = <Uri>[];

  @override
  Future<bool> open(Uri url) async {
    opened.add(url);
    return opens;
  }
}
