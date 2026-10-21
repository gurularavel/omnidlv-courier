// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'OmniDLV Kurye';

  @override
  String get phoneTitle => 'Telefon numaranız';

  @override
  String get phoneBody =>
      'Dispeçerin kaydettiği numarayı girin. 6 haneli kodu SMS ile göndereceğiz.';

  @override
  String get phoneLabel => 'Cep telefonu';

  @override
  String get sendCode => 'Kodu gönder';

  @override
  String get codeTitle => 'Kodu girin';

  @override
  String codeSentTo(String phone) {
    return '$phone kayıtlıysa kod gönderildi. 5 dakika geçerlidir.';
  }

  @override
  String get codeLabel => '6 haneli kod';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get resendCode => 'Yeni kod gönder';

  @override
  String get changeNumber => 'Numarayı değiştir';

  @override
  String demoSms(String code) {
    return 'Demo SMS: kodunuz $code';
  }

  @override
  String get startShift => 'Vardiyayı başlat';

  @override
  String get endShift => 'Vardiyayı bitir';

  @override
  String get onShift => 'Vardiyada';

  @override
  String get offShiftTitle => 'Vardiya kapalı';

  @override
  String get offShiftBody =>
      'Siparişlerinizi görmek için vardiyayı başlatın. Vardiya açıkken konumunuz dispeçerle paylaşılır.';

  @override
  String get noOrdersTitle => 'Şu an sipariş yok';

  @override
  String get noOrdersBody =>
      'Yeni siparişler burada görünür. Havuzdan da alabilirsiniz.';

  @override
  String get minLeft => 'dk kaldı';

  @override
  String get minLate => 'dk gecikme';

  @override
  String get left => 'kaldı';

  @override
  String get late => 'gecikme';

  @override
  String get pickUpFirst => 'Önce teslim alın';

  @override
  String get call => 'Ara';

  @override
  String get navigate => 'Navigasyon';

  @override
  String get details => 'Ayrıntılar';

  @override
  String get nextClaim => 'Bu siparişi al';

  @override
  String get nextPickup => 'Teslim aldım';

  @override
  String get nextDepart => 'Yola çıktım';

  @override
  String get nextArrive => 'Adrese vardım';

  @override
  String get nextComplete => 'Teslim et';

  @override
  String get couldNotDeliver => 'Teslim edilemedi';

  @override
  String get handoverTitle => 'Nasıl teslim edildi?';

  @override
  String get handedToRecipient => 'Alıcıya verildi';

  @override
  String get leftAtDoor => 'Kapıya bırakıldı';

  @override
  String get handedToOther => 'Başka birine verildi';

  @override
  String get whoReceived => 'Kim teslim aldı?';

  @override
  String get confirmHandover => 'Teslimi onayla';

  @override
  String get failTitle => 'Neden olmadı?';

  @override
  String get failNotAvailable => 'Alıcı yerinde değil';

  @override
  String get failWrongAddress => 'Adres yanlış';

  @override
  String get failRefused => 'Alıcı reddetti';

  @override
  String get failDamaged => 'Ürün hasarlı';

  @override
  String get failOther => 'Başka sebep';

  @override
  String get notes => 'Not';

  @override
  String get confirmFail => 'Onayla';

  @override
  String get proof => 'Teslim kanıtı';

  @override
  String get photo => 'Fotoğraf';

  @override
  String get signature => 'İmza';

  @override
  String get deliveryCode => 'SMS kodu';

  @override
  String get enterCode => 'Alıcının kodu';

  @override
  String get checkCode => 'Kontrol et';

  @override
  String get codeOk => 'Kod onaylandı';

  @override
  String get scan => 'Tara';

  @override
  String get items => 'Ürünler';

  @override
  String get scanned => 'Tarandı';

  @override
  String get notInOrder => 'Bu barkod siparişte yok';

  @override
  String get mandatory => 'zorunlu';

  @override
  String get dontRing => 'Zili çalmayın';

  @override
  String get contactless => 'Temassız';

  @override
  String collect(String amount) {
    return 'Tahsil et: $amount';
  }

  @override
  String get addProofToFinish =>
      'Bitirmek için yukarıdaki zorunlu kanıtı ekleyin.';

  @override
  String get myDay => 'Günüm';

  @override
  String get tabActive => 'Aktif';

  @override
  String get tabPool => 'Havuz';

  @override
  String get tabDone => 'Biten';

  @override
  String get take => 'Al';

  @override
  String deliveredCount(int count) {
    return '$count teslim edildi';
  }

  @override
  String cashToCollect(String amount) {
    return 'Tahsil edilecek nakit: $amount';
  }

  @override
  String get emptyList => 'Burada bir şey yok';

  @override
  String queuedBanner(int count) {
    return 'Gönderilmeyi bekliyor: $count';
  }

  @override
  String get queuedAction =>
      'Bağlantı yok: işlem bu telefonda kaydedildi, ağ gelince gönderilecek.';

  @override
  String get handedOver => 'Teslim kaydedildi. Müşteri şimdi görüyor.';

  @override
  String get menu => 'Menü';

  @override
  String get language => 'Dil';

  @override
  String get directions => 'Navigasyon';

  @override
  String get askEveryTime => 'Her seferinde sor';

  @override
  String get openDirectionsIn => 'Yol tarifini aç';

  @override
  String get alwaysUseApp => 'Her zaman bu uygulamayı kullan';

  @override
  String get changeLater => 'Daha sonra menüden değiştirebilirsiniz.';

  @override
  String get signOut => 'Çıkış';

  @override
  String get deleteAccount => 'Hesabımı silmek istiyorum';

  @override
  String get deleteAccountBody =>
      'Talep şirketinize gider. Hesabınız ve kişisel verileriniz 30 gün içinde silinir.';

  @override
  String get send => 'Gönder';

  @override
  String version(String version) {
    return 'Sürüm $version';
  }

  @override
  String get permissionTitle => 'Konum izni';

  @override
  String get permissionBody =>
      'OmniDLV Kurye, vardiyanız açıkken uygulama kapalı veya ekran kapalı olsa bile konumunuzu dispeçerle ve siparişini bekleyen müşteriyle paylaşır. Vardiya bitince takip durur.';

  @override
  String get permissionBackground =>
      'Vardiya boyunca takibin durmaması için sonraki pencerede \"Her zaman izin ver\"i seçin.';

  @override
  String get allow => 'Devam et';

  @override
  String get openSettings => 'Ayarları aç';

  @override
  String get notNow => 'Şimdi değil';

  @override
  String get locationDenied =>
      'Konum izni yok. Vardiya için ayarlardan izin verin.';

  @override
  String get batteryTitle => 'Pil tasarrufu';

  @override
  String get batteryBody =>
      'Bazı telefonlar arka plandaki uygulamaları durdurur. Ayarlardan OmniDLV Kurye için pil optimizasyonunu kapatın.';

  @override
  String get updateTitle => 'Güncelleme gerekli';

  @override
  String get updateBody =>
      'Bu sürüm artık desteklenmiyor. Devam etmek için uygulamayı güncelleyin.';

  @override
  String get update => 'Güncelle';

  @override
  String get errorGeneric => 'Bir şeyler ters gitti. Tekrar deneyin.';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get close => 'Kapat';

  @override
  String get cancel => 'İptal';

  @override
  String get clear => 'Temizle';

  @override
  String get save => 'Kaydet';

  @override
  String get trackingTitle => 'OmniDLV: vardiyadasınız';

  @override
  String get trackingText => 'Konumunuz dispeçerle paylaşılıyor';
}
