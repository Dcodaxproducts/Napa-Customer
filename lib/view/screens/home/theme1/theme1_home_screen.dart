import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/notification_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/paginated_list_view.dart';
import 'package:sixam_mart/view/screens/home/home_screen.dart';
import 'package:sixam_mart/view/screens/home/theme1/banner_view1.dart';
import 'package:sixam_mart/view/screens/home/theme1/best_reviewed_item_view.dart';
import 'package:sixam_mart/view/screens/home/theme1/category_view1.dart';
import 'package:sixam_mart/view/screens/home/theme1/item_campaign_view1.dart';
import 'package:sixam_mart/view/screens/home/theme1/popular_item_view1.dart';
import 'package:sixam_mart/view/screens/home/widget/module_view.dart';

import '../../../base/title_widget.dart';

class Theme1HomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  final SplashController splashController;
  final bool showMobileModule;
  const Theme1HomeScreen(
      {Key? key,
      required this.scrollController,
      required this.splashController,
      required this.showMobileModule})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: ResponsiveHelper.isDesktop(context)
              ? Colors.transparent
              : Theme.of(context).colorScheme.background,
          title: Center(
              child: Container(
            width: Dimensions.webMaxWidth,
            height: 50,
            color: Theme.of(context).colorScheme.background,
            child: Row(children: [
              (splashController.module != null &&
                      splashController.configModel!.module == null)
                  ? InkWell(
                      onTap: () => splashController.removeModule(),
                      child:
                          Image.asset(Images.moduleIcon, height: 22, width: 22),
                    )
                  : const SizedBox(),
              SizedBox(
                  width: (splashController.module != null &&
                          splashController.configModel!.module == null)
                      ? Dimensions.paddingSizeExtraSmall
                      : 0),
              Expanded(
                  child: InkWell(
                onTap: () =>
                    Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                    horizontal: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeSmall
                        : 0,
                  ),
                  child: GetBuilder<LocationController>(
                      builder: (locationController) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          locationController.getUserAddress()!.addressType ==
                                  'home'
                              ? Icons.home_filled
                              : locationController
                                          .getUserAddress()!
                                          .addressType ==
                                      'office'
                                  ? Icons.work
                                  : Icons.location_on,
                          size: 20,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'deliver_to'.tr,
                          style: robotoRegular.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                              fontSize: Dimensions.fontSizeSmall,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            ": ${locationController.getUserAddress()!.address!}",
                            style: robotoRegular.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down,
                            color:
                                Theme.of(context).textTheme.bodyLarge!.color),
                      ],
                    );
                  }),
                ),
              )),
              InkWell(
                child: GetBuilder<NotificationController>(
                    builder: (notificationController) {
                  return Stack(children: [
                    Icon(Icons.notifications,
                        size: 25,
                        color: Theme.of(context).textTheme.bodyLarge!.color),
                    notificationController.hasNotification
                        ? Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 1,
                                    color: Theme.of(context).cardColor),
                              ),
                            ))
                        : const SizedBox(),
                  ]);
                }),
                onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
              ),
            ]),
          )),
          actions: const [SizedBox()],
        ),

        // Search Button
        !showMobileModule
            ? SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(
                    child: Center(
                        child: Container(
                  height: 50,
                  width: Dimensions.webMaxWidth,
                  color: Theme.of(context).colorScheme.background,
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall),
                  child: InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                              spreadRadius: 1,
                              blurRadius: 5)
                        ],
                      ),
                      child: Row(children: [
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Icon(
                          Icons.search,
                          size: 25,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Expanded(
                            child: Text(
                          Get.find<SplashController>()
                                  .configModel!
                                  .moduleConfig!
                                  .module!
                                  .showRestaurantText!
                              ? 'search_food_or_restaurant'.tr
                              : 'search_item_or_store'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        )),
                      ]),
                    ),
                  ),
                ))),
              )
            : const SliverToBoxAdapter(),

        SliverToBoxAdapter(
          child: Center(
              child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: !showMobileModule
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const BannerView1(isFeatured: false),
                        const CategoryView1(),
                        const ItemCampaignView1(),
                        const BestReviewedItemView(),
                        const PopularItemView1(isPopular: true),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 0, 5),
                          child: TitleWidget(
                            title: 'all_products'.tr,
                          ),
                        ),
                        GetBuilder<StoreController>(builder: (storeController) {
                          return storeController.storeItemModel == null
                              ? const SizedBox()
                              : PaginatedListView(
                                  scrollController: scrollController,
                                  onPaginate: (int? offset) =>
                                      storeController.getStoreItemList(1,
                                          offset!, storeController.type, false),
                                  totalSize:
                                      storeController.storeItemModel != null
                                          ? storeController
                                              .storeItemModel!.totalSize
                                          : null,
                                  offset: storeController.storeItemModel != null
                                      ? storeController.storeItemModel!.offset
                                      : null,
                                  itemView: ItemsView(
                                    fromHome: true,
                                    isStore: false,
                                    stores: null,
                                    items: (storeController.storeItemModel !=
                                            null)
                                        ? storeController.storeItemModel!.items
                                        : null,
                                    inStorePage: true,
                                    type: storeController.type,
                                    onVegFilterTap: (String type) {
                                      storeController.getStoreItemList(
                                          1, 1, type, true);
                                    },
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                      vertical:
                                          ResponsiveHelper.isDesktop(context)
                                              ? Dimensions.paddingSizeSmall
                                              : 0,
                                    ),
                                  ),
                                );
                        }),
                      ])
                : ModuleView(splashController: splashController),
          )),
        ),
      ],
    );
  }
}
