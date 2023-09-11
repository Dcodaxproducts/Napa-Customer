import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/view/screens/cart/cart_screen.dart';
import 'package:sixam_mart/view/screens/favourite/favourite_screen.dart';
import 'package:sixam_mart/view/screens/home/home_screen.dart';
import 'package:sixam_mart/view/screens/item/item_details_screen.dart';
import 'package:sixam_mart/view/screens/menu/menu_screen.dart';
import 'package:sixam_mart/view/screens/order/order_screen.dart';

class DashboardController extends GetxController implements GetxService {
  static DashboardController get to => Get.find<DashboardController>();

  PageController? pageController;
  int _pageIndex = 0;

  int get pageIndex => _pageIndex;

  List<Widget> screens = [
    const HomeScreen(),
    const FavouriteScreen(),
    const CartScreen(fromNav: true),
    const OrderScreen(),
    const MenuScreen(),
    const ItemDetailsScreen()
  ];

  init(int index) {
    _pageIndex = index;
    pageController = PageController(initialPage: index);
    update();
  }

  set pageIndex(int index) {
    _pageIndex = index;
    update();
  }

  setPage(int index, {Item? item, bool inStorePage = false}) {
    _pageIndex = index;
    if (index == 5) {
      screens[5] = ItemDetailsScreen(item: item, inStorePage: inStorePage);
    }
    pageController!.jumpToPage(index);
    update();
  }
}
