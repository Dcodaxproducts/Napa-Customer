import 'package:sixam_mart/controller/search_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/screens/search/widget/filter_widget.dart';
import 'package:sixam_mart/view/screens/search/widget/item_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchResultWidget extends StatefulWidget {
  final String searchText;
  const SearchResultWidget({Key? key, required this.searchText})
      : super(key: key);

  @override
  SearchResultWidgetState createState() => SearchResultWidgetState();
}

class SearchResultWidgetState extends State<SearchResultWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GetBuilder<SearchController>(builder: (searchController) {
        bool isNull = true;
        int length = 0;

        isNull = searchController.searchItemList == null;
        if (!isNull) {
          length = searchController.searchItemList!.length;
        }

        return isNull
            ? const SizedBox()
            : Center(
                child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Row(children: [
                        Text(
                          length.toString(),
                          style: robotoBold.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeSmall),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Expanded(
                            child: Text(
                          'results_found'.tr,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).disabledColor,
                              fontSize: Dimensions.fontSizeSmall),
                        )),
                        widget.searchText.isNotEmpty
                            ? InkWell(
                                onTap: () {
                                  List<double?> prices = [];
                                  if (!Get.find<SearchController>().isStore) {
                                    for (var product
                                        in Get.find<SearchController>()
                                            .allItemList!) {
                                      prices.add(product.price);
                                    }
                                    prices.sort();
                                  }
                                  double? maxValue = prices.isNotEmpty
                                      ? prices[prices.length - 1]
                                      : 1000;
                                  Get.dialog(FilterWidget(
                                      maxValue: maxValue,
                                      isStore: Get.find<SearchController>()
                                          .isStore));
                                },
                                child: const Icon(Icons.filter_list),
                              )
                            : const SizedBox(),
                      ]),
                    )));
      }),
      Expanded(
          child: NotificationListener(
        onNotification: (dynamic scrollNotification) {
          if (scrollNotification is ScrollEndNotification) {
            Get.find<SearchController>().searchData(widget.searchText, false);
          }
          return false;
        },
        child: const ItemView(isItem: false),
      )),
    ]);
  }
}
