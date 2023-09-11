class FilterConfig {
  List<String> itemTypes;
  List<String> vintage;
  List<String> countries;
  List<Brand> brands;
  List<Unit> units;

  FilterConfig(
      {required this.itemTypes,
      required this.vintage,
      required this.countries,
      required this.brands,
      required this.units});

  factory FilterConfig.fromJson(Map<String, dynamic> json) {
    return FilterConfig(
      itemTypes: List<String>.from(json['item_type']),
      vintage: List<String>.from(json['vintage']),
      countries: List<String>.from(json['country']),
      brands: List<Brand>.from(json['brand'].map((x) => Brand.fromJson(x))),
      units: List<Unit>.from(json['unit'].map((x) => Unit.fromJson(x))),
    );
  }
}

class Brand {
  String name;
  int id;

  Brand({required this.name, required this.id});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      name: json['name'],
      id: json['id'],
    );
  }
}

class Unit {
  String unit;
  int id;

  Unit({required this.unit, required this.id});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      unit: json['unit'],
      id: json['id'],
    );
  }
}
