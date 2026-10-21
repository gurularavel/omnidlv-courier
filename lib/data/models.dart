// Courier API shapes (docs/COURIER-MOBILE-API.md in the omnidlv repo). Parsing is lenient:
// a missing optional field must never crash the courier's screen.

double? _double(Object? v) => v is num ? v.toDouble() : (v is String ? double.tryParse(v) : null);
int? _int(Object? v) => v is num ? v.toInt() : (v is String ? int.tryParse(v) : null);
bool _bool(Object? v) => v == true || v == 1 || v == '1';
DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;
Map<String, dynamic> _map(Object? v) => v is Map ? v.cast<String, dynamic>() : <String, dynamic>{};
List<Map<String, dynamic>> _list(Object? v) => v is List ? v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList() : [];

enum Urgency { ok, risk, late }

Urgency _urgency(Object? v) => switch (v) { 'late' => Urgency.late, 'risk' => Urgency.risk, _ => Urgency.ok };

class Courier {
  Courier({required this.id, required this.name, this.phone, this.phoneDisplay, this.locale, this.ink});

  factory Courier.fromJson(Map<String, dynamic> j) => Courier(
        id: _int(j['id']) ?? 0,
        name: (j['name'] as String?) ?? '',
        phone: j['phone'] as String?,
        phoneDisplay: j['phone_display'] as String?,
        locale: j['locale'] as String?,
        ink: j['ink'] as String?,
      );

  final int id;
  final String name;
  final String? phone;
  final String? phoneDisplay;
  final String? locale;
  final String? ink;
}

class AppSettings {
  AppSettings({
    required this.minVersion,
    required this.latestVersion,
    required this.storeUrls,
    required this.onTaskInterval,
    required this.onTaskDistance,
    required this.idleInterval,
    required this.idleDistance,
    required this.batchSize,
    this.privacyUrl,
    this.supportPhone,
  });

  factory AppSettings.fromJson(Map<String, dynamic> j) {
    final loc = _map(j['location']);
    final onTask = _map(loc['on_task']);
    final idle = _map(loc['idle']);
    return AppSettings(
      minVersion: (j['min_version'] as String?) ?? '0.0.0',
      latestVersion: (j['latest_version'] as String?) ?? '0.0.0',
      storeUrls: _map(j['store_urls']).map((k, v) => MapEntry(k, v as String?)),
      onTaskInterval: _int(onTask['interval']) ?? 15,
      onTaskDistance: _int(onTask['distance']) ?? 30,
      idleInterval: _int(idle['interval']) ?? 60,
      idleDistance: _int(idle['distance']) ?? 100,
      batchSize: _int(loc['batch_size']) ?? 50,
      privacyUrl: j['privacy_url'] as String?,
      supportPhone: j['support_phone'] as String?,
    );
  }

  static AppSettings fallback() => AppSettings.fromJson(const {});

  final String minVersion;
  final String latestVersion;
  final Map<String, String?> storeUrls;
  final int onTaskInterval;
  final int onTaskDistance;
  final int idleInterval;
  final int idleDistance;
  final int batchSize;
  final String? privacyUrl;
  final String? supportPhone;
}

/// One stop as listed on the home screen and in "My day".
class TaskSummary {
  TaskSummary.fromJson(Map<String, dynamic> j)
      : id = _int(j['id']) ?? 0,
        code = (j['code'] as String?) ?? '',
        type = (j['type'] as String?) ?? 'drop_off',
        category = (j['category'] as String?) ?? 'created',
        status = (j['status'] as String?) ?? '',
        name = j['name'] as String?,
        address = j['address'] as String?,
        lat = _double(j['lat']),
        lng = _double(j['lng']),
        minutes = _int(j['minutes']),
        minutesLabel = (j['minutes_label'] as String?) ?? '—',
        minutesInHours = _bool(j['minutes_in_hours']),
        urgency = _urgency(j['urgency']),
        window = (j['window'] as String?) ?? '',
        cash = _double(j['cash']),
        currency = j['currency'] as String?,
        locked = _bool(j['locked']);

  final int id;
  final String code;
  final String type;
  final String category;
  final String status;
  final String? name;
  final String? address;
  final double? lat;
  final double? lng;
  final int? minutes;
  final String minutesLabel;
  final bool minutesInHours;
  final Urgency urgency;
  final String window;
  final double? cash;
  final String? currency;
  final bool locked;

  bool get isFinal => const {'completed', 'failed', 'cancelled'}.contains(category);
}

