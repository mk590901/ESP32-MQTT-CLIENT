// Control panel (Start/Stop и Switch)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../gui_adapter/service_adapter.dart';
import '../ui_blocks/app_bloc.dart';
import '../ui_blocks/esp32_bloc.dart';
import '../ui_blocks/items_bloc.dart';
import '../ui_blocks/mqtt_bloc.dart';
import '../utils.dart';

class Esp32lPanel extends StatelessWidget {
  const Esp32lPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Esp32Bloc, Esp32State>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (state.isRunning) {
                        context.read<Esp32Bloc>().add(FinalEcg());
                      }
                      else {
                        context.read<Esp32Bloc>().add(StartEcg());
                      }
                    },
                    child: Text(state.isRunning ? 'ECG Final' : 'ECG Start'),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      if (context.read<AppBloc>().state.isRunning) {
                        if (context.read<MqttBloc>().state.isConnected
                            &&  context.read<MqttBloc>().state.isSubscribed) {
                          ServiceAdapter.instance()?.send2Esp32('stop');
                          showToast(context, "The application running on the ESP32-S3 has been terminated and cannot be used any further. Please restart it with jag to resume interaction.");
                        }
                        else {
                          showToast(context, "MQTT problems");
                        }
                      }
                      else {
                        showToast(context, "Service isn't run");
                      }
                    },
                    child: Text('Stop ESP32-S3', ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
