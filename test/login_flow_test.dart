import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnidlv_courier/app.dart';
import 'package:omnidlv_courier/core/storage/token_store.dart';
import 'package:omnidlv_courier/data/models.dart';
import 'package:omnidlv_courier/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignedOutTokens extends TokenStore {
  @override
  Future<String?> read() async => null;
}

void main() {
  testWidgets('a signed-out courier lands on the phone screen, and letters never reach the field', (tester) async {
    SharedPreferences.setMockInitialValues({'courier.locale': 'az'});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        tokenStoreProvider.overrideWithValue(SignedOutTokens()),
        appSettingsProvider.overrideWith((ref) async => AppSettings.fallback()),
        updateRequiredProvider.overrideWith((ref) async => false),
      ],
      child: const CourierApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Telefon nömrəniz'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '05abc01234567');
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '050 123 45 67');
    expect(find.text('KODU GÖNDƏR'), findsOneWidget);
  });
}
