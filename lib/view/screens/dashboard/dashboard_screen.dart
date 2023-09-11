import 'dart:async';

import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/scheduler.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/dashboard_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/view/base/cart_widget.dart';
import 'package:sixam_mart/view/screens/dashboard/widget/bottom_nav_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/category_controller.dart';
import 'widget/running_order_view_widget.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  const DashboardScreen({Key? key, required this.pageIndex}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;

  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  late bool _isLogin;

  @override
  void initState() {
    super.initState();

    if (Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }

    _isLogin = Get.find<AuthController>().isLoggedIn();

    if (_isLogin) {
      Get.find<OrderController>().getRunningOrders(1);
    }

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      DashboardController.to.init(widget.pageIndex);
      if (widget.pageIndex != 0) {
        DashboardController.to.setPage(widget.pageIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (con) {
      return WillPopScope(
        onWillPop: () async {
          if (con.pageIndex != 0) {
            _setPage(0);
            return false;
          } else {
            if (!ResponsiveHelper.isDesktop(context) &&
                Get.find<SplashController>().module != null &&
                Get.find<SplashController>().configModel!.module == null) {
              Get.find<SplashController>().setModule(null);
              return false;
            } else {
              if (_canExit) {
                return true;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('back_press_again_to_exit'.tr,
                      style: const TextStyle(color: Colors.white)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                ));
                _canExit = true;
                Timer(const Duration(seconds: 2), () {
                  _canExit = false;
                });
                return false;
              }
            }
          }
        },
        child: GetBuilder<OrderController>(builder: (orderController) {
          List<OrderModel> runningOrder =
              orderController.runningOrderModel != null
                  ? orderController.runningOrderModel!.orders!
                  : [];

          List<OrderModel> reversOrder = List.from(runningOrder.reversed);

          return Scaffold(
            key: _scaffoldKey,
            floatingActionButton: con.pageIndex == 2
                ? null
                : ResponsiveHelper.isDesktop(context)
                    ? null
                    : (orderController.showBottomSheet &&
                            orderController.runningOrderModel != null &&
                            orderController
                                .runningOrderModel!.orders!.isNotEmpty)
                        ? const SizedBox()
                        : FloatingActionButton(
                            elevation: 5,
                            backgroundColor: con.pageIndex == 2
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor,
                            onPressed: () {
                              // log('message');
                              // if(Get.find<SplashController>().module != null) {
                              _setPage(2);
                              // }else{
                              //   showCustomSnackBar('please_select_any_module'.tr);
                              // }
                            },
                            child: CartWidget(
                                color: con.pageIndex == 2
                                    ? Theme.of(context).cardColor
                                    : Theme.of(context).disabledColor,
                                size: 30),
                          ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: ResponsiveHelper.isDesktop(context)
                ? const SizedBox()
                : (orderController.showBottomSheet &&
                        orderController.runningOrderModel != null &&
                        orderController.runningOrderModel!.orders!.isNotEmpty)
                    ? const SizedBox()
                    : BottomAppBar(
                        elevation: 5,
                        notchMargin: 5,
                        clipBehavior: Clip.antiAlias,
                        shape: const CircularNotchedRectangle(),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall),
                          child: Row(children: [
                            BottomNavItem(
                                iconData: Icons.home_filled,
                                isSelected: con.pageIndex == 0,
                                onTap: () => _setPage(0)),
                            BottomNavItem(
                                iconData: Icons.favorite_border_rounded,
                                isSelected: con.pageIndex == 1,
                                onTap: () => _setPage(1)),
                            const Expanded(child: SizedBox()),
                            BottomNavItem(
                                iconData: Icons.shopping_basket_outlined,
                                isSelected: con.pageIndex == 3,
                                onTap: () => _setPage(3)),
                            BottomNavItem(
                                iconData: Icons.menu_open,
                                isSelected: con.pageIndex == 4,
                                onTap: () {
                                  _setPage(4);
                                  // Get.bottomSheet(const MenuScreen(),
                                  //     backgroundColor: Colors.transparent,
                                  //     isScrollControlled: true);
                                }),
                          ]),
                        ),
                      ),
            body: ExpandableBottomSheet(
              background: PageView.builder(
                controller: con.pageController,
                itemCount: con.screens.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return con.screens[index];
                },
              ),
              persistentContentHeight: 100,
              onIsContractedCallback: () {
                if (!orderController.showOneOrder) {
                  orderController.showOrders();
                }
              },
              onIsExtendedCallback: () {
                if (orderController.showOneOrder) {
                  orderController.showOrders();
                }
              },
              enableToggle: true,
              expandableContent: (ResponsiveHelper.isDesktop(context) ||
                      !_isLogin ||
                      orderController.runningOrderModel == null ||
                      orderController.runningOrderModel!.orders!.isEmpty ||
                      !orderController.showBottomSheet)
                  ? const SizedBox()
                  : Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        if (orderController.showBottomSheet) {
                          orderController.showRunningOrders();
                        }
                      },
                      child: RunningOrderViewWidget(reversOrder: reversOrder),
                    ),
            ),
          );
        }),
      );
    });
  }

  void _setPage(int pageIndex) => DashboardController.to.setPage(pageIndex);

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(
        height: 3,
        decoration: BoxDecoration(
            color: status
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault)));
  }
}
