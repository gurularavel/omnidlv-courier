/// Build-time settings. Pass them with `--dart-define`, for example
/// `flutter run --dart-define=API_BASE_URL=https://app.omnidlv.az`.
class AppConfig {
  AppConfig._();

  /// OmniDLV server. The Android emulator reaches the host machine at 10.0.2.2.
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8090');

  static String get apiRoot => '$apiBaseUrl/api/courier/v1';

  static const supportedLocales = ['az', 'en', 'ru', 'tr'];

  /// Map tiles. The same OpenStreetMap source as the web panel; replace for heavy production use.
  static const tileUrl = String.fromEnvironment('TILE_URL', defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');
}
