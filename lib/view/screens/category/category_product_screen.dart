import 'package:sixam_mart/controller/search_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/cart_widget.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/search/widget/filter_widget.dart';

class CategoryProductScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryProductScreen(
      {Key? key, required this.categoryID, required this.categoryName})
      : super(key: key);

  @override
  CategoryProductScreenState createState() => CategoryProductScreenState();
}

class CategoryProductScreenState extends State<CategoryProductScreen>
    with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // scrollController.addListener(() {
    //   if (scrollController.position.pixels ==
    //           scrollController.position.maxScrollExtent &&
    //       Get.find<CategoryController>().categoryItemList != null &&
    //       !Get.find<CategoryController>().isLoading) {
    //     int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
    //     if (Get.find<CategoryController>().offset < pageSize) {
    //       if (kDebugMode) {
    //         print('end of the page');
    //       }
    //       Get.find<CategoryController>().showBottomLoader();
    //       Get.find<CategoryController>().getCategoryItemList(
    //         Get.find<CategoryController>().subCategoryIndex == 0
    //             ? widget.categoryID
    //             : Get.find<CategoryController>()
    //                 .subCategoryList![
    //                     Get.find<CategoryController>().subCategoryIndex]
    //                 .id
    //                 .toString(),
    //         Get.find<CategoryController>().offset + 1,
    //         Get.find<CategoryController>().type,
    //         false,
    //       );
    //     }
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchController>(builder: (searchController) {
      return Scaffold(
        appBar: (ResponsiveHelper.isDesktop(context)
            ? const WebMenuBar()
            : AppBar(
                title: Text(widget.categoryName,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    )),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () {
                    Get.back();
                  },
                ),
                backgroundColor: Theme.of(context).cardColor,
                elevation: 0,
                actions: [
                  IconButton(
                    onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                    icon: CartWidget(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        size: 25),
                  ),
                ],
              )) as PreferredSizeWidget?,
        body: Column(
          children: [
            Container(
              height: 70,
              width: Dimensions.webMaxWidth,
              color: Theme.of(context).colorScheme.background,
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall),
              child: InkWell(
                onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 70,
                        margin: const EdgeInsets.symmetric(vertical: 10),
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
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          Icon(
                            Icons.search,
                            size: 25,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
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
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    IconButton(
                        onPressed: () {
                          Get.dialog(const FilterWidget(
                              maxValue: 1000, isStore: true));
                        },
                        icon: Icon(Icons.filter_list,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            size: 25))
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: ItemsView(
                  isStore: false,
                  items: searchController.searchItemList,
                  stores: null,
                  noDataText: 'no_category_item_found'.tr,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
