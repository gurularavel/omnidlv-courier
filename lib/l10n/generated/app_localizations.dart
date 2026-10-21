import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_az.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('az'),
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OmniDLV Courier'**
  String get appTitle;

  /// No description provided for @phoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get phoneTitle;

  /// No description provided for @phoneBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the number your dispatcher registered. We will text you a 6-digit code.'**
  String get phoneBody;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get phoneLabel;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @codeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get codeTitle;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'If {phone} is registered, a code is on its way. It works for 5 minutes.'**
  String codeSentTo(String phone);

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get codeLabel;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get resendCode;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// No description provided for @demoSms.
  ///
  /// In en, this message translates to:
  /// **'Demo SMS: your code is {code}'**
  String demoSms(String code);

  /// No description provided for @startShift.
  ///
  /// In en, this message translates to:
  /// **'Start shift'**
  String get startShift;

  /// No description provided for @endShift.
  ///
  /// In en, this message translates to:
  /// **'End shift'**
  String get endShift;

  /// No description provided for @onShift.
  ///
  /// In en, this message translates to:
  /// **'On shift'**
  String get onShift;

  /// No description provided for @offShiftTitle.
  ///
  /// In en, this message translates to:
  /// **'Shift closed'**
  String get offShiftTitle;

  /// No description provided for @offShiftBody.
  ///
  /// In en, this message translates to:
  /// **'Start your shift to see your orders. Your location is shared with dispatch while the shift is open.'**
  String get offShiftBody;

  /// No description provided for @noOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders right now'**
  String get noOrdersTitle;

  /// No description provided for @noOrdersBody.
  ///
  /// In en, this message translates to:
  /// **'New orders appear here. You can also take one from the pool.'**
  String get noOrdersBody;

  /// No description provided for @minLeft.
  ///
  /// In en, this message translates to:
  /// **'min left'**
  String get minLeft;

  /// No description provided for @minLate.
  ///
  /// In en, this message translates to:
  /// **'min late'**
  String get minLate;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get left;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'late'**
  String get late;

  /// No description provided for @pickUpFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick up first'**
  String get pickUpFirst;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @nextClaim.
  ///
  /// In en, this message translates to:
  /// **'Take this order'**
  String get nextClaim;

  /// No description provided for @nextPickup.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get nextPickup;

  /// No description provided for @nextDepart.
  ///
  /// In en, this message translates to:
  /// **'On my way'**
  String get nextDepart;

  /// No description provided for @nextArrive.
  ///
  /// In en, this message translates to:
  /// **'I have arrived'**
  String get nextArrive;

  /// No description provided for @nextComplete.
  ///
  /// In en, this message translates to:
  /// **'Hand over'**
  String get nextComplete;

  /// No description provided for @couldNotDeliver.
  ///
  /// In en, this message translates to:
  /// **'Could not deliver'**
  String get couldNotDeliver;

  /// No description provided for @handoverTitle.
  ///
  /// In en, this message translates to:
  /// **'How was it handed over?'**
  String get handoverTitle;

  /// No description provided for @handedToRecipient.
  ///
  /// In en, this message translates to:
  /// **'Handed to the recipient'**
  String get handedToRecipient;

  /// No description provided for @leftAtDoor.
  ///
  /// In en, this message translates to:
  /// **'Left at the door'**
  String get leftAtDoor;

  /// No description provided for @handedToOther.
  ///
  /// In en, this message translates to:
  /// **'Handed to someone else'**
  String get handedToOther;

  /// No description provided for @whoReceived.
  ///
  /// In en, this message translates to:
  /// **'Who received it?'**
  String get whoReceived;

  /// No description provided for @confirmHandover.
  ///
  /// In en, this message translates to:
  /// **'Confirm handover'**
  String get confirmHandover;

  /// No description provided for @failTitle.
  ///
  /// In en, this message translates to:
  /// **'Why not?'**
  String get failTitle;

  /// No description provided for @failNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Recipient not available'**
  String get failNotAvailable;

  /// No description provided for @failWrongAddress.
  ///
  /// In en, this message translates to:
  /// **'Wrong address'**
  String get failWrongAddress;

  /// No description provided for @failRefused.
  ///
  /// In en, this message translates to:
  /// **'Recipient refused'**
  String get failRefused;

  /// No description provided for @failDamaged.
  ///
  /// In en, this message translates to:
  /// **'Item damaged'**
  String get failDamaged;

  /// No description provided for @failOther.
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get failOther;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get notes;

  /// No description provided for @confirmFail.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmFail;

  /// No description provided for @proof.
  ///
  /// In en, this message translates to:
  /// **'Proof of delivery'**
  String get proof;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signature;

  /// No description provided for @deliveryCode.
  ///
  /// In en, this message translates to:
  /// **'SMS code'**
  String get deliveryCode;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Recipient\'s code'**
  String get enterCode;

  /// No description provided for @checkCode.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get checkCode;

  /// No description provided for @codeOk.
  ///
  /// In en, this message translates to:
  /// **'Code confirmed'**
  String get codeOk;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @scanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get scanned;

  /// No description provided for @notInOrder.
  ///
  /// In en, this message translates to:
  /// **'This barcode is not in the order'**
  String get notInOrder;

  /// No description provided for @mandatory.
  ///
  /// In en, this message translates to:
  /// **'mandatory'**
  String get mandatory;

  /// No description provided for @dontRing.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ring the bell'**
  String get dontRing;

  /// No description provided for @contactless.
  ///
  /// In en, this message translates to:
  /// **'Contactless'**
  String get contactless;

  /// No description provided for @collect.
  ///
  /// In en, this message translates to:
  /// **'Collect {amount}'**
  String collect(String amount);

  /// No description provided for @addProofToFinish.
  ///
  /// In en, this message translates to:
  /// **'Add the mandatory proof above to finish.'**
  String get addProofToFinish;

  /// No description provided for @myDay.
  ///
  /// In en, this message translates to:
  /// **'My day'**
  String get myDay;

  /// No description provided for @tabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get tabActive;

  /// No description provided for @tabPool.
  ///
  /// In en, this message translates to:
  /// **'Pool'**
  String get tabPool;

  /// No description provided for @tabDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tabDone;

  /// No description provided for @take.
  ///
  /// In en, this message translates to:
  /// **'Take'**
  String get take;

  /// No description provided for @deliveredCount.
  ///
  /// In en, this message translates to:
  /// **'{count} delivered'**
  String deliveredCount(int count);

  /// No description provided for @cashToCollect.
  ///
  /// In en, this message translates to:
  /// **'Cash to collect: {amount}'**
  String cashToCollect(String amount);

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get emptyList;

  /// No description provided for @queuedBanner.
  ///
  /// In en, this message translates to:
  /// **'Waiting to send: {count}'**
  String queuedBanner(int count);

  /// No description provided for @queuedAction.
  ///
  /// In en, this message translates to:
  /// **'No connection: the action is saved on this phone and will be sent when the network is back.'**
  String get queuedAction;

  /// No description provided for @handedOver.
  ///
  /// In en, this message translates to:
  /// **'Handover saved. The customer sees it now.'**
  String get handedOver;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @askEveryTime.
  ///
  /// In en, this message translates to:
  /// **'Ask every time'**
  String get askEveryTime;

  /// No description provided for @openDirectionsIn.
  ///
  /// In en, this message translates to:
  /// **'Open directions in'**
  String get openDirectionsIn;

  /// No description provided for @alwaysUseApp.
  ///
  /// In en, this message translates to:
  /// **'Always use this app'**
  String get alwaysUseApp;

  /// No description provided for @changeLater.
  ///
  /// In en, this message translates to:
  /// **'You can change it later in the menu.'**
  String get changeLater;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'The request goes to your company. Your account and personal data are deleted within 30 days.'**
  String get deleteAccountBody;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location access'**
  String get permissionTitle;

  /// No description provided for @permissionBody.
  ///
  /// In en, this message translates to:
  /// **'OmniDLV Courier shares your location with dispatch and with the customer waiting for their order while your shift is open, even when the app is closed or the screen is off. Tracking stops when the shift ends.'**
  String get permissionBody;

  /// No description provided for @permissionBackground.
  ///
  /// In en, this message translates to:
  /// **'So tracking keeps working during the shift, choose \"Allow all the time\" in the next window.'**
  String get permissionBackground;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get allow;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'No location access. Allow it in settings to work a shift.'**
  String get locationDenied;

  /// No description provided for @batteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery saving'**
  String get batteryTitle;

  /// No description provided for @batteryBody.
  ///
  /// In en, this message translates to:
  /// **'Some phones stop apps in the background. Turn off battery optimisation for OmniDLV Courier in settings.'**
  String get batteryBody;

  /// No description provided for @updateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateTitle;

  /// No description provided for @updateBody.
  ///
  /// In en, this message translates to:
  /// **'This version is no longer supported. Update the app to continue.'**
  String get updateBody;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @trackingTitle.
  ///
  /// In en, this message translates to:
  /// **'OmniDLV: you are on shift'**
  String get trackingTitle;

  /// No description provided for @trackingText.
  ///
  /// In en, this message translates to:
  /// **'Your location is shared with dispatch'**
  String get trackingText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['az', 'en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'az':
      return AppLocalizationsAz();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
