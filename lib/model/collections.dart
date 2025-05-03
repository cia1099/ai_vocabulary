import 'dart:convert';

abstract class BookMark {
  final int id;
  String name;
  int index;

  BookMark({required this.name, this.id = 0, this.index = -1});

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
  CollectionMark({
    this.color,
    this.icon,
    required super.id,
    required super.name,
    required super.index,
  });

  factory CollectionMark.fromRawJson(String str) =>
      CollectionMark.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CollectionMark.fromJson(Map<String, dynamic> json) => CollectionMark(
    id: json["id"],
    name: json["name"],
    index: json["index"],
    icon: json["icon"],
    color: json["color"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "index": index,
    "icon": icon,
    "color": color,
  };
}

class SystemMark extends BookMark {
  SystemMark({required super.name, required super.index, super.id});
}

class IncludeWordMark extends BookMark {
  bool included;
  IncludeWordMark({
    required super.id,
    required super.name,
    super.index,
    this.included = false,
  });
}
