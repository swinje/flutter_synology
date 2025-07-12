// To parse this JSON data, do
//
//     final synoDownloadTasks = synoDownloadTasksFromJson(jsonString);

import 'dart:convert';

SynoDownloadTasks synoDownloadTasksFromJson(String str) =>
    SynoDownloadTasks.fromJson(json.decode(str));

String synoDownloadTasksToJson(SynoDownloadTasks data) =>
    json.encode(data.toJson());

class SynoDownloadTasks {
  Data data;
  bool success;

  SynoDownloadTasks({
    required this.data,
    required this.success,
  });

  factory SynoDownloadTasks.fromJson(Map<String, dynamic> json) =>
      SynoDownloadTasks(
        data: Data.fromJson(json["data"]),
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "success": success,
      };

  @override
  String toString() {
    return data.toString() + " success " + success.toString();
  }
}

class Data {
  int total;
  int offset;
  List<Task> tasks;

  Data({
    required this.total,
    required this.offset,
    required this.tasks,
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

  @override
  String toString() {
    return total.toString() + " " + offset.toString() + " " + tasks.toString();
  }
}

class Task {
  String id;
  String type;
  String username;
  String title;
  int size;
  int downloaded;
  String status;
  dynamic statusExtra;

  Task({
    required this.id,
    required this.type,
    required this.username,
    required this.title,
    required this.size,
    required this.downloaded,
    required this.status,
    required this.statusExtra,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
      id: json["id"],
      type: json["type"],
      username: json["username"],
      title: json["title"],
      size: json["size"],
      status: json["status"],
      statusExtra: json["status_extra"],
      downloaded: json["additional"] != null
          ? json["additional"]["file"] != null
              ? json["additional"]["file"].contains(1)
                  ? (json["additional"]["file"][1]['size_downloaded'] /
                          json["size"] *
                          100)
                      .round()
                  : 0
              : 0
          : 0);

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "username": username,
        "title": title,
        "size": size,
        "status": status,
        "status_extra": statusExtra,
      };

  @override
  String toString() {
    return ("id $id  type $type username $username title $title size $size status $status status_extra $statusExtra downloaded $downloaded");
  }
}
