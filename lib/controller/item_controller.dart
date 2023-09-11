import 'package:flutter/foundation.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/api/api_checker.dart';
import 'package:sixam_mart/data/model/body/review_body.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/order_details_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/response_model.dart';
import 'package:sixam_mart/data/repository/item_repo.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/screens/item/item_details_screen.dart';

class ItemController extends GetxController implements GetxService {
  final ItemRepo itemRepo;
  ItemController({required this.itemRepo});

  // Latest products
  List<Item>? _popularItemList;
  List<Item>? _reviewedItemList;
  bool _isLoading = false;
  int? _quantity = 1;
  String _popularType = 'all';
  String _reviewedType = 'all';
  static final List<String> _itemTypeList = ['all', 'veg', 'non_veg'];
  int _imageIndex = 0;
  int _cartIndex = -1;
  Item? _item;
  Item? _selectedItem;
  int _productSelect = 0;
  int _imageSliderIndex = 0;

  List<Item>? get popularItemList => _popularItemList;
  List<Item>? get reviewedItemList => _reviewedItemList;
  bool get isLoading => _isLoading;
  int? get quantity => _quantity;
  String get popularType => _popularType;
  String get reviewType => _reviewedType;
  List<String> get itemTypeList => _itemTypeList;
  int get imageIndex => _imageIndex;
  int get cartIndex => _cartIndex;
  Item? get item => _item;
  Item? get selectedItem => _selectedItem;
  int get productSelect => _productSelect;
  int get imageSliderIndex => _imageSliderIndex;

  set selectedItem(Item? value) {
    _selectedItem = value;
    update();
  }

  Future<void> getPopularItemList(bool reload, String type, bool notify) async {
    _popularType = type;
    if (reload) {
      _popularItemList = null;
    }
    if (notify) {
      update();
    }
    if (_popularItemList == null || reload) {
      Response response = await itemRepo.getPopularItemList(type);
      if (response.statusCode == 200) {
        _popularItemList = [];
        _popularItemList!.addAll(ItemModel.fromJson(response.body).items!);
        _isLoading = false;
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getReviewedItemList(
      bool reload, String type, bool notify) async {
    _reviewedType = type;
    if (reload) {
      _reviewedItemList = null;
    }
    if (notify) {
      update();
    }
    if (_reviewedItemList == null || reload) {
      Response response = await itemRepo.getReviewedItemList(type);
      if (response.statusCode == 200) {
        _reviewedItemList = [];
        _reviewedItemList!.addAll(ItemModel.fromJson(response.body).items!);
        _isLoading = false;
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void initData(Item? item, CartModel? cart) {
    if (cart != null) {
      _quantity = cart.quantity;
    } else {
      _quantity = 1;
      setExistInCart(item, notify: false);
    }
  }

  int setExistInCart(Item? item, {bool notify = false}) {
    if (Get.find<SplashController>()
        .getModuleConfig(Get.find<SplashController>().module!.moduleType)
        .newVariation!) {
      _cartIndex = -1;
    } else {
      _cartIndex = Get.find<CartController>().isExistInCart(item!.id) ? 0 : -1;
    }
    if (_cartIndex != -1) {
      _quantity = Get.find<CartController>().cartList[_cartIndex].quantity;
    }
    if (notify) {
      update();
    }
    return _cartIndex;
  }

  void setQuantity(bool isIncrement, int? stock) {
    if (isIncrement) {
      if (Get.find<SplashController>()
              .configModel!
              .moduleConfig!
              .module!
              .stock! &&
          _quantity! >= stock!) {
        showCustomSnackBar('only_for_stock'.tr);
      } else {
        _quantity = _quantity! + 1;
      }
    } else {
      _quantity = _quantity! - 1;
    }
    update();
  }

  void setCartVariationIndex(int index, int i, Item? item) {
    _quantity = 1;
    setExistInCart(item);
    update();
  }

  List<int> _ratingList = [];
  List<String> _reviewList = [];
  List<bool> _loadingList = [];
  List<bool> _submitList = [];
  int _deliveryManRating = 0;

  List<int> get ratingList => _ratingList;
  List<String> get reviewList => _reviewList;
  List<bool> get loadingList => _loadingList;
  List<bool> get submitList => _submitList;
  int get deliveryManRating => _deliveryManRating;

  void initRatingData(List<OrderDetailsModel> orderDetailsList) {
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _deliveryManRating = 0;
    for (var orderDetails in orderDetailsList) {
      _ratingList.add(0);
      _reviewList.add('');
      _loadingList.add(false);
      _submitList.add(false);
      if (kDebugMode) {
        print(orderDetails);
      }
    }
  }

  void setRating(int index, int rate) {
    _ratingList[index] = rate;
    update();
  }

  void setReview(int index, String review) {
    _reviewList[index] = review;
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    update();
  }

  Future<ResponseModel> submitReview(int index, ReviewBody reviewBody) async {
    _loadingList[index] = true;
    update();

    Response response = await itemRepo.submitReview(reviewBody);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      _submitList[index] = true;
      responseModel = ResponseModel(true, 'Review submitted successfully');
      update();
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _loadingList[index] = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> submitDeliveryManReview(ReviewBody reviewBody) async {
    _isLoading = true;
    update();
    Response response = await itemRepo.submitDeliveryManReview(reviewBody);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      _deliveryManRating = 0;
      responseModel = ResponseModel(true, 'Review submitted successfully');
      update();
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  void setImageIndex(int index, bool notify) {
    _imageIndex = index;
    if (notify) {
      update();
    }
  }

  Future<void> getProductDetails(Item item, {bool load = false}) async {
    _item = item;
    update();
    Response response = await itemRepo.getItemDetails(item.id);
    if (response.statusCode == 200) {
      _item = Item.fromJson(response.body);
      _isLoading = false;
    } else {
      ApiChecker.checkApi(response);
    }

    initData(_item, null);
    setExistInCart(item, notify: true);
  }

  void setSelect(int select, bool notify) {
    _productSelect = select;
    if (notify) {
      update();
    }
  }

  void setImageSliderIndex(int index) {
    _imageSliderIndex = index;
    update();
  }

  double? getStartingPrice(Item item) {
    double? startingPrice = 0;
    if (item.choiceOptions!.isNotEmpty) {
      List<double?> priceList = [];
      for (var variation in item.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
    } else {
      startingPrice = item.price;
    }
    return startingPrice;
  }

  bool isAvailable(Item item) {
    return DateConverter.isAvailable(
        item.availableTimeStarts, item.availableTimeEnds);
  }

  double? getDiscount(Item item) =>
      item.storeDiscount == 0 ? item.discount : item.storeDiscount;

  String? getDiscountType(Item item) =>
      item.storeDiscount == 0 ? item.discountType : 'percent';

  void navigateToItemPage(Item? item) {
    Get.toNamed(RouteHelper.getItemDetailsRoute(item?.id, false),
        arguments: ItemDetailsScreen(item: item, inStorePage: false));
  }
}
