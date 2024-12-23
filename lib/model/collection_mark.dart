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
  CollectionMark({required super.name, required super.index});
}

class SystemMark extends BookMark {
  SystemMark({required super.name, required super.index});
}
