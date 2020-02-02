// To parse this JSON data, do
//
//     final synoTask = synoTaskFromJson(jsonString);

import 'dart:convert';

SynoTask synoTaskFromJson(String str) => SynoTask.fromJson(json.decode(str));

String synoTaskToJson(SynoTask data) => json.encode(data.toJson());

class SynoTask {
  Data data;
  bool success;

  SynoTask({
    this.data,
    this.success,
  });

  factory SynoTask.fromJson(Map<String, dynamic> json) => SynoTask(
    data: Data.fromJson(json["data"]),
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "success": success,
  };
}

class Data {
  String taskid;

  Data({
    this.taskid,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    taskid: json["taskid"],
  );

  Map<String, dynamic> toJson() => {
    "taskid": taskid,
  };
}
