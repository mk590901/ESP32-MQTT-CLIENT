// --- App BLoC (for Start/Stop и Mode1/Mode2) ---
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../data_packet.dart';
import '../gui_adapter/service_adapter.dart';
import '../service_components/foreground_service.dart';

abstract class Esp32Event {}

class StartEcg extends Esp32Event {}

class FinalEcg extends Esp32Event {}


class Esp32State {
  final bool isRunning;

  Esp32State( {
    required this.isRunning,
  });

  Esp32State copyWith({
    bool? isRunning, }) {
    return Esp32State(
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class Esp32Bloc extends Bloc<Esp32Event, Esp32State> {

  late StreamSubscription? _dataSubscription;

  Esp32Bloc() : super(Esp32State(isRunning: false)) {

    ServiceAdapter.instance()?.setEsp32Bloc(this);

    on<StartEcg>((event, emit) async {
      emit(Esp32State(
        isRunning: true,
      ));
    });

    on<FinalEcg>((event, emit) async {
      await FlutterForegroundTask.stopService();
      emit(Esp32State(isRunning: false, ));
    });

  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }

}
