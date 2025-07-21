// --- App BLoC (for Start/Stop и Mode1/Mode2) ---
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../data_packet.dart';
import '../gui_adapter/service_adapter.dart';
import '../service_components/foreground_service.dart';

abstract class AppEvent {}

class StartService extends AppEvent {}

class StopService extends AppEvent {}

class UpdateData extends AppEvent {
  final int counter;
  UpdateData(this.counter);
}

class SendData extends AppEvent {
  final String command;
  final String data;
  SendData(this.command, this.data);
}

class AppState {
  final bool isRunning;
  final int counter;
  final String sentData;

  AppState( {
    required this.isRunning,
    this.counter = 0,
    this.sentData = '',
  });

  AppState copyWith({
    bool? isRunning,
  }) {
    return AppState(
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class AppBloc extends Bloc<AppEvent, AppState> {

  late StreamSubscription? _dataSubscription;

  AppBloc() : super(AppState(isRunning: false/*, isServer: true*/)) {

    ServiceAdapter.instance()?.setAppBloc(this);

    FlutterForegroundTask.isRunningService.then((isRunning) {
      emit(AppState(
        isRunning: isRunning,
        counter: state.counter,
       ));
    });

    _dataSubscription = FlutterForegroundTask.receivePort?.listen((data) {

      if (data is Map && data.containsKey('response') && data.containsKey('value')) {
        String command = data['response'] as String;
        print('listener.command->[$command]');
        if (command == 'counter') {
          int counter = data['value'] as int;
          add(UpdateData(counter));
        }

        if (command == 'destroy') {
          String id = data['value'] as String;
          print ('******* DESTROY OBJECT [$id] *******');
          ServiceAdapter.instance()?.destroyObject(id);
        }

        if (command == 'sync') {
          String jsonString = data['value'] as String;
          DataPacket targetDataPacket = DataPacket.empty().decode(jsonString);
          //DataPacket targetDataPacket = DataPacket.empty().restore(jsonString);
          String id = targetDataPacket.sensorId;
          String name = targetDataPacket.sensorName;
          int length =  targetDataPacket.seriesLength;
          List<double> rawData = targetDataPacket.rawData;
          print ('listener.command->sync [$id]:[$name]:[$length]->(${rawData.length})');
          ServiceAdapter.instance()?.createGuiItem(id, name, length);
          ServiceAdapter.instance()?.updateRawData(id, rawData);
        }

        if (command == 'Connected') {
          String value = data['value'] as String;
          print ('AppBloc.Connected->[$value]');
          ServiceAdapter.instance()?.mqttConnect();
        }

        if (command == 'Disconnected') {
          String value = data['value'] as String;
          print ('AppBloc.Disconnected->[$value]');
          ServiceAdapter.instance()?.mqttDisconnect();
        }

        if (command == 'Subscribed') {
          String value = data['value'] as String;
          print ('AppBloc.Subscribed->[$value]');
          ServiceAdapter.instance()?.mqttSubscribe();
        }

        if (command == 'Unsubscribed') {
          String value = data['value'] as String;
          print ('AppBloc.Unsubscribed->[$value]');
          ServiceAdapter.instance()?.mqttUnsubscribe();
        }

        if (command == 'Publish') {
          String value = data['value'] as String;
          print ('AppBloc.Publish->[$value]');
        }

        if (command == 'mqtt') {
          Map value = data['value'] as Map;
          print ('AppBloc.mqtt->[$value]');
          bool connected = value['connected'] as bool;
          bool subscribed = value['subscribed'] as bool;
          connected  ? ServiceAdapter.instance()?.mqttConnect() : ServiceAdapter.instance()?.mqttDisconnect();
          subscribed ? ServiceAdapter.instance()?.mqttSubscribe() : ServiceAdapter.instance()?.mqttUnsubscribe();
        }

        if (command == 'progress') {
          bool progress = data['value'] as bool;
          ServiceAdapter.instance()?.setProgress(progress);
        }

      }
    });

    on<StartService>((event, emit) async {
      bool isRunning = await FlutterForegroundTask.isRunningService;
      if (!isRunning) {
        await FlutterForegroundTask.startService(
          notificationTitle: 'Foreground Service',
          notificationText: 'Starting...',
          callback: startCallback,
        );
        emit(AppState(
          isRunning: true,
          counter: state.counter,
        ));
        FlutterForegroundTask.sendData({'command': 'phone_id', 'data': ServiceAdapter.instance()?.getDeviceName()?? '?DeviceName'});
      }
      else {
        print('------- Service already running -------');
      }
    });

    on<StopService>((event, emit) async {
      ServiceAdapter.instance()?.sendCommand2Esp32('finalEcg');
      ServiceAdapter.instance()?.sendCommand2Esp32('stop');
      await FlutterForegroundTask.stopService();
      emit(AppState(isRunning: false, counter: 0, ));
    });

    on<UpdateData>((event, emit) {
      emit(AppState(
        isRunning: state.isRunning,
        counter: event.counter,
      ));
    });

    on<SendData>((event, emit) async {
      print('Sending data to service: ${event.command}:${event.data}');
      FlutterForegroundTask.sendData({'command': event.command, 'data': event.data});

      emit(AppState(
        isRunning: state.isRunning,
        counter: state.counter,
        sentData: event.data, //  command?
      ));
    });

  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }

}
