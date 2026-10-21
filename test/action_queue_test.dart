import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnidlv_courier/core/api/api_client.dart';
import 'package:omnidlv_courier/core/api/api_exception.dart';
import 'package:omnidlv_courier/core/offline/action_queue.dart';
import 'package:omnidlv_courier/core/storage/token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers requests from a script; `null` simulates "no network".
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.answer);
  final ResponseBody? Function(RequestOptions options) answer;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final res = answer(options);
    if (res == null) throw DioException.connectionError(requestOptions: options, reason: 'offline');
    return res;
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Map<String, dynamic> body) =>
    ResponseBody.fromString(jsonEncode(body), status, headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});

class MemoryTokens extends TokenStore {
  MemoryTokens() : super();
  @override
  Future<String?> read() async => 'test-token';
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ({ActionQueue queue, ScriptedAdapter adapter}) build(ResponseBody? Function(RequestOptions) answer) {
    final adapter = ScriptedAdapter(answer);
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/courier/v1'))..httpClientAdapter = adapter;
    final api = ApiClient(MemoryTokens(), dio: dio);
    return (queue: ActionQueue(api, prefs), adapter: adapter);
  }

  test('an action sent without network waits and is replayed with the same action id', () async {
    var online = false;
    final s = build((o) => online ? json(200, {'id': 5, 'final': true}) : null);

    final first = await s.queue.act('/tasks/5/complete', {'status': 'delivered'});
    expect(first.queued, isTrue);
    expect(s.queue.pending, 1);

    online = true;
    expect(await s.queue.flush(), 1);
    expect(s.queue.pending, 0);

    final ids = s.adapter.requests.map((r) => r.headers['X-Action-Id']).toSet();
    expect(ids, hasLength(1), reason: 'the replay must reuse the id so the server can deduplicate');
    expect(s.adapter.requests.last.headers['Authorization'], 'Bearer test-token');
  });

  test('a refusal from the server is not queued but reported', () async {
    final s = build((o) => json(422, {'message': 'Əvvəlcə sübut fotosunu çəkin.', 'code': 'photo_required'}));

    expect(
      () => s.queue.act('/tasks/5/complete', {'status': 'delivered'}),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'photo_required')),
    );
    expect(s.queue.pending, 0);
  });

  test('replays that the server refuses are dropped and reported, the rest still goes out', () async {
    var online = false;
    final s = build((o) {
      if (!online) return null;
      return o.path.contains('/tasks/1/') ? json(422, {'message': 'cancelled', 'code': 'task_final'}) : json(200, {'id': 2});
    });
    final rejected = <String>[];
    s.queue.onRejected = (a, e) => rejected.add(e.code!);

    await s.queue.act('/tasks/1/step', {'action': 'arrive'});
    await s.queue.act('/tasks/2/step', {'action': 'arrive'});
    expect(s.queue.pending, 2);

    online = true;
    await s.queue.flush();

    expect(s.queue.pending, 0);
    expect(rejected, ['task_final']);
  });
}
