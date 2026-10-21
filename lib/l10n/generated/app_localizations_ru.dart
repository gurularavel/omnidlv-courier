// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'OmniDLV Курьер';

  @override
  String get phoneTitle => 'Ваш номер телефона';

  @override
  String get phoneBody =>
      'Введите номер, который зарегистрировал диспетчер. Мы пришлём 6-значный код.';

  @override
  String get phoneLabel => 'Мобильный номер';

  @override
  String get sendCode => 'Отправить код';

  @override
  String get codeTitle => 'Введите код';

  @override
  String codeSentTo(String phone) {
    return 'Если номер $phone зарегистрирован, код отправлен. Он действует 5 минут.';
  }

  @override
  String get codeLabel => '6-значный код';

  @override
  String get signIn => 'Войти';

  @override
  String get resendCode => 'Отправить новый код';

  @override
  String get changeNumber => 'Изменить номер';

  @override
  String demoSms(String code) {
    return 'Демо SMS: ваш код $code';
  }

  @override
  String get startShift => 'Начать смену';

  @override
  String get endShift => 'Закончить смену';

  @override
  String get onShift => 'На смене';

  @override
  String get offShiftTitle => 'Смена закрыта';

  @override
  String get offShiftBody =>
      'Начните смену, чтобы увидеть заказы. Пока смена открыта, ваше местоположение видит диспетчер.';

  @override
  String get noOrdersTitle => 'Сейчас заказов нет';

  @override
  String get noOrdersBody =>
      'Новые заказы появятся здесь. Можно взять заказ из пула.';

  @override
  String get minLeft => 'мин осталось';

  @override
  String get minLate => 'мин опоздание';

  @override
  String get left => 'осталось';

  @override
  String get late => 'опоздание';

  @override
  String get pickUpFirst => 'Сначала заберите';

  @override
  String get call => 'Звонок';

  @override
  String get navigate => 'Навигация';

  @override
  String get details => 'Подробнее';

  @override
  String get nextClaim => 'Взять этот заказ';

  @override
  String get nextPickup => 'Забрал';

  @override
  String get nextDepart => 'Выехал';

  @override
  String get nextArrive => 'На месте';

  @override
  String get nextComplete => 'Передать';

  @override
  String get couldNotDeliver => 'Не удалось доставить';

  @override
  String get handoverTitle => 'Как передан заказ?';

  @override
  String get handedToRecipient => 'Передан получателю';

  @override
  String get leftAtDoor => 'Оставлен у двери';

  @override
  String get handedToOther => 'Передан другому человеку';

  @override
  String get whoReceived => 'Кто получил?';

  @override
  String get confirmHandover => 'Подтвердить передачу';

  @override
  String get failTitle => 'Почему не удалось?';

  @override
  String get failNotAvailable => 'Получателя нет на месте';

  @override
  String get failWrongAddress => 'Неверный адрес';

  @override
  String get failRefused => 'Получатель отказался';

  @override
  String get failDamaged => 'Товар повреждён';

  @override
  String get failOther => 'Другая причина';

  @override
  String get notes => 'Заметка';

  @override
  String get confirmFail => 'Подтвердить';

  @override
  String get proof => 'Подтверждение доставки';

  @override
  String get photo => 'Фото';

  @override
  String get signature => 'Подпись';

  @override
  String get deliveryCode => 'SMS-код';

  @override
  String get enterCode => 'Код получателя';

  @override
  String get checkCode => 'Проверить';

  @override
  String get codeOk => 'Код подтверждён';

  @override
  String get scan => 'Сканировать';

  @override
  String get items => 'Товары';

  @override
  String get scanned => 'Отсканировано';

  @override
  String get notInOrder => 'Этого штрихкода нет в заказе';

  @override
  String get mandatory => 'обязательно';

  @override
  String get dontRing => 'Не звонить в дверь';

  @override
  String get contactless => 'Бесконтактно';

  @override
  String collect(String amount) {
    return 'Получить $amount';
  }

  @override
  String get addProofToFinish =>
      'Чтобы завершить, добавьте обязательное подтверждение выше.';

  @override
  String get myDay => 'Мой день';

  @override
  String get tabActive => 'Активные';

  @override
  String get tabPool => 'Пул';

  @override
  String get tabDone => 'Готово';

  @override
  String get take => 'Взять';

  @override
  String deliveredCount(int count) {
    return 'Доставлено: $count';
  }

  @override
  String cashToCollect(String amount) {
    return 'Наличные к сбору: $amount';
  }

  @override
  String get emptyList => 'Здесь пусто';

  @override
  String queuedBanner(int count) {
    return 'Ожидает отправки: $count';
  }

  @override
  String get queuedAction =>
      'Нет связи: действие сохранено на телефоне и будет отправлено, когда появится сеть.';

  @override
  String get handedOver => 'Передача сохранена. Клиент уже видит это.';

  @override
  String get menu => 'Меню';

  @override
  String get language => 'Язык';

  @override
  String get directions => 'Навигация';

  @override
  String get askEveryTime => 'Спрашивать каждый раз';

  @override
  String get openDirectionsIn => 'Открыть маршрут в';

  @override
  String get alwaysUseApp => 'Всегда открывать в этом приложении';

  @override
  String get changeLater => 'Это можно изменить в меню.';

  @override
  String get signOut => 'Выйти';

  @override
  String get deleteAccount => 'Удалить мой аккаунт';

  @override
  String get deleteAccountBody =>
      'Запрос получит ваша компания. Аккаунт и личные данные будут удалены в течение 30 дней.';

  @override
  String get send => 'Отправить';

  @override
  String version(String version) {
    return 'Версия $version';
  }

  @override
  String get permissionTitle => 'Доступ к местоположению';

  @override
  String get permissionBody =>
      'Пока смена открыта, OmniDLV Курьер передаёт ваше местоположение диспетчеру и клиенту, который ждёт заказ, даже когда приложение закрыто или экран выключен. Отслеживание прекращается после смены.';

  @override
  String get permissionBackground =>
      'Чтобы отслеживание не прерывалось во время смены, выберите «Разрешить всегда» в следующем окне.';

  @override
  String get allow => 'Продолжить';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get locationDenied =>
      'Нет доступа к местоположению. Разрешите его в настройках, чтобы работать в смену.';

  @override
  String get batteryTitle => 'Экономия батареи';

  @override
  String get batteryBody =>
      'Некоторые телефоны останавливают приложения в фоне. Отключите оптимизацию батареи для OmniDLV Курьер в настройках.';

  @override
  String get updateTitle => 'Нужно обновление';

  @override
  String get updateBody =>
      'Эта версия больше не поддерживается. Обновите приложение, чтобы продолжить.';

  @override
  String get update => 'Обновить';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get retry => 'Повторить';

  @override
  String get close => 'Закрыть';

  @override
  String get cancel => 'Отмена';

  @override
  String get clear => 'Очистить';

  @override
  String get save => 'Сохранить';

  @override
  String get trackingTitle => 'OmniDLV: вы на смене';

  @override
  String get trackingText => 'Ваше местоположение видит диспетчер';
}
