// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:esp32_ecg_mqtt_client/data_packet.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esp32_ecg_mqtt_client/main.dart';

void main() {

  test('base64', () {
    List<double> listIn = [12.5, 23.5, 34.5, 45.5, 56.5, 67.5];
    print ('listIn->$listIn');
    DataPacket dataPacket = DataPacket.empty();
    String base64string = dataPacket.base64encode(listIn);
    print ('base64string->$base64string');
    List<double> listOut = DataPacket.empty().base64decode(base64string);
    print ('listOut->$listOut');

  });

  test('DataPacket1', () {
    String base64string = 'AAAAAAAAKUAAAAAAAIA3QAAAAAAAQEFAAAAAAADARkAAAAAAAEBMQAAAAAAA4FBAAAAAAAAAAAAAAAAAAAAAAA==';
    List<double> list = DataPacket.empty().base64decode(base64string);
    print ('list->$list');
  });

  test('DataPacket2', () {
    String base64string = 'AAAAAAAAKUAAAAAAAIA3QAAAAAAAQEFAAAAAAADARkAAAAAAAEBMQAAAAAAA4FBAAAAAAACgU0AAAAAAAGBWQA==';
    List<double> list = DataPacket.empty().base64decode(base64string);
    print ('list->$list');
  });

  test('DataPacket1a', () {
    String base64string = 'AAAAAAAAKUAAAAAAAIA3QAAAAAAAQEFAAAAAAADARkAAAAAAAEBMQAAAAAAA4FBAAAAAAAAAAAAAAAAAAAAAAA==';
    List<double> list = DataPacket.empty().base64restore(base64string,6);
    print ('list->$list');
  });

  test('DataPacket2a', () {
    String base64string = 'AAAAAAAAKUAAAAAAAIA3QAAAAAAAQEFAAAAAAADARkAAAAAAAEBMQAAAAAAA4FBAAAAAAACgU0AAAAAAAGBWQA==';
    List<double> list = DataPacket.empty().base64restore(base64string,8);
    print ('list->$list');
  });

  test('Restore DataPacket', () {
    String jsonStr = '{"sensor_id":"sensor123","sensor_name":"ESP32-S3","series_length":3,"raw_data":"AAAAAACAN0AAAAAAAAA4QAAAAAAAgDhAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="}';
    DataPacket packet = DataPacket.empty().restore(jsonStr);
    packet.trace();
  });
}
