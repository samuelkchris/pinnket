class Categories {
  final String id;
  final String name;
  final List<EventSubCategory> eventSubCategories;

  Categories(
      {required this.id, required this.name, required this.eventSubCategories});

  factory Categories.fromJson(Map<String, dynamic> json) {
    var list = json['eventSubCategories'] as List;
    List<EventSubCategory> eventSubCategoryList =
    list.map((i) => EventSubCategory.fromJson(i)).toList();

    return Categories(
      id: json['id'],
      name: json['name'],
      eventSubCategories: eventSubCategoryList,
    );
  }
}

class EventSubCategory {
  final String id;
  final String cid;
  final String name;

  EventSubCategory({required this.id, required this.cid, required this.name});

  factory EventSubCategory.fromJson(Map<String, dynamic> json) {
    return EventSubCategory(
      id: json['id'],
      cid: json['cid'],
      name: json['name'],
    );
  }
}