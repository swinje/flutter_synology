// To parse this JSON data, do
//
//     final synoAuth = synoAuthFromJson(jsonString);

import 'dart:convert';

SynoAuth synoAuthFromJson(String str) => SynoAuth.fromJson(json.decode(str));

String synoAuthToJson(SynoAuth data) => json.encode(data.toJson());

class SynoAuth {
  Data? data;
  bool? success;

  SynoAuth({
    this.data,
    this.success,
  });

  factory SynoAuth.fromJson(Map<String, dynamic> json) => SynoAuth(
        data: Data.fromJson(json["data"]),
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "data": data!.toJson(),
        "success": success,
      };
}

class Data {
  Syno? synoApiAuth;
  Syno? synoDownloadStationTask;

  Data({
    this.synoApiAuth,
    this.synoDownloadStationTask,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        synoApiAuth: Syno.fromJson(json["SYNO.API.Auth"]),
        synoDownloadStationTask:
            Syno.fromJson(json["SYNO.DownloadStation.Task"]),
      );

  Map<String, dynamic> toJson() => {
        "SYNO.API.Auth": synoApiAuth!.toJson(),
        "SYNO.DownloadStation.Task": synoDownloadStationTask!.toJson(),
      };
}

class Syno {
  int maxVersion;
  int minVersion;
  String path;

  Syno({
    required this.maxVersion,
    required this.minVersion,
    required this.path,
  });

  factory Syno.fromJson(Map<String, dynamic> json) => Syno(
        maxVersion: json["maxVersion"],
        minVersion: json["minVersion"],
        path: json["path"],
      );

  Map<String, dynamic> toJson() => {
        "maxVersion": maxVersion,
        "minVersion": minVersion,
        "path": path,
      };
}
