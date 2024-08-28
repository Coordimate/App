import 'package:coordimate/keys.dart';
import '../response.dart';

const timeSlot = '''{
    _id: ObjectId('66cdf00a7858f64e7f105ece'),
    day: 1,
    start: '2024-08-27 15:35:54.176446Z',
    length: 60,
    is_meeting: true
}''';

void whenUserTimeSlotsNone(client) {
  getResponse(client, '$apiUrl/users/user_id/time_slots', '{"time_slots": []}');
}

void whenUserTimeSlotsOne(client) {
  getResponse(client, '$apiUrl/users/user_id/time_slots',
      '{"time_slots": [$timeSlot]}');
}

void whenGroupTimeSlotsNone(client) {
  getResponse(
      client, '$apiUrl/groups/group_id/time_slots', '{"time_slots": []}');
}

void whenGroupTimeSlotsOne(client) {
  getResponse(client, '$apiUrl/groups/group_id/time_slots',
      '{"time_slots": [$timeSlot]}');
}
