// To parse this JSON data, do
//     final welcome = welcomeFromJson(jsonString);
import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  bool status;
  Data data;

  Welcome({
    required this.status,
    required this.data,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
    status: json["status"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
  };
}

class Data {
  int id;
  String state;
  DateTime createdAt;
  DateTime updatedAt;

  Data({
    required this.id,
    required this.state,

    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    state: json["state"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "state": state,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}