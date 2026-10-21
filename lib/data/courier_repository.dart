import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/offline/action_queue.dart';
import 'models.dart';

/// Every call the app makes to /api/courier/v1. Actions that change state go through the
/// offline queue, so they survive a dead network.
class CourierRepository {
  CourierRepository(this._api, this.queue);

  final ApiClient _api;
  final ActionQueue queue;

  Future<AppSettings> appConfig() async => AppSettings.fromJson(await _api.get('/app-config'));

  /// Returns the demo code while the server's SMS runs in demo mode.
  Future<String?> requestCode(String phone) async => (await _api.post('/auth/otp', body: {'phone': phone}))['demo_code'] as String?;

  Future<({String token, Courier courier})> verify(String phone, String code, String deviceName) async {
    final res = await _api.post('/auth/verify', body: {'phone': phone, 'code': code, 'device_name': deviceName});
    return (token: res['token'] as String, courier: Courier.fromJson((res['courier'] as Map).cast<String, dynamic>()));
  }

  Future<void> logout() => _api.post('/auth/logout');

  Future<Map<String, dynamic>> me() => _api.get('/me');

  Future<void> setLocale(String locale) => _api.patch('/me/locale', body: {'locale': locale});

  Future<void> registerDevice(Map<String, dynamic> device) => _api.post('/devices', body: device);

  Future<void> requestDeletion(String? reason) => _api.post('/account/deletion-request', body: {'reason': reason});

  Future<Board> board() async => Board.fromJson(await _api.get('/board'));

  Future<TaskDetail> task(int id) async => TaskDetail.fromJson(await _api.get('/tasks/$id'));

  /// Shift changes are not queued: the courier must see at once whether the shift started.
  Future<Board> startShift({double? lat, double? lng}) async =>
      Board.fromJson(await _api.post('/shift/start', body: {'lat': ?lat, 'lng': ?lng}));

  Future<Board> endShift() async => Board.fromJson(await _api.post('/shift/end'));

  Future<ActResult> claim(int id) => queue.act('/tasks/$id/claim');

  Future<ActResult> step(int id, String action, {Map<String, dynamic> point = const {}}) =>
      queue.act('/tasks/$id/step', {'action': action, ...point});

  Future<ActResult> complete(int id, String status, {String? receivedBy, Map<String, dynamic> point = const {}}) =>
      queue.act('/tasks/$id/complete', {'status': status, 'received_by': ?receivedBy, ...point});

  Future<ActResult> fail(int id, String status, {String? notes, Map<String, dynamic> point = const {}}) =>
      queue.act('/tasks/$id/fail', {'status': status, 'notes': ?notes, ...point});

  /// Code checks need an answer now (right or wrong), so they are not queued.
  Future<({bool verified, int attemptsLeft, TaskDetail task, String? message})> verifyCode(int id, String code) async {
    try {
      final res = await _api.post('/tasks/$id/code', body: {'code': code});
      return (verified: true, attemptsLeft: (res['attempts_left'] as num?)?.toInt() ?? 0, task: TaskDetail.fromJson((res['task'] as Map).cast<String, dynamic>()), message: null);
    } on ApiException catch (e) {
      final body = e.body;
      if (body != null && body['task'] is Map) {
        return (
          verified: false,
          attemptsLeft: (body['attempts_left'] as num?)?.toInt() ?? 0,
          task: TaskDetail.fromJson((body['task'] as Map).cast<String, dynamic>()),
          message: body['message'] as String?,
        );
      }
      rethrow;
    }
  }

  Future<({bool matched, TaskDetail? task})> scan(int id, String code) async {
    try {
      final res = await _api.post('/tasks/$id/scan', body: {'code': code});
      return (matched: true, task: TaskDetail.fromJson((res['task'] as Map).cast<String, dynamic>()));
    } on ApiException catch (e) {
      final body = e.body;
      if (body != null && body['task'] is Map) {
        return (matched: false, task: TaskDetail.fromJson((body['task'] as Map).cast<String, dynamic>()));
      }
      rethrow;
    }
  }

  /// Proof photos are too big for the offline queue; they upload while online.
  Future<TaskDetail> uploadPod(int id, String type, List<int> bytes, String filename) async {
    final form = FormData.fromMap({'type': type, 'file': MultipartFile.fromBytes(bytes, filename: filename)});
    return TaskDetail.fromJson(await _api.upload('/tasks/$id/pods', form));
  }

  Future<Map<String, dynamic>> sendLocations(List<Map<String, dynamic>> fixes) => _api.post('/locations', body: {'locations': fixes});
}

