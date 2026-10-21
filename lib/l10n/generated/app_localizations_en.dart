// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OmniDLV Courier';

  @override
  String get phoneTitle => 'Your phone number';

  @override
  String get phoneBody =>
      'Enter the number your dispatcher registered. We will text you a 6-digit code.';

  @override
  String get phoneLabel => 'Mobile number';

  @override
  String get sendCode => 'Send code';

  @override
  String get codeTitle => 'Enter the code';

  @override
  String codeSentTo(String phone) {
    return 'If $phone is registered, a code is on its way. It works for 5 minutes.';
  }

  @override
  String get codeLabel => '6-digit code';

  @override
  String get signIn => 'Sign in';

  @override
  String get resendCode => 'Send a new code';

  @override
  String get changeNumber => 'Change number';

  @override
  String demoSms(String code) {
    return 'Demo SMS: your code is $code';
  }

  @override
  String get startShift => 'Start shift';

  @override
  String get endShift => 'End shift';

  @override
  String get onShift => 'On shift';

  @override
  String get offShiftTitle => 'Shift closed';

  @override
  String get offShiftBody =>
      'Start your shift to see your orders. Your location is shared with dispatch while the shift is open.';

  @override
  String get noOrdersTitle => 'No orders right now';

  @override
  String get noOrdersBody =>
      'New orders appear here. You can also take one from the pool.';

  @override
  String get minLeft => 'min left';

  @override
  String get minLate => 'min late';

  @override
  String get left => 'left';

  @override
  String get late => 'late';

  @override
  String get pickUpFirst => 'Pick up first';

  @override
  String get call => 'Call';

  @override
  String get navigate => 'Navigate';

  @override
  String get details => 'Details';

  @override
  String get nextClaim => 'Take this order';

  @override
  String get nextPickup => 'Picked up';

  @override
  String get nextDepart => 'On my way';

  @override
  String get nextArrive => 'I have arrived';

  @override
  String get nextComplete => 'Hand over';

  @override
  String get couldNotDeliver => 'Could not deliver';

  @override
  String get handoverTitle => 'How was it handed over?';

  @override
  String get handedToRecipient => 'Handed to the recipient';

  @override
  String get leftAtDoor => 'Left at the door';

  @override
  String get handedToOther => 'Handed to someone else';

  @override
  String get whoReceived => 'Who received it?';

  @override
  String get confirmHandover => 'Confirm handover';

  @override
  String get failTitle => 'Why not?';

  @override
  String get failNotAvailable => 'Recipient not available';

  @override
  String get failWrongAddress => 'Wrong address';

  @override
  String get failRefused => 'Recipient refused';

  @override
  String get failDamaged => 'Item damaged';

  @override
  String get failOther => 'Other reason';

  @override
  String get notes => 'Note';

  @override
  String get confirmFail => 'Confirm';

  @override
  String get proof => 'Proof of delivery';

  @override
  String get photo => 'Photo';

  @override
  String get signature => 'Signature';

  @override
  String get deliveryCode => 'SMS code';

  @override
  String get enterCode => 'Recipient\'s code';

  @override
  String get checkCode => 'Check';

  @override
  String get codeOk => 'Code confirmed';

  @override
  String get scan => 'Scan';

  @override
  String get items => 'Items';

  @override
  String get scanned => 'Scanned';

  @override
  String get notInOrder => 'This barcode is not in the order';

  @override
  String get mandatory => 'mandatory';

  @override
  String get dontRing => 'Don\'t ring the bell';

  @override
  String get contactless => 'Contactless';

  @override
  String collect(String amount) {
    return 'Collect $amount';
  }

  @override
  String get addProofToFinish => 'Add the mandatory proof above to finish.';

  @override
  String get myDay => 'My day';

  @override
  String get tabActive => 'Active';

  @override
  String get tabPool => 'Pool';

  @override
  String get tabDone => 'Done';

  @override
  String get take => 'Take';

  @override
  String deliveredCount(int count) {
    return '$count delivered';
  }

  @override
  String cashToCollect(String amount) {
    return 'Cash to collect: $amount';
  }

  @override
  String get emptyList => 'Nothing here';

  @override
  String queuedBanner(int count) {
    return 'Waiting to send: $count';
  }

  @override
  String get queuedAction =>
      'No connection: the action is saved on this phone and will be sent when the network is back.';

  @override
  String get handedOver => 'Handover saved. The customer sees it now.';

  @override
  String get menu => 'Menu';

  @override
  String get language => 'Language';

  @override
  String get directions => 'Directions';

  @override
  String get askEveryTime => 'Ask every time';

  @override
  String get openDirectionsIn => 'Open directions in';

  @override
  String get alwaysUseApp => 'Always use this app';

  @override
  String get changeLater => 'You can change it later in the menu.';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get deleteAccountBody =>
      'The request goes to your company. Your account and personal data are deleted within 30 days.';

  @override
  String get send => 'Send';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get permissionTitle => 'Location access';

  @override
  String get permissionBody =>
      'OmniDLV Courier shares your location with dispatch and with the customer waiting for their order while your shift is open, even when the app is closed or the screen is off. Tracking stops when the shift ends.';

  @override
  String get permissionBackground =>
      'So tracking keeps working during the shift, choose \"Allow all the time\" in the next window.';

  @override
  String get allow => 'Continue';

  @override
  String get openSettings => 'Open settings';

  @override
  String get notNow => 'Not now';

  @override
  String get locationDenied =>
      'No location access. Allow it in settings to work a shift.';

  @override
  String get batteryTitle => 'Battery saving';

  @override
  String get batteryBody =>
      'Some phones stop apps in the background. Turn off battery optimisation for OmniDLV Courier in settings.';

  @override
  String get updateTitle => 'Update required';

  @override
  String get updateBody =>
      'This version is no longer supported. Update the app to continue.';

  @override
  String get update => 'Update';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get retry => 'Try again';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get save => 'Save';

  @override
  String get trackingTitle => 'OmniDLV: you are on shift';

  @override
  String get trackingText => 'Your location is shared with dispatch';
}
