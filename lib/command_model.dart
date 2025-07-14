import 'dart:convert';

class Command {
  final String cmd;

  Command({required this.cmd});

  // Convert Command to JSON
  Map<String, dynamic> toJson() {
    return {
      'cmd': cmd,
    };
  }

  // Create Command from JSON
  factory Command.fromJson(Map<String, dynamic> json) {
    return Command(
      cmd: json['cmd'] as String,
    );
  }

  // Encode to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Decode from JSON string
  static Command fromJsonString(String jsonString) {
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return Command.fromJson(jsonMap);
  }

}
