import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

enum NavApp { google, waze }

/// Directions in Google Maps or Waze. The courier picks each time or saves a choice on the
/// phone, as in the web app.
class NavLauncher {
  NavLauncher(this._prefs);

  static const _key = 'courier.nav_app';
  final SharedPreferences _prefs;

  NavApp? get saved => switch (_prefs.getString(_key)) {
        'google' => NavApp.google,
        'waze' => NavApp.waze,
        _ => null,
      };

  Future<void> remember(NavApp? app) async {
    if (app == null) {
      await _prefs.remove(_key);
    } else {
      await _prefs.setString(_key, app.name);
    }
  }

  /// Opens the installed app when there is one (the URLs are universal links), else the browser.
  Future<bool> open(NavApp app, {String? googleUrl, String? wazeUrl}) async {
    final url = app == NavApp.google ? googleUrl : wazeUrl;
    if (url == null) return false;
    return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  static Future<bool> call(String phone) => launchUrl(Uri(scheme: 'tel', path: phone));
}
