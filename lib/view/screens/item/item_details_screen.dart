import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/dashboard_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/cart_snackbar.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/screens/checkout/checkout_screen.dart';
import 'package:sixam_mart/view/screens/item/widget/details_web_view.dart';
import '../../../controller/auth_controller.dart';
import '../../base/custom_image.dart';
import '../../base/rating_bar.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Item? item;
  final bool inStorePage;
  const ItemDetailsScreen({Key? key, this.item, this.inStorePage = false})
      : super(key: key);

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<ItemController>().getProductDetails(widget.item!);
    });
  }

  _navigate() {
    if (DashboardController.to.pageIndex == 5) {
      DashboardController.to.setPage(0);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      return GetBuilder<ItemController>(
        builder: (itemController) {
          String? baseUrl = itemController.item!.availableDateStarts == null
              ? splashController.configModel!.baseUrls!.itemImageUrl
              : splashController.configModel!.baseUrls!.campaignImageUrl;
          int? stock = 0;
          CartModel? cartModel;
          double priceWithAddons = 0;
          if (itemController.item != null) {
            double? price = itemController.item!.price;
            stock = itemController.item!.stock ?? 0;

            double? discount =
                (itemController.item!.availableDateStarts != null ||
                        itemController.item!.storeDiscount == 0)
                    ? itemController.item!.discount
                    : itemController.item!.storeDiscount;
            String? discountType =
                (itemController.item!.availableDateStarts != null ||
                        itemController.item!.storeDiscount == 0)
                    ? itemController.item!.discountType
                    : 'percent';
            double priceWithDiscount = PriceConverter.convertWithDiscount(
                price, discount, discountType)!;
            double priceWithQuantity =
                priceWithDiscount * itemController.quantity!;

            cartModel = CartModel(
              price,
              priceWithDiscount,
              [],
              [],
              (price! -
                  PriceConverter.convertWithDiscount(
                      price, discount, discountType)!),
              itemController.quantity,
              [],
              [],
              itemController.item!.availableDateStarts != null,
              stock,
              itemController.item,
            );
            priceWithAddons = priceWithQuantity;
          }
          List<String?> imageList = [];
          imageList.add(itemController.item!.image);
          imageList.addAll(itemController.item!.images!);
          final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

          return Scaffold(
            backgroundColor: Theme.of(context).cardColor,
            body: (itemController.item != null)
                ? ResponsiveHelper.isDesktop(context)
                    ? DetailsWebView(
                        cartModel: cartModel,
                        stock: stock,
                        priceWithAddOns: priceWithAddons,
                      )
                    : Column(children: [
                        Expanded(
                            child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  const SizedBox(
                                    height: 400,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(right: 15),
                                    width: double.infinity,
                                    height: 370,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(90))),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              30, 40, 15, 30),
                                          child: Row(
                                            children: [
                                              // back  button
                                              IconButton(
                                                  icon: const Icon(
                                                      Icons.arrow_back_ios,
                                                      color: Colors.white),
                                                  onPressed: _navigate),
                                              const Spacer(),
                                              Text(
                                                'item_details'.tr,
                                                style: robotoMedium.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const Spacer(),
                                              GetBuilder<WishListController>(
                                                  builder: (wishController) {
                                                return IconButton(
                                                  onPressed: () {
                                                    if (isLoggedIn) {
                                                      if (wishController
                                                          .wishItemIdList
                                                          .contains(
                                                              itemController
                                                                  .item!.id)) {
                                                        wishController
                                                            .removeFromWishList(
                                                                itemController
                                                                    .item!.id,
                                                                false);
                                                      } else {
                                                        wishController
                                                            .addToWishList(
                                                                itemController
                                                                    .item,
                                                                null,
                                                                false);
                                                      }
                                                    } else {
                                                      showCustomSnackBar(
                                                          'you_are_not_logged_in'
                                                              .tr);
                                                    }
                                                  },
                                                  icon: Icon(
                                                    Icons.favorite,
                                                    size: 22,
                                                    color: wishController
                                                            .wishItemIdList
                                                            .contains(
                                                                itemController
                                                                    .item!.id)
                                                        ? Colors.red
                                                        : Colors.white,
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .45,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    itemController.item!.name ??
                                                        '',
                                                    style:
                                                        robotoMedium.copyWith(
                                                            color: Colors.white,
                                                            fontSize: 25),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),
                                                  Text(
                                                    itemController.item!
                                                                .vintage ==
                                                            null
                                                        ? ''
                                                        : 'Vintage',
                                                    style: robotoMedium.copyWith(
                                                        color: Colors.white,
                                                        fontSize: Dimensions
                                                            .fontSizeDefault,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    itemController
                                                            .item!.vintage ??
                                                        '',
                                                    style:
                                                        robotoMedium.copyWith(
                                                            color: Colors.white,
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),
                                                  Text(
                                                    itemController.item!
                                                                .alcohol ==
                                                            null
                                                        ? ''
                                                        : 'Alcohol',
                                                    style: robotoMedium.copyWith(
                                                        color: Colors.white,
                                                        fontSize: Dimensions
                                                            .fontSizeDefault,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    itemController.item!
                                                                .alcohol ==
                                                            null
                                                        ? ''
                                                        : '${itemController.item!.alcohol} %',
                                                    style:
                                                        robotoMedium.copyWith(
                                                            color: Colors.white,
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),
                                                  Text(
                                                    itemController.item!
                                                                .country ==
                                                            null
                                                        ? ''
                                                        : 'Region',
                                                    style: robotoMedium.copyWith(
                                                        color: Colors.white,
                                                        fontSize: Dimensions
                                                            .fontSizeDefault,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    itemController
                                                            .item!.country ??
                                                        '',
                                                    maxLines: 2,
                                                    style:
                                                        robotoMedium.copyWith(
                                                            color: Colors.white,
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),
                                                  GetBuilder<CartController>(
                                                      builder:
                                                          (cartController) {
                                                    return Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10,
                                                          horizontal: 15),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          color: Colors.white),
                                                      child: Text(
                                                          PriceConverter.convertPrice(itemController
                                                                      .cartIndex !=
                                                                  -1
                                                              ? (cartController
                                                                      .cartList[
                                                                          itemController
                                                                              .cartIndex]
                                                                      .discountedPrice! *
                                                                  cartController
                                                                      .cartList[
                                                                          itemController
                                                                              .cartIndex]
                                                                      .quantity!)
                                                              : priceWithAddons),
                                                          textDirection:
                                                              TextDirection.ltr,
                                                          style: robotoBold
                                                              .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontSize: Dimensions
                                                                .fontSizeLarge,
                                                          )),
                                                    );
                                                  })
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (imageList.isNotEmpty)
                                    Positioned(
                                      left: 40,
                                      bottom: 0,
                                      child: SizedBox(
                                        height: 250,
                                        width: 140,
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: CustomImage(
                                            fit: BoxFit.cover,
                                            image: '$baseUrl/${imageList[0]}',
                                            height: 250,
                                            width: 140,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    RatingBar(
                                        size: 20,
                                        rating: itemController.item!.avgRating,
                                        ratingCount:
                                            itemController.item!.ratingCount),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Row(children: [
                                        const SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            if (itemController.cartIndex !=
                                                -1) {
                                              if (Get.find<CartController>()
                                                      .cartList[itemController
                                                          .cartIndex]
                                                      .quantity! >
                                                  1) {
                                                Get.find<CartController>()
                                                    .setQuantity(
                                                        false,
                                                        itemController
                                                            .cartIndex,
                                                        stock);
                                              }
                                            } else {
                                              if (itemController.quantity! >
                                                  1) {
                                                itemController.setQuantity(
                                                    false, stock);
                                              }
                                            }
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: Dimensions
                                                    .paddingSizeExtraSmall),
                                            child: Icon(
                                              Icons.remove,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        GetBuilder<CartController>(
                                            builder: (cartController) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 10),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Text(
                                              itemController.cartIndex != -1
                                                  ? cartController
                                                      .cartList[itemController
                                                          .cartIndex]
                                                      .quantity
                                                      .toString()
                                                  : itemController.quantity
                                                      .toString(),
                                              style: robotoMedium.copyWith(
                                                  color: Colors.white,
                                                  fontSize: Dimensions
                                                      .fontSizeDefault),
                                            ),
                                          );
                                        }),
                                        InkWell(
                                          onTap: () =>
                                              itemController.cartIndex != -1
                                                  ? Get.find<CartController>()
                                                      .setQuantity(
                                                          true,
                                                          itemController
                                                              .cartIndex,
                                                          stock)
                                                  : itemController.setQuantity(
                                                      true, stock),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: Dimensions
                                                    .paddingSizeExtraSmall),
                                            child: Icon(
                                              Icons.add,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall,
                                        )
                                      ]),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeExtraSmall,
                                          vertical:
                                              Dimensions.paddingSizeExtraSmall -
                                                  2),
                                      decoration: BoxDecoration(
                                        color: (splashController
                                                    .configModel!
                                                    .moduleConfig!
                                                    .module!
                                                    .stock! &&
                                                stock <= 0)
                                            ? Colors.red
                                            : Colors.green,
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusLarge),
                                      ),
                                      child: Text(
                                          (splashController
                                                      .configModel!
                                                      .moduleConfig!
                                                      .module!
                                                      .stock! &&
                                                  stock <= 0)
                                              ? 'out_of_stock'.tr
                                              : 'in_stock'.tr,
                                          style: robotoRegular.copyWith(
                                            color: Colors.white,
                                            fontSize: 8,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${itemController.item!.name}',
                                        style: robotoMedium.copyWith(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall),
                                    Text(itemController.item!.description ?? '',
                                        style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeSmall)),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeLarge),
                                    Container(
                                      height: 5,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                    ),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeLarge),
                                    Text('You May Need',
                                        style: robotoMedium.copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey)),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeLarge),
                                    // related items
                                    if (itemController.item!.relatedItems !=
                                        null)
                                      SizedBox(
                                        height: 170,
                                        child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: itemController
                                                .item!.relatedItems!.length,
                                            separatorBuilder: (context, index) {
                                              return const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall);
                                            },
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                onTap: () async {
                                                  Get.toNamed(
                                                          RouteHelper
                                                              .getItemDetailsRoute(
                                                                  itemController
                                                                      .item!
                                                                      .relatedItems![
                                                                          index]
                                                                      .id,
                                                                  false),
                                                          arguments:
                                                              ItemDetailsScreen(
                                                            item: itemController
                                                                    .item!
                                                                    .relatedItems![
                                                                index],
                                                            inStorePage: false,
                                                          ))!
                                                      .then((value) => Get.find<
                                                              ItemController>()
                                                          .getProductDetails(
                                                              widget.item!,
                                                              load: true));
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                      Dimensions
                                                          .paddingSizeSmall),
                                                  width: 120,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Theme.of(context)
                                                                .primaryColor, // Replace with your desired background color
                                                            Colors.white,
                                                          ],
                                                          stops: const [
                                                            0.5,
                                                            1,
                                                          ]),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25)),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                          child: CustomImage(
                                                            image:
                                                                '$baseUrl/${itemController.item!.relatedItems![index].image}',
                                                            height: 100,
                                                            width: 100,
                                                            fit: BoxFit
                                                                .fitHeight,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Text(
                                                          itemController
                                                                  .item!
                                                                  .relatedItems![
                                                                      index]
                                                                  .name ??
                                                              '',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: robotoMedium
                                                              .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeDefault,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black)),
                                                      const SizedBox(height: 5),
                                                      // price
                                                      Text(
                                                          PriceConverter
                                                              .convertPrice(
                                                                  itemController
                                                                      .item!
                                                                      .relatedItems![
                                                                          index]
                                                                      .price),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: robotoMedium
                                                              .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeSmall,
                                                                  color: Colors
                                                                      .black)),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                        Builder(builder: (context) {
                          return Container(
                            width: 1170,
                            padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall)
                                .copyWith(bottom: Dimensions.paddingSizeLarge),
                            child: CustomButton(
                              radius: 50,
                              buttonText: (splashController.configModel!
                                          .moduleConfig!.module!.stock! &&
                                      stock! <= 0)
                                  ? 'out_of_stock'.tr
                                  : itemController.item!.availableDateStarts !=
                                          null
                                      ? 'order_now'.tr
                                      : itemController.cartIndex != -1
                                          ? 'update_in_cart'.tr
                                          : 'add_to_cart'.tr,
                              onPressed: (!splashController.configModel!
                                          .moduleConfig!.module!.stock! ||
                                      stock! > 0)
                                  ? () {
                                      if (!splashController.configModel!
                                              .moduleConfig!.module!.stock! ||
                                          stock! > 0) {
                                        if (itemController
                                                .item!.availableDateStarts !=
                                            null) {
                                          Get.toNamed(
                                              RouteHelper.getCheckoutRoute(
                                                  'campaign'),
                                              arguments: CheckoutScreen(
                                                storeId: null,
                                                fromCart: false,
                                                cartList: [cartModel],
                                              ));
                                        } else {
                                          if (Get.find<CartController>()
                                              .existAnotherStoreItem(
                                                  cartModel!.item!.storeId,
                                                  splashController
                                                      .module!.id)) {
                                            Get.dialog(
                                                ConfirmationDialog(
                                                  icon: Images.warning,
                                                  title: 'are_you_sure_to_reset'
                                                      .tr,
                                                  description: Get.find<
                                                              SplashController>()
                                                          .configModel!
                                                          .moduleConfig!
                                                          .module!
                                                          .showRestaurantText!
                                                      ? 'if_you_continue'.tr
                                                      : 'if_you_continue_without_another_store'
                                                          .tr,
                                                  onYesPressed: () {
                                                    Get.back();
                                                    Get.find<CartController>()
                                                        .removeAllAndAddToCart(
                                                            cartModel!);
                                                    showCartSnackBar(context);
                                                  },
                                                ),
                                                barrierDismissible: false);
                                          } else {
                                            if (itemController.cartIndex ==
                                                -1) {
                                              Get.find<CartController>()
                                                  .addToCart(cartModel,
                                                      itemController.cartIndex);
                                            }
                                            showCartSnackBar(context);
                                            _navigate();
                                          }
                                        }
                                      }
                                    }
                                  : null,
                            ),
                          );
                        }),
                      ])
                : const Center(child: CircularProgressIndicator()),
          );
        },
      );
    });
  }
}

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int? quantity;
  final bool isCartWidget;
  final int? stock;
  final bool isExistInCart;
  final int cartIndex;
  const QuantityButton({
    Key? key,
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.isExistInCart,
    required this.cartIndex,
    this.isCartWidget = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isExistInCart) {
          if (!isIncrement && quantity! > 1) {
            Get.find<CartController>().setQuantity(false, cartIndex, stock);
          } else if (isIncrement && quantity! > 0) {
            if (quantity! < stock! ||
                !Get.find<SplashController>()
                    .configModel!
                    .moduleConfig!
                    .module!
                    .stock!) {
              Get.find<CartController>().setQuantity(true, cartIndex, stock);
            } else {
              showCustomSnackBar('out_of_stock'.tr);
            }
          }
        } else {
          if (!isIncrement && quantity! > 1) {
            Get.find<ItemController>().setQuantity(false, stock);
          } else if (isIncrement && quantity! > 0) {
            if (quantity! < stock! ||
                !Get.find<SplashController>()
                    .configModel!
                    .moduleConfig!
                    .module!
                    .stock!) {
              Get.find<ItemController>().setQuantity(true, stock);
            } else {
              showCustomSnackBar('out_of_stock'.tr);
            }
          }
        }
      },
      child: Container(
        // padding: EdgeInsets.all(3),
        height: 50, width: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).primaryColor),
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: isIncrement
                ? Colors.white
                : quantity! > 1
                    ? Colors.white
                    : Colors.white,
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ),
    );
  }
}
