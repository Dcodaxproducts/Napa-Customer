import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/rating_bar.dart';

class ItemTitleView extends StatelessWidget {
  final Item? item;
  final bool inStorePage;
  final bool isCampaign;
  final bool inStock;
  const ItemTitleView(
      {Key? key,
      required this.item,
      this.inStorePage = false,
      this.isCampaign = false,
      required this.inStock})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(inStock ? 'out_of_stock'.tr : 'in_stock'.tr);
    }

    double? startingPrice;
    double? endingPrice;
    if (item!.variations!.isNotEmpty) {
      List<double?> priceList = [];
      for (var variation in item!.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
      if (priceList[0]! < priceList[priceList.length - 1]!) {
        endingPrice = priceList[priceList.length - 1];
      }
    } else {
      startingPrice = item!.price;
    }

    return ResponsiveHelper.isDesktop(context)
        ? GetBuilder<ItemController>(builder: (itemController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item!.name ?? '',
                  style: robotoMedium.copyWith(fontSize: 30),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                InkWell(
                  onTap: () {
                    if (inStorePage) {
                      Get.back();
                    } else {
                      Get.offNamed(
                          RouteHelper.getStoreRoute(item!.storeId, 'item'));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                    child: Text(
                      item!.storeName!,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                RatingBar(
                    rating: item!.avgRating,
                    ratingCount: item!.ratingCount,
                    size: 21),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(children: [
                  Text(
                    '${PriceConverter.convertPrice(startingPrice, discount: item!.discount, discountType: item!.discountType)}'
                    '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: item!.discount, discountType: item!.discountType)}' : ''}',
                    style: robotoBold.copyWith(
                        color: Theme.of(context).primaryColor, fontSize: 30),
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(width: 10),
                  item!.discount! > 0
                      ? Flexible(
                          child: Text(
                            '${PriceConverter.convertPrice(startingPrice)}'
                            '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                            textDirection: TextDirection.ltr,
                            style: robotoRegular.copyWith(
                                color: Colors.red,
                                decoration: TextDecoration.lineThrough,
                                fontSize: Dimensions.fontSizeLarge),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(width: Dimensions.paddingSizeLarge),
                  Column(
                    children: [
                      ((Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .unit! &&
                                  item!.unitType != null) ||
                              (Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .vegNonVeg! &&
                                  Get.find<SplashController>()
                                      .configModel!
                                      .toggleVegNonVeg!))
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeExtraSmall,
                                  horizontal: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Text(
                                Get.find<SplashController>()
                                        .configModel!
                                        .moduleConfig!
                                        .module!
                                        .unit!
                                    ? item!.unitType ?? ''
                                    : item!.veg == 0
                                        ? 'non_veg'.tr
                                        : 'veg'.tr,
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Colors.white),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          color: inStock ? Colors.red : Colors.green,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Text(inStock ? 'out_of_stock'.tr : 'in_stock'.tr,
                            style: robotoRegular.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeSmall,
                            )),
                      ),
                    ],
                  ),
                ]),
              ],
            );
          })
        : Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: GetBuilder<ItemController>(
              builder: (itemController) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  const SizedBox(height: 5),
                                  item!.discount! > 0
                                      ? Text(
                                          '${PriceConverter.convertPrice(startingPrice)}'
                                          '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                                          textDirection: TextDirection.ltr,
                                          style: robotoRegular.copyWith(
                                              color:
                                                  Theme.of(context).hintColor,
                                              decoration:
                                                  TextDecoration.lineThrough),
                                        )
                                      : const SizedBox(),
                                  SizedBox(height: item!.discount! > 0 ? 5 : 0),
                                  !isCampaign
                                      ? Row(children: [
                                          Text(
                                              item!.avgRating!
                                                  .toStringAsFixed(1),
                                              style: robotoRegular.copyWith(
                                                color:
                                                    Theme.of(context).hintColor,
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                              )),
                                          const SizedBox(width: 5),
                                          RatingBar(
                                              rating: item!.avgRating,
                                              ratingCount: item!.ratingCount),
                                        ])
                                      : const SizedBox(),
                                ])),
                            Column(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeExtraSmall),
                                decoration: BoxDecoration(
                                  color: inStock ? Colors.red : Colors.green,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                ),
                                child: Text(
                                    inStock ? 'out_of_stock'.tr : 'in_stock'.tr,
                                    style: robotoRegular.copyWith(
                                      color: Colors.white,
                                      fontSize: Dimensions.fontSizeSmall,
                                    )),
                              ),
                            ]),
                          ]),
                    ]);
              },
            ),
          );
  }
}
