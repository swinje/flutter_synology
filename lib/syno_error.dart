// To parse this JSON data, do
//
//     final synoError = synoErrorFromJson(jsonString);

import 'dart:convert';

SynoError synoErrorFromJson(String str) => SynoError.fromJson(json.decode(str));

String synoErrorToJson(SynoError data) => json.encode(data.toJson());

class SynoError {
  Error error;
  bool success;

  SynoError({
    required this.error,
    required this.success,
  });

  factory SynoError.fromJson(Map<String, dynamic> json) => SynoError(
        error: Error.fromJson(json["error"]),
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "error": error.toJson(),
        "success": success,
      };
}

class Error {
  int code;

  Error({
    required this.code,
  });

  factory Error.fromJson(Map<String, dynamic> json) => Error(
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
      };
}
