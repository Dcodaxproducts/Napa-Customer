import 'package:flutter/foundation.dart';
import 'package:sixam_mart/controller/category_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/cart_widget.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/loading.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:sixam_mart/view/base/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'category_product_screen.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryItemScreen(
      {Key? key, required this.categoryID, required this.categoryName})
      : super(key: key);

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen>
    with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<CategoryController>().getSubCategoryList(widget.categoryID);
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          Get.find<CategoryController>().categoryItemList != null &&
          !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryItemList(
            Get.find<CategoryController>().subCategoryIndex == 0
                ? widget.categoryID
                : Get.find<CategoryController>()
                    .subCategoryList![
                        Get.find<CategoryController>().subCategoryIndex]
                    .id
                    .toString(),
            Get.find<CategoryController>().offset + 1,
            Get.find<CategoryController>().type,
            false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Item>? item;
      // List<Store>? stores;
      if (catController.isSearching
          ? catController.searchItemList != null
          : catController.categoryItemList != null) {
        item = [];
        if (catController.isSearching) {
          item.addAll(catController.searchItemList!);
        } else {
          item.addAll(catController.categoryItemList!);
        }
      }
      // if (catController.isSearching
      //     ? catController.searchStoreList != null
      //     : catController.categoryStoreList != null) {
      //   stores = [];
      //   if (catController.isSearching) {
      //     stores.addAll(catController.searchStoreList!);
      //   } else {
      //     stores.addAll(catController.categoryStoreList!);
      //   }
      // }

      return WillPopScope(
        onWillPop: () async {
          if (catController.isSearching) {
            catController.toggleSearch();
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          appBar: (ResponsiveHelper.isDesktop(context)
              ? const WebMenuBar()
              : AppBar(
                  title: catController.isSearching
                      ? TextField(
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: 'Search...',
                            border: InputBorder.none,
                          ),
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge),
                          onSubmitted: (String query) {
                            catController.searchData(
                              query,
                              catController.subCategoryIndex == 0
                                  ? widget.categoryID
                                  : catController
                                      .subCategoryList![
                                          catController.subCategoryIndex]
                                      .id
                                      .toString(),
                              catController.type,
                            );
                          })
                      : Text(widget.categoryName,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          )),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () {
                      if (catController.isSearching) {
                        catController.toggleSearch();
                      } else {
                        Get.back();
                      }
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
          body: catController.subCategoryList == null
              ? const CustomLoading()
              : catController.subCategoryList!.isNotEmpty
                  ? ListView.separated(
                      itemCount: catController.subCategoryList!.length,
                      padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeSmall),
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                            height: Dimensions.paddingSizeSmall);
                      },
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            catController.setSubCategoryIndex(
                                index, widget.categoryID);
                            Get.to(() => CategoryProductScreen(
                                  categoryID: widget.categoryID,
                                  categoryName: catController
                                      .subCategoryList![index].name!,
                                ));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusExtraLarge),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors
                                        .grey[Get.isDarkMode ? 800 : 200]!,
                                    blurRadius: 5,
                                    spreadRadius: 1)
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        catController
                                            .subCategoryList![index].name!,
                                        textAlign: TextAlign.center,
                                        style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        widget.categoryName,
                                        textAlign: TextAlign.center,
                                        style: robotoMedium.copyWith(
                                            color: Colors.grey, fontSize: 10),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusExtraLarge),
                                    child: CustomImage(
                                      height: 90,
                                      width: 125,
                                      fit: BoxFit.cover,
                                      image:
                                          '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${catController.subCategoryList![index].image}',
                                    ),
                                  ),
                                ]),
                          ),
                        );
                      },
                    )
                  : NoDataScreen(text: 'no_category_found'.tr),
        ),
      );
    });
  }
}
