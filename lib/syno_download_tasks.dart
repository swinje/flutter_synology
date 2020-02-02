// To parse this JSON data, do
//
//     final synoDownloadTasks = synoDownloadTasksFromJson(jsonString);

import 'dart:convert';

SynoDownloadTasks synoDownloadTasksFromJson(String str) => SynoDownloadTasks.fromJson(json.decode(str));

String synoDownloadTasksToJson(SynoDownloadTasks data) => json.encode(data.toJson());

class SynoDownloadTasks {
  Data data;
  bool success;

  SynoDownloadTasks({
    this.data,
    this.success,
  });

  factory SynoDownloadTasks.fromJson(Map<String, dynamic> json) => SynoDownloadTasks(
    data: Data.fromJson(json["data"]),
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "success": success,
  };
}

class Data {
  int total;
  int offset;
  List<Task> tasks;

  Data({
    this.total,
    this.offset,
    this.tasks,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    total: json["total"],
    offset: json["offset"],
    tasks: List<Task>.from(json["tasks"].map((x) => Task.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "offset": offset,
    "tasks": List<dynamic>.from(tasks.map((x) => x.toJson())),
  };
}

class Task {
  String id;
  String type;
  String username;
  String title;
  int size;
  String status;
  dynamic statusExtra;

  Task({
    this.id,
    this.type,
    this.username,
    this.title,
    this.size,
    this.status,
    this.statusExtra,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json["id"],
    type: json["type"],
    username: json["username"],
    title: json["title"],
    size: json["size"],
    status: json["status"],
    statusExtra: json["status_extra"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "username": username,
    "title": title,
    "size": size,
    "status": status,
    "status_extra": statusExtra,
  };
}
