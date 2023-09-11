// ignore_for_file: use_build_context_synchronously

import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/dashboard_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../util/styles.dart';
import '../screens/home/theme1/popular_item_view1.dart';
import 'custom_button.dart';
import 'custom_image.dart';

class ItemsView extends StatefulWidget {
  final List<Item?>? items;
  final List<Store?>? stores;
  final bool isStore;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  final bool isCampaign;
  final bool inStorePage;
  final String? type;
  final bool isFeatured;
  final bool showTheme1Store;
  final Function(String type)? onVegFilterTap;
  final bool fromHome;
  const ItemsView(
      {Key? key,
      required this.stores,
      required this.items,
      required this.isStore,
      this.isScrollable = false,
      this.shimmerLength = 20,
      this.padding = const EdgeInsets.all(Dimensions.paddingSizeSmall),
      this.noDataText,
      this.isCampaign = false,
      this.inStorePage = false,
      this.type,
      this.onVegFilterTap,
      this.isFeatured = false,
      this.fromHome = false,
      this.showTheme1Store = false})
      : super(key: key);

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;

    isNull = widget.items == null;
    if (!isNull) {
      length = widget.items!.length;
    }

    return Column(children: [
      !isNull
          ? length > 0
              ? GridView.builder(
                  key: UniqueKey(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: ResponsiveHelper.isDesktop(context)
                        ? 4
                        : widget.showTheme1Store
                            ? 1.9
                            : 0.65,
                    crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 2,
                  ),
                  physics: widget.isScrollable
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  shrinkWrap: widget.isScrollable ? false : true,
                  itemCount: length,
                  padding: widget.padding,
                  itemBuilder: (context, index) {
                    var item = widget.items![index];
                    return GetBuilder<ItemController>(
                        builder: (itemController) {
                      return GetBuilder<CartController>(
                          builder: (cartController) {
                        return InkWell(
                          onTap: () {
                            if (widget.fromHome) {
                              DashboardController.to
                                  .setPage(5, item: widget.items![index]!);
                            } else {
                              Get.find<ItemController>()
                                  .navigateToItemPage(widget.items![index]);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeExtraSmall),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: CustomImage(
                                      image:
                                          '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                                          '/${widget.items![index]!.image}',
                                    ),
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    widget.items![index]!.name!,
                                    style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall),
                                  // price
                                  Text(
                                    PriceConverter.convertPrice(
                                        widget.items![index]!.price!),
                                    style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context).disabledColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  CustomButton(
                                    color: Theme.of(context).primaryColor,
                                    height: 30,
                                    buttonText: widget.items![index]!.stock! < 1
                                        ? 'out_of_stock'.tr
                                        : cartController.isExistInCart(item!.id)
                                            ? 'remove_from_cart'.tr
                                            : 'add_to_cart'.tr,
                                    fontSize: 9,
                                    radius: 20,
                                    onPressed: widget.items![index]!.stock! < 1
                                        ? null
                                        : () async {
                                            await itemController
                                                .getProductDetails(item!);

                                            int? stock = 0;
                                            CartModel? cartModel;
                                            if (itemController.item != null) {
                                              double? price =
                                                  itemController.item!.price;
                                              stock =
                                                  itemController.item!.stock ??
                                                      0;

                                              double? discount = (itemController
                                                              .item!
                                                              .availableDateStarts !=
                                                          null ||
                                                      itemController.item!
                                                              .storeDiscount ==
                                                          0)
                                                  ? itemController
                                                      .item!.discount
                                                  : itemController
                                                      .item!.storeDiscount;
                                              String? discountType = (itemController
                                                              .item!
                                                              .availableDateStarts !=
                                                          null ||
                                                      itemController.item!
                                                              .storeDiscount ==
                                                          0)
                                                  ? itemController
                                                      .item!.discountType
                                                  : 'percent';
                                              double priceWithDiscount =
                                                  PriceConverter
                                                      .convertWithDiscount(
                                                          price,
                                                          discount,
                                                          discountType)!;

                                              cartModel = CartModel(
                                                price,
                                                priceWithDiscount,
                                                [],
                                                [],
                                                (price! -
                                                    PriceConverter
                                                        .convertWithDiscount(
                                                            price,
                                                            discount,
                                                            discountType)!),
                                                itemController.quantity,
                                                [],
                                                [],
                                                itemController.item!
                                                        .availableDateStarts !=
                                                    null,
                                                stock,
                                                itemController.item,
                                              );
                                            }
                                            if (itemController.cartIndex ==
                                                -1) {
                                              Get.find<CartController>()
                                                  .addToCart(cartModel!,
                                                      itemController.cartIndex);
                                              // showCartSnackBar(context);
                                            } else {
                                              Get.find<CartController>()
                                                  .removeFromCart(cartController
                                                      .cartList
                                                      .indexWhere((e) =>
                                                          e.item!.id ==
                                                          item.id));
                                            }
                                          },
                                  )
                                ]),
                          ),
                        );
                      });
                    });
                  },
                )
              : NoDataScreen(
                  text: widget.noDataText ??
                      (widget.isStore
                          ? Get.find<SplashController>()
                                  .configModel!
                                  .moduleConfig!
                                  .module!
                                  .showRestaurantText!
                              ? 'no_restaurant_available'.tr
                              : 'no_store_available'.tr
                          : 'no_item_available'.tr),
                )
          : PopularItemShimmer(enabled: widget.showTheme1Store)
    ]);
  }
}
