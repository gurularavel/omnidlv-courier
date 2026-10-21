import 'package:flutter_test/flutter_test.dart';
import 'package:omnidlv_courier/data/models.dart';
import 'package:omnidlv_courier/state/providers.dart';

void main() {
  test('parses the board the server sends, including the next stop', () {
    final board = Board.fromJson({
      'courier': {'id': 7, 'name': 'Ayxan Rüstəmov', 'ink': '#14b8a6'},
      'company': 'Demo Logistika',
      'shift': {'active': true, 'started_label': '09:02'},
      'next': {
        'id': 21,
        'code': 'ODAQ9EQXAT4ZT3',
        'type': 'drop_off',
        'category': 'on_delivery',
        'status': 'Ünvana çatdı',
        'minutes': 125,
        'minutes_label': '2s 5d',
        'minutes_in_hours': true,
        'urgency': 'ok',
        'window': '12:00–14:00',
        'cash': 34.5,
        'target': {'name': 'Leyla', 'address': 'Füzuli küç. 12', 'lat': '40.377300', 'lng': 49.8389},
        'requirements': {'photo': true, 'photo_mandatory': false, 'code': true, 'code_mandatory': true},
        'items': [
          {'id': 1, 'name': 'Qəhvə maşını', 'quantity': 1, 'scanned': false},
        ],
        'next': 'complete',
        'can_complete': false,
        'navigate': {'google': 'https://www.google.com/maps/dir/?api=1&destination=40.3773,49.8389', 'waze': null},
      },
      'active': [
        {'id': 21, 'code': 'ODAQ9EQXAT4ZT3', 'category': 'on_delivery', 'urgency': 'late'},
        {'id': 22, 'code': 'ODB3SP5CR6B6GU', 'category': 'assigned'},
      ],
      'pool': [],
      'done': [],
      'counts': {'delivered': 3, 'failed': 1, 'cash': 34.5},
    });

    expect(board.shiftActive, isTrue);
    expect(board.next!.target.lat, 40.3773, reason: 'numbers may arrive as strings');
    expect(board.next!.minutesInHours, isTrue);
    expect(board.next!.requirements.codeMandatory, isTrue);
    expect(board.next!.canComplete, isFalse);
    expect(board.next!.canNavigate, isTrue);
    expect(board.next!.items.single.name, 'Qəhvə maşını');
    expect(board.active.first.urgency, Urgency.late);
    expect(board.delivered, 3);
  });

  test('missing optional fields never crash', () {
    final task = TaskDetail.fromJson({'id': 1});
    expect(task.code, '');
    expect(task.items, isEmpty);
    expect(task.next, isNull);
    expect(task.canNavigate, isFalse);
  });

  test('compares app versions for the forced update', () {
    expect(compareVersions('1.0.0', '1.0.0'), 0);
    expect(compareVersions('1.0.9', '1.1.0'), lessThan(0));
    expect(compareVersions('1.10.0', '1.9.3'), greaterThan(0));
    expect(compareVersions('2.0.0+15', '2.0'), 0);
  });
}
