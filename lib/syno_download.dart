// To parse this JSON data, do
//
//     final synoDownload = synoDownloadFromJson(jsonString);

import 'dart:convert';

SynoDownload synoDownloadFromJson(String str) => SynoDownload.fromJson(json.decode(str));

String synoDownloadToJson(SynoDownload data) => json.encode(data.toJson());

class SynoDownload {
  Data data;
  bool success;

  SynoDownload({
    this.data,
    this.success,
  });

  factory SynoDownload.fromJson(Map<String, dynamic> json) => SynoDownload(
    data: Data.fromJson(json["data"]),
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "success": success,
  };
}

class Data {
  String sid;

  Data({
    this.sid,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    sid: json["sid"],
  );

  Map<String, dynamic> toJson() => {
    "sid": sid,
  };
}
