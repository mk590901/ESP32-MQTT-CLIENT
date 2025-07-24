// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:math';

import 'package:esp32_ecg_mqtt_client/data_packet.dart';
import 'package:esp32_ecg_mqtt_client/ecg_simulator/ecg_simulator.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('Simulation', () {
    EcgSimulator simulator = EcgSimulator(128);
    for (int i = 0; i < 1; i++) {
      List<int> data = simulator.generateBuffer();
      print ("$i");
      print ("$data");
    }
  });

  test('ECG', () {
    List<double> ecg = generateECG();
    for (int i = 0; i < ecg.length; i++) {
      print('${(ecg[i]).toInt()}');
    }
  });
}

// ECG parameters
const double heartRate = 60;    //  Heart rate (beats per minute)
const double sampleRate = 128;  //  Sampling frequency (Hz)
const double duration = 1.0;    //  Signal duration in seconds

// Wave amplitudes and durations
const double pWaveAmp = 0.15;   //  P-wave amplitude
const double qrsAmp = 1.0;      //  QRS complex amplitude
const double tWaveAmp = 0.20;   //  T-wave amplitude
const double pDuration = 0.1;   //  P-wave duration
const double qrsDuration = 0.1; //  QRS complex duration
const double tDuration = 0.2;   //  P-wave duration
const double noise = 0.2;       //  Noise (% from ECG signal value)

List<double> generateECG() {
  List<double> ecgSignal = [];
  double period = 60.0 / heartRate;   //  Period of one cardiac cycle
  int samples = (duration * sampleRate).toInt();

  for (int i = 0; i < samples; i++) {
    double t = i / sampleRate;
    double modT = t % period;         //  Time within one cycle

    double signal = 0.0;

    //  P-wave (Gaussian function)
    double pCenter = 0.1 * period;
    signal += pWaveAmp * exp(-pow((modT - pCenter) / pDuration, 2));

    // QRS complex (combination of Gaussian functions)
    double qrsCenter = 0.4 * period;
    signal += -0.2 * qrsAmp * exp(-pow((modT - (qrsCenter - 0.025)) / (qrsDuration / 3), 2)); // Q
    signal += qrsAmp * exp(-pow((modT - qrsCenter) / (qrsDuration / 2), 2)); // R
    signal += -0.3 * qrsAmp * exp(-pow((modT - (qrsCenter + 0.025)) / (qrsDuration / 3), 2)); // S

    // T-wave (Gaussian function)
    double tCenter = 0.7 * period;
    signal += tWaveAmp * exp(-pow((modT - tCenter) / tDuration, 2));

    signal *= 1000;
    int n = getRandomValue(0, (signal*noise).toInt());
    ecgSignal.add(signal + n.toDouble());
  }
  return ecgSignal;
}

int getRandomValue(final int min, final int max) {
  return Random().nextInt(max - min + 1) + min;
}
