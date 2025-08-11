enum Order {
  asc,
  desc;

  factory Order.fromName(String name) =>
      values.firstWhere((element) => element.name == name);
}
