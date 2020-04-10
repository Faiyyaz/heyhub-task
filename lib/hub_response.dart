// To parse this JSON data, do
//
//     final hubResponse = hubResponseFromJson(jsonString);

import 'dart:convert';

HubResponse hubResponseFromJson(String str) =>
    HubResponse.fromJson(json.decode(str));

String hubResponseToJson(HubResponse data) => json.encode(data.toJson());

class HubResponse {
  Results results;

  HubResponse({
    this.results,
  });

  factory HubResponse.fromJson(Map<String, dynamic> json) => HubResponse(
        results: Results.fromJson(json["results"]),
      );

  Map<String, dynamic> toJson() => {
        "results": results.toJson(),
      };
}

class Results {
  String type;
  int id;
  Bounds bounds;
  List<List<Geometry>> geometry;
  Tags tags;

  Results({
    this.type,
    this.id,
    this.bounds,
    this.geometry,
    this.tags,
  });

  factory Results.fromJson(Map<String, dynamic> json) => Results(
        type: json["type"],
        id: json["id"],
        bounds: Bounds.fromJson(json["bounds"]),
        geometry: List<List<Geometry>>.from(json["geometry"].map(
            (x) => List<Geometry>.from(x.map((x) => Geometry.fromJson(x))))),
        tags: Tags.fromJson(json["tags"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
        "bounds": bounds.toJson(),
        "geometry": List<dynamic>.from(
            geometry.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
        "tags": tags.toJson(),
      };
}

class Bounds {
  double minlat;
  double minlon;
  double maxlat;
  double maxlon;

  Bounds({
    this.minlat,
    this.minlon,
    this.maxlat,
    this.maxlon,
  });

  factory Bounds.fromJson(Map<String, dynamic> json) => Bounds(
        minlat: json["minlat"].toDouble(),
        minlon: json["minlon"].toDouble(),
        maxlat: json["maxlat"].toDouble(),
        maxlon: json["maxlon"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "minlat": minlat,
        "minlon": minlon,
        "maxlat": maxlat,
        "maxlon": maxlon,
      };
}

class Geometry {
  double lat;
  double lon;

  Geometry({
    this.lat,
    this.lon,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        lat: json["lat"].toDouble(),
        lon: json["lon"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lon": lon,
      };
}

class Tags {
  String name;

  Tags({
    this.name,
  });

  factory Tags.fromJson(Map<String, dynamic> json) => Tags(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}
