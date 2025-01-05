import 'dart:convert';

abstract class BookMark {
  String name;
  int index;

  BookMark({required this.name, this.index = -1});

  @override
  bool operator ==(Object rhs) {
    if (identical(this, rhs)) return true;
    if (rhs is! BookMark) return false;
    return name == rhs.name;
  }

  @override
  int get hashCode => Object.hash(name, index);
}

class CollectionMark extends BookMark {
  int? color;
  int? icon;
  CollectionMark(
      {this.color, this.icon, required super.name, required super.index});

  factory CollectionMark.fromRawJson(String str) =>
      CollectionMark.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CollectionMark.fromJson(Map<String, dynamic> json) => CollectionMark(
        name: json["name"],
        index: json["index"],
        icon: json["icon"],
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "index": index,
        "icon": icon,
        "color": color,
      };
}

class SystemMark extends BookMark {
  SystemMark({required super.name, required super.index});
}

class IncludeWordMark extends BookMark {
  bool included;
  IncludeWordMark(
      {required super.name, required super.index, this.included = false});
}
