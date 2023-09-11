class MenuModel {
  String icon;
  String title;
  String route;
  bool? trailing;

  MenuModel(
      {required this.icon,
      required this.title,
      required this.route,
      this.trailing = false});
}
