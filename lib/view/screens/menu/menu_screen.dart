import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/model/response/menu_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/view/screens/menu/widget/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/styles.dart';
import '../../base/custom_image.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();
  late List<MenuModel> _menuList;
  @override
  void initState() {
    super.initState();

    if (_isLoggedIn && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    _menuList = [
      MenuModel(
          icon: Images.profile,
          title: 'profile'.tr,
          route: RouteHelper.getProfileRoute()),
      MenuModel(
          icon: Images.location,
          title: 'my_address'.tr,
          route: RouteHelper.getAddressRoute()),
      MenuModel(
          icon: Images.language,
          title: 'language'.tr,
          route: RouteHelper.getLanguageRoute('menu')),
      MenuModel(
          icon: Images.notification,
          title: 'notification'.tr,
          route: RouteHelper.getNotificationRoute()),
      MenuModel(
          icon: Images.orders,
          title: 'my_orders'.tr,
          route: RouteHelper.getOrderRoute()),
      MenuModel(
          icon: Images.darkmode,
          title: 'dark_mode'.tr,
          route: '',
          trailing: true),
      MenuModel(
          icon: Images.coupon,
          title: 'coupon'.tr,
          route: RouteHelper.getCouponRoute()),
      MenuModel(
          icon: Images.support,
          title: 'help_support'.tr,
          route: RouteHelper.getSupportRoute()),
      MenuModel(
          icon: Images.policy,
          title: 'privacy_policy'.tr,
          route: RouteHelper.getHtmlRoute('privacy-policy')),
      MenuModel(
          icon: Images.aboutUs,
          title: 'about_us'.tr,
          route: RouteHelper.getHtmlRoute('about-us')),
      MenuModel(
          icon: Images.terms,
          title: 'terms_conditions'.tr,
          route: RouteHelper.getHtmlRoute('terms-and-condition')),
      MenuModel(
          icon: Images.chat,
          title: 'live_chat'.tr,
          route: RouteHelper.getConversationRoute()),

      ///only for taxi module.. will come soon.
      // MenuModel(icon: Images.orders, title: 'trip_order'.tr, route: RouteHelper.getTripHistoryScreen()),
    ];

    if (Get.find<SplashController>().configModel!.refundPolicyStatus == 1) {
      _menuList.add(MenuModel(
          icon: Images.refund,
          title: 'refund_policy'.tr,
          route: RouteHelper.getHtmlRoute('refund-policy')));
    }
    if (Get.find<SplashController>().configModel!.cancellationPolicyStatus ==
        1) {
      _menuList.add(MenuModel(
          icon: Images.cancellation,
          title: 'cancellation_policy'.tr,
          route: RouteHelper.getHtmlRoute('cancellation-policy')));
    }
    if (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1) {
      _menuList.add(MenuModel(
          icon: Images.shippingPolicy,
          title: 'shipping_policy'.tr,
          route: RouteHelper.getHtmlRoute('shipping-policy')));
    }
    if (Get.find<SplashController>().configModel!.refEarningStatus == 1) {
      _menuList.add(MenuModel(
          icon: Images.referCode,
          title: 'refer_and_earn'.tr,
          route: RouteHelper.getReferAndEarnRoute()));
    }
    if (Get.find<SplashController>().configModel!.customerWalletStatus == 1) {
      _menuList.add(MenuModel(
          icon: Images.wallet,
          title: 'wallet'.tr,
          route: RouteHelper.getWalletRoute(true)));
    }
    if (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1) {
      _menuList.add(MenuModel(
          icon: Images.loyal,
          title: 'loyalty_points'.tr,
          route: RouteHelper.getWalletRoute(false)));
    }

    _menuList.add(MenuModel(
        icon: Images.logOut,
        title: isLoggedIn ? 'logout'.tr : 'sign_in'.tr,
        route: ''));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GetBuilder<UserController>(
                builder: (userController) => Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipOval(
                              child: CustomImage(
                            image:
                                '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
                                '/${(userController.userInfoModel != null && _isLoggedIn) ? userController.userInfoModel!.image : ''}',
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          )),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            children: [
                              Text(
                                _isLoggedIn
                                    ? '${userController.userInfoModel!.fName} ${userController.userInfoModel!.lName}'
                                    : 'guest'.tr,
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge),
                              ),
                              Text(
                                _isLoggedIn
                                    ? '${userController.userInfoModel!.phone}'
                                    : 'phone'.tr,
                                style: robotoMedium.copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: Dimensions.fontSizeDefault),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: Dimensions.webMaxWidth,
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _menuList.length,
                  itemBuilder: (context, index) {
                    return MenuButton(
                        menu: _menuList[index],
                        isProfile: index == 0,
                        isLogout: index == _menuList.length - 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