class Place {
  Place.fromJson(Map<String, dynamic> j)
      : name = j['name'] as String?,
        address = j['address'] as String?,
        building = j['building'] as String?,
        floor = j['floor'] as String?,
        apartment = j['apartment'] as String?,
        description = j['description'] as String?,
        phone = j['phone'] as String?,
        lat = _double(j['lat']),
        lng = _double(j['lng']);

  final String? name;
  final String? address;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? description;
  final String? phone;
  final double? lat;
  final double? lng;
}

class TaskItem {
  TaskItem.fromJson(Map<String, dynamic> j)
      : id = _int(j['id']) ?? 0,
        name = (j['name'] as String?) ?? '',
        sku = j['sku'] as String?,
        barcode = j['barcode'] as String?,
        quantity = _int(j['quantity']) ?? 1,
        scanned = _bool(j['scanned']);

  final int id;
  final String name;
  final String? sku;
  final String? barcode;
  final int quantity;
  final bool scanned;
}

class Pod {
  Pod.fromJson(Map<String, dynamic> j)
      : id = _int(j['id']) ?? 0,
        type = (j['type'] as String?) ?? 'photo',
        url = (j['url'] as String?) ?? '';

  final int id;
  final String type;
  final String url;
}

class Requirements {
  Requirements.fromJson(Map<String, dynamic> j)
      : photo = _bool(j['photo']),
        photoMandatory = _bool(j['photo_mandatory']),
        code = _bool(j['code']),
        codeMandatory = _bool(j['code_mandatory']),
        dontRing = _bool(j['dont_ring']),
        contactless = _bool(j['contactless']);

  final bool photo;
  final bool photoMandatory;
  final bool code;
  final bool codeMandatory;
  final bool dontRing;
  final bool contactless;
}

/// Everything about one task, with what the courier can do next.
class TaskDetail extends TaskSummary {
  TaskDetail.fromJson(super.j)
      : target = Place.fromJson(_map(j['target'])),
        from = Place.fromJson(_map(j['from'])),
        hub = j['hub'] as String?,
        phone = j['phone'] as String?,
        phoneDisplay = j['phone_display'] as String?,
        notes = j['notes'] as String?,
        recipientNotes = j['recipient_notes'] as String?,
        requirements = Requirements.fromJson(_map(j['requirements'])),
        codeVerified = _bool(j['code_verified']),
        codeAttemptsLeft = _int(j['code_attempts_left']) ?? 0,
        items = _list(j['items']).map(TaskItem.fromJson).toList(),
        pods = _list(j['pods']).map(Pod.fromJson).toList(),
        next = j['next'] as String?,
        canComplete = _bool(j['can_complete']),
        canFail = _bool(j['can_fail']),
        googleUrl = _map(j['navigate'])['google'] as String?,
        wazeUrl = _map(j['navigate'])['waze'] as String?,
        finalState = _bool(j['final']),
        endsAt = _date(j['ends_at']),
        super.fromJson();

  final Place target;
  final Place from;
  final String? hub;
  final String? phone;
  final String? phoneDisplay;
  final String? notes;
  final String? recipientNotes;
  final Requirements requirements;
  final bool codeVerified;
  final int codeAttemptsLeft;
  final List<TaskItem> items;
  final List<Pod> pods;

  /// claim | pickup | depart | arrive | complete | null
  final String? next;
  final bool canComplete;
  final bool canFail;
  final String? googleUrl;
  final String? wazeUrl;
  final bool finalState;
  final DateTime? endsAt;

  bool get canNavigate => googleUrl != null || wazeUrl != null;
}

class Board {
  Board.fromJson(Map<String, dynamic> j)
      : courier = Courier.fromJson(_map(j['courier'])),
        company = j['company'] as String?,
        shiftActive = _bool(_map(j['shift'])['active']),
        shiftStartedLabel = _map(j['shift'])['started_label'] as String?,
        next = j['next'] is Map ? TaskDetail.fromJson(_map(j['next'])) : null,
        active = _list(j['active']).map(TaskSummary.fromJson).toList(),
        pool = _list(j['pool']).map(TaskSummary.fromJson).toList(),
        done = _list(j['done']).map(TaskSummary.fromJson).toList(),
        delivered = _int(_map(j['counts'])['delivered']) ?? 0,
        failed = _int(_map(j['counts'])['failed']) ?? 0,
        cash = _double(_map(j['counts'])['cash']) ?? 0;

  final Courier courier;
  final String? company;
  final bool shiftActive;
  final String? shiftStartedLabel;
  final TaskDetail? next;
  final List<TaskSummary> active;
  final List<TaskSummary> pool;
  final List<TaskSummary> done;
  final int delivered;
  final int failed;
  final double cash;
}
