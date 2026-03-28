// To parse this JSON data, do
//
//     final synoBt = synoBtFromJson(jsonString);

import 'dart:convert';

SynoBt synoBtFromJson(String str) => SynoBt.fromJson(json.decode(str));

String synoBtToJson(SynoBt data) => json.encode(data.toJson());

class SynoBt {
  Data data;
  bool success;

  SynoBt({
    required this.data,
    required this.success,
  });

  factory SynoBt.fromJson(Map<String, dynamic> json) => SynoBt(
        data: Data.fromJson(json["data"]),
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "success": success,
      };
}

class Data {
  bool? finished;
  List<Item> items;
  int? offset;
  int? total;

  Data({
    this.finished,
    required this.items,
    this.offset,
    this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        finished: json["finished"],
        items: json["items"] == null
            ? []
            : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        offset: json["offset"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "finished": finished,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "offset": offset,
        "total": total,
      };
}

class Item {
  DateTime date;
  String downloadUri;
  String externalLink;
  int id;
  int leechs;
  String moduleId;
  String moduleTitle;
  int peers;
  int seeds;
  String size;
  String title;

  bool picked = false;

  Item({
    required this.date,
    required this.downloadUri,
    required this.externalLink,
    required this.id,
    required this.leechs,
    required this.moduleId,
    required this.moduleTitle,
    required this.peers,
    required this.seeds,
    required this.size,
    required this.title,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        date: DateTime.parse(json["date"]),
        downloadUri: json["download_uri"],
        externalLink: json["external_link"],
        id: json["id"],
        leechs: json["leechs"],
        moduleId: json["module_id"],
        moduleTitle: json["module_title"],
        peers: json["peers"],
        seeds: json["seeds"],
        size: json["size"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "download_uri": downloadUri,
        "external_link": externalLink,
        "id": id,
        "leechs": leechs,
        "module_id": moduleId,
        "module_title": moduleTitle,
        "peers": peers,
        "seeds": seeds,
        "size": size,
        "title": title,
      };
}
