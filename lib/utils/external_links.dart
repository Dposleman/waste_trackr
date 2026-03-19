import 'package:url_launcher/url_launcher.dart';

class ExternalLinks {
  static final Uri _underStackUri = Uri.parse('https://understack.vercel.app');
  static final Uri _gastroAppUri = Uri.parse('https://gastroapp.dk');

  static Future<void> openUnderStack() async {
    if (!await launchUrl(
      _underStackUri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch UnderStack');
    }
  }

  static Future<void> openGastroApp() async {
    if (!await launchUrl(
      _gastroAppUri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch GastroApp');
    }
  }
}