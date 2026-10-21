import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';

/// An action the courier took while the phone had no network.
class QueuedAction {
  QueuedAction({required this.path, required this.body, required this.actionId, required this.at});

  factory QueuedAction.fromJson(Map<String, dynamic> j) => QueuedAction(
        path: j['path'] as String,
        body: (j['body'] as Map?)?.cast<String, dynamic>() ?? {},
        actionId: j['actionId'] as String,
        at: DateTime.parse(j['at'] as String),
      );

  final String path;
  final Map<String, dynamic> body;
  final String actionId;
  final DateTime at;

  Map<String, dynamic> toJson() => {'path': path, 'body': body, 'actionId': actionId, 'at': at.toIso8601String()};
}

/// Result of [ActionQueue.act]: the server's answer, or "saved for later".
class ActResult {
  const ActResult.sent(this.data) : queued = false;
  const ActResult.queued()
      : data = null,
        queued = true;

  final Map<String, dynamic>? data;
  final bool queued;
}

/// Sends state-changing actions with an `X-Action-Id`; when the network is down they wait here
/// and are replayed in order. The server acknowledges a repeated id instead of acting twice.
class ActionQueue {
  ActionQueue(this._api, this._prefs);

  static const _key = 'courier.action_queue';
  final ApiClient _api;
  final SharedPreferences _prefs;
  bool _flushing = false;

  /// Called after a replay the server refused (e.g. dispatch cancelled the task meanwhile).
  void Function(QueuedAction action, ApiException error)? onRejected;

  int get pending => _read().length;

  Future<ActResult> act(String path, [Map<String, dynamic> body = const {}]) async {
    final actionId = const Uuid().v4();
    try {
      return ActResult.sent(await _api.post(path, body: body, actionId: actionId));
    } on ApiException catch (e) {
      if (!e.isNetwork) rethrow; // the server answered: not a network problem
      _write([..._read(), QueuedAction(path: path, body: body, actionId: actionId, at: DateTime.now())]);
      return const ActResult.queued();
    }
  }

  /// Replays queued actions in order; stops at the first one that still cannot reach the server.
  Future<int> flush() async {
    if (_flushing) return 0;
    _flushing = true;
    var sent = 0;
    try {
      final items = _read();
      var index = 0;
      for (; index < items.length; index++) {
        final item = items[index];
        try {
          await _api.post(item.path, body: item.body, actionId: item.actionId);
          sent++;
        } on ApiException catch (e) {
          if (e.isNetwork) break;
          onRejected?.call(item, e);
        }
      }
      _write(items.sublist(index));
    } finally {
      _flushing = false;
    }
    return sent;
  }

  List<QueuedAction> _read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).map((e) => QueuedAction.fromJson((e as Map).cast<String, dynamic>())).toList();
    } catch (_) {
      return [];
    }
  }

  void _write(List<QueuedAction> items) => _prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
}
