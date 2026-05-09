import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'dart:developer' as dev;

abstract class LinkLauncherService {
  Future<bool> openExternalUrl(String url);
  Future<bool> makeCall(String phoneNumber);
  Future<bool> sendSms(String phoneNumber);
  Future<bool> openWhatsApp(String phoneNumber);
  Future<bool> openInstagram(String username);
  Future<bool> openFacebook(String profileName);
}

class LinkLauncherServiceImpl implements LinkLauncherService {
  
  String _sanitizePhone(String phone) {
    // Удаляем всё кроме цифр и знака +
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  @override
  Future<bool> openExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await url_launcher.canLaunchUrl(uri)) {
        return await url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      dev.log('LinkLauncher: Error opening URL: $e');
      return false;
    }
  }

  @override
  Future<bool> makeCall(String phoneNumber) async {
    try {
      final cleanPhone = _sanitizePhone(phoneNumber);
      final uri = Uri.parse('tel:$cleanPhone');
      if (await url_launcher.canLaunchUrl(uri)) {
        return await url_launcher.launchUrl(uri);
      }
      return false;
    } catch (e) {
      dev.log('LinkLauncher: Error making call: $e');
      return false;
    }
  }

  @override
  Future<bool> sendSms(String phoneNumber) async {
    try {
      final cleanPhone = _sanitizePhone(phoneNumber);
      final uri = Uri.parse('sms:$cleanPhone');
      if (await url_launcher.canLaunchUrl(uri)) {
        return await url_launcher.launchUrl(uri);
      }
      return false;
    } catch (e) {
      dev.log('LinkLauncher: Error sending SMS: $e');
      return false;
    }
  }

  @override
  Future<bool> openWhatsApp(String phoneNumber) async {
    try {
      final cleanPhone = _sanitizePhone(phoneNumber).replaceAll('+', '');
      // Используем универсальную ссылку wa.me
      final uri = Uri.parse('https://wa.me/$cleanPhone');
      if (await url_launcher.canLaunchUrl(uri)) {
        return await url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      dev.log('LinkLauncher: Error opening WhatsApp: $e');
      return false;
    }
  }

  @override
  Future<bool> openInstagram(String username) async {
    try {
      final nativeUri = Uri.parse('instagram://user?username=$username');
      final webUri = Uri.parse('https://instagram.com/$username');
      
      if (await url_launcher.canLaunchUrl(nativeUri)) {
        return await url_launcher.launchUrl(nativeUri);
      } else if (await url_launcher.canLaunchUrl(webUri)) {
        return await url_launcher.launchUrl(webUri, mode: url_launcher.LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      dev.log('LinkLauncher: Error opening Instagram: $e');
      return false;
    }
  }

  @override
  Future<bool> openFacebook(String profileName) async {
    try {
      final webUri = Uri.parse('https://facebook.com/$profileName');
      if (await url_launcher.canLaunchUrl(webUri)) {
        return await url_launcher.launchUrl(webUri, mode: url_launcher.LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      dev.log('LinkLauncher: Error opening Facebook: $e');
      return false;
    }
  }
}
