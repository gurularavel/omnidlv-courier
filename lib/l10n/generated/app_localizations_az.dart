// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class AppLocalizationsAz extends AppLocalizations {
  AppLocalizationsAz([String locale = 'az']) : super(locale);

  @override
  String get appTitle => 'OmniDLV Kuryer';

  @override
  String get phoneTitle => 'Telefon nömrəniz';

  @override
  String get phoneBody =>
      'Dispetçerin qeydiyyata aldığı nömrəni yazın. 6 rəqəmli kod SMS ilə gələcək.';

  @override
  String get phoneLabel => 'Mobil nömrə';

  @override
  String get sendCode => 'Kodu göndər';

  @override
  String get codeTitle => 'Kodu daxil edin';

  @override
  String codeSentTo(String phone) {
    return '$phone qeydiyyatdadırsa, kod göndərildi. 5 dəqiqə etibarlıdır.';
  }

  @override
  String get codeLabel => '6 rəqəmli kod';

  @override
  String get signIn => 'Daxil ol';

  @override
  String get resendCode => 'Yeni kod göndər';

  @override
  String get changeNumber => 'Nömrəni dəyiş';

  @override
  String demoSms(String code) {
    return 'Demo SMS: kodunuz $code';
  }

  @override
  String get startShift => 'Növbəni başlat';

  @override
  String get endShift => 'Növbəni bitir';

  @override
  String get onShift => 'Növbədə';

  @override
  String get offShiftTitle => 'Növbə bağlıdır';

  @override
  String get offShiftBody =>
      'Növbəni başladanda tapşırıqlarınız görünəcək və yeriniz dispetçerə göndəriləcək.';

  @override
  String get noOrdersTitle => 'Hazırda sifariş yoxdur';

  @override
  String get noOrdersBody =>
      'Yeni tapşırıq gələndə burada görünəcək. Hovuzdan da götürə bilərsiniz.';

  @override
  String get minLeft => 'dəq qalıb';

  @override
  String get minLate => 'dəq gecikir';

  @override
  String get left => 'qalıb';

  @override
  String get late => 'gecikir';

  @override
  String get pickUpFirst => 'Əvvəlcə götürün';

  @override
  String get call => 'Zəng';

  @override
  String get navigate => 'Naviqasiya';

  @override
  String get details => 'Təfərrüatlar';

  @override
  String get nextClaim => 'Bu sifarişi götür';

  @override
  String get nextPickup => 'Götürdüm';

  @override
  String get nextDepart => 'Yola çıxdım';

  @override
  String get nextArrive => 'Ünvana çatdım';

  @override
  String get nextComplete => 'Təhvil ver';

  @override
  String get couldNotDeliver => 'Çatdırmaq alınmadı';

  @override
  String get handoverTitle => 'Necə təhvil verildi?';

  @override
  String get handedToRecipient => 'Alıcıya verildi';

  @override
  String get leftAtDoor => 'Qapının ağzında qoyuldu';

  @override
  String get handedToOther => 'Başqa şəxsə verildi';

  @override
  String get whoReceived => 'Kim təhvil aldı?';

  @override
  String get confirmHandover => 'Təhvili təsdiqlə';

  @override
  String get failTitle => 'Niyə alınmadı?';

  @override
  String get failNotAvailable => 'Alıcı yerində deyil';

  @override
  String get failWrongAddress => 'Ünvan yanlışdır';

  @override
  String get failRefused => 'Alıcı imtina etdi';

  @override
  String get failDamaged => 'Məhsul zədələnib';

  @override
  String get failOther => 'Başqa səbəb';

  @override
  String get notes => 'Qeyd';

  @override
  String get confirmFail => 'Təsdiqlə';

  @override
  String get proof => 'Təhvil sübutu';

  @override
  String get photo => 'Foto';

  @override
  String get signature => 'İmza';

  @override
  String get deliveryCode => 'SMS kodu';

  @override
  String get enterCode => 'Alıcının kodu';

  @override
  String get checkCode => 'Yoxla';

  @override
  String get codeOk => 'Kod təsdiqləndi';

  @override
  String get scan => 'Skan et';

  @override
  String get items => 'Məhsullar';

  @override
  String get scanned => 'Skan olundu';

  @override
  String get notInOrder => 'Bu barkod sifarişdə yoxdur';

  @override
  String get mandatory => 'məcburi';

  @override
  String get dontRing => 'Zəngi basmayın';

  @override
  String get contactless => 'Təmassız';

  @override
  String collect(String amount) {
    return 'Al: $amount';
  }

  @override
  String get addProofToFinish =>
      'Bitirmək üçün yuxarıdakı məcburi sübutu əlavə edin.';

  @override
  String get myDay => 'Günüm';

  @override
  String get tabActive => 'Aktiv';

  @override
  String get tabPool => 'Hovuz';

  @override
  String get tabDone => 'Bitən';

  @override
  String get take => 'Götür';

  @override
  String deliveredCount(int count) {
    return '$count çatdırılıb';
  }

  @override
  String cashToCollect(String amount) {
    return 'Yığılacaq nağd: $amount';
  }

  @override
  String get emptyList => 'Burada heç nə yoxdur';

  @override
  String queuedBanner(int count) {
    return 'Göndərilməyi gözləyir: $count';
  }

  @override
  String get queuedAction =>
      'İnternet yoxdur: əməliyyat bu telefonda saxlanıldı, şəbəkə qayıdanda göndəriləcək.';

  @override
  String get handedOver => 'Təhvil qeydə alındı. Müştəri artıq görür.';

  @override
  String get menu => 'Menyu';

  @override
  String get language => 'Dil';

  @override
  String get directions => 'Naviqasiya';

  @override
  String get askEveryTime => 'Hər dəfə soruş';

  @override
  String get openDirectionsIn => 'Yolu hansı tətbiqdə açaq?';

  @override
  String get alwaysUseApp => 'Həmişə bu tətbiqi aç';

  @override
  String get changeLater => 'Sonra menyudan dəyişə bilərsiniz.';

  @override
  String get signOut => 'Çıxış';

  @override
  String get deleteAccount => 'Hesabımı silmək istəyirəm';

  @override
  String get deleteAccountBody =>
      'Sorğu şirkətinizə göndəriləcək. Hesabınız və şəxsi məlumatlarınız 30 gün ərzində silinəcək.';

  @override
  String get send => 'Göndər';

  @override
  String version(String version) {
    return 'Versiya $version';
  }

  @override
  String get permissionTitle => 'Məkan icazəsi';

  @override
  String get permissionBody =>
      'OmniDLV Kuryer növbə açıq olanda yerinizi dispetçerə və sifarişini gözləyən müştəriyə göndərir, tətbiq bağlı olsa və ekran sönülü olsa belə. Növbə bağlananda izləmə dayanır.';

  @override
  String get permissionBackground =>
      'Növbə zamanı izləmənin dayanmaması üçün növbəti pəncərədə \"Həmişə icazə ver\" seçin.';

  @override
  String get allow => 'Davam et';

  @override
  String get openSettings => 'Ayarları aç';

  @override
  String get notNow => 'İndi yox';

  @override
  String get locationDenied =>
      'Məkan icazəsi yoxdur. Növbə üçün ayarlardan icazə verin.';

  @override
  String get batteryTitle => 'Batareya qənaəti';

  @override
  String get batteryBody =>
      'Bəzi telefonlar fon tətbiqlərini dayandırır. Ayarlarda OmniDLV Kuryer üçün batareya optimallaşdırmasını söndürün.';

  @override
  String get updateTitle => 'Yeniləmə lazımdır';

  @override
  String get updateBody =>
      'Bu versiya artıq dəstəklənmir. Davam etmək üçün tətbiqi yeniləyin.';

  @override
  String get update => 'Yenilə';

  @override
  String get errorGeneric => 'Nəsə alınmadı. Yenidən cəhd edin.';

  @override
  String get retry => 'Yenidən cəhd et';

  @override
  String get close => 'Bağla';

  @override
  String get cancel => 'Ləğv et';

  @override
  String get clear => 'Təmizlə';

  @override
  String get save => 'Saxla';

  @override
  String get trackingTitle => 'OmniDLV: növbədəsiniz';

  @override
  String get trackingText => 'Yeriniz dispetçerə göndərilir';
}
