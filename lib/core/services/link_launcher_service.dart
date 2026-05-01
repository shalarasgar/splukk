import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'dart:developer' as dev;

abstract class LinkLauncherService {
  Future<void> openExternalUrl(String url);
  Future<void> makeCall(String phoneNumber);
  Future<void> sendSms(String phoneNumber);
  Future<void> openWhatsApp(String phoneNumber);
  Future<void> openInstagram(String username);
  Future<void> openFacebook(String profileName);
}

class LinkLauncherServiceImpl implements LinkLauncherService {
  
  String _sanitizePhone(String phone) {
    // Удаляем всё кроме цифр и знака +
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  @override
  Future<void> openExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
      }
    } catch (e) {
      dev.log('LinkLauncher: Error opening URL: $e');
    }
  }

  @override
  Future<void> makeCall(String phoneNumber) async {
    try {
      final cleanPhone = _sanitizePhone(phoneNumber);
      final uri = Uri.parse('tel:$cleanPhone');
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri);
      }
    } catch (e) {
      dev.log('LinkLauncher: Error making call: $e');
    }
  }

  @override
  Future<void> sendSms(String phoneNumber) async {
    try {
      final cleanPhone = _sanitizePhone(phoneNumber);
      final uri = Uri.parse('sms:$cleanPhone');
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri);
      }
    } catch (e) {
      dev.log('LinkLauncher: Error sending SMS: $e');
    }
  }

  @override
  Future<void> openWhatsApp(String phoneNumber) async {
    try {
      final cleanPhone = _sanitizePhone(phoneNumber).replaceAll('+', '');
      // Используем универсальную ссылку wa.me
      final uri = Uri.parse('https://wa.me/$cleanPhone');
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
      }
    } catch (e) {
      dev.log('LinkLauncher: Error opening WhatsApp: $e');
    }
  }

  @override
  Future<void> openInstagram(String username) async {
    try {
      final nativeUri = Uri.parse('instagram://user?username=$username');
      final webUri = Uri.parse('https://instagram.com/$username');
      
      if (await url_launcher.canLaunchUrl(nativeUri)) {
        await url_launcher.launchUrl(nativeUri);
      } else {
        await url_launcher.launchUrl(webUri, mode: url_launcher.LaunchMode.externalApplication);
      }
    } catch (e) {
      dev.log('LinkLauncher: Error opening Instagram: $e');
    }
  }

  @override
  Future<void> openFacebook(String profileName) async {
    try {
      final webUri = Uri.parse('https://facebook.com/$profileName');
      if (await url_launcher.canLaunchUrl(webUri)) {
        await url_launcher.launchUrl(webUri, mode: url_launcher.LaunchMode.externalApplication);
      }
    } catch (e) {
      dev.log('LinkLauncher: Error opening Facebook: $e');
    }
  }
}
