import 'package:url_launcher/url_launcher.dart';

class ExternalLinks {
  static final Uri _gastroAppUri = Uri.parse('https://gastroapp.dk');

  static Future<void> openGastroApp() async {
    await launchUrl(
      _gastroAppUri,
      mode: LaunchMode.externalApplication,
    );
  }
}