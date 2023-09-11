import 'package:sixam_mart/controller/search_controller.dart';
import 'package:sixam_mart/data/model/response/filter_config.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/screens/search/widget/custom_check_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterWidget extends StatelessWidget {
  final double? maxValue;
  final bool isStore;
  const FilterWidget({Key? key, required this.maxValue, required this.isStore})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: GetBuilder<SearchController>(builder: (searchController) {
          return SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeExtraSmall),
                            child: Icon(Icons.close,
                                color: Theme.of(context).disabledColor),
                          ),
                        ),
                        Text('filter'.tr,
                            style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge)),
                        CustomButton(
                          onPressed: () {
                            searchController.resetFilter();
                          },
                          buttonText: 'reset'.tr,
                          transparent: true,
                          width: 65,
                        ),
                      ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text('sort_by'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  GridView.builder(
                    itemCount: searchController.sortList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isDesktop(context)
                          ? 3
                          : ResponsiveHelper.isTab(context)
                              ? 3
                              : 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          searchController.setSortIndex(index);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: searchController.sortIndex == index
                                    ? Colors.transparent
                                    : Theme.of(context).disabledColor),
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                            color: searchController.sortIndex == index
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .disabledColor
                                    .withOpacity(0.1),
                          ),
                          child: Text(
                            searchController.sortList[index],
                            textAlign: TextAlign.center,
                            style: robotoMedium.copyWith(
                              color: searchController.sortIndex == index
                                  ? Colors.white
                                  : Theme.of(context).hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text('filter_by'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomCheckBox(
                    title: 'currently_available_items'.tr,
                    value: searchController.isAvailableItems,
                    onClick: () {
                      searchController.toggleAvailableItems();
                    },
                  ),
                  CustomCheckBox(
                    title: 'discounted_items'.tr,
                    value: searchController.isDiscountedItems,
                    onClick: () {
                      searchController.toggleDiscountedItems();
                    },
                  ),
                  GetBuilder<SearchController>(
                      builder: (con) => Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _customPopupButton(
                                    title: 'Country',
                                    items: con.filterConfig!.countries,
                                    onSelected: (value) {
                                      searchController.resetFilter();
                                      searchController.sortItemSearchList(
                                          type: 'country',
                                          value: value,
                                          productPage: isStore);
                                      Get.back();
                                    }),
                                _customPopupButton(
                                    title: 'Vintage',
                                    items: con.filterConfig!.vintage,
                                    onSelected: (value) {
                                      searchController.resetFilter();
                                      searchController.sortItemSearchList(
                                          type: 'vintage',
                                          value: value,
                                          productPage: isStore);
                                      Get.back();
                                    }),
                                _customPopupButton(
                                    title: 'Brand',
                                    items: con.filterConfig!.brands
                                        .map((e) => e)
                                        .toList(),
                                    onSelected: (value) {
                                      searchController.resetFilter();
                                      searchController.sortItemSearchList(
                                          type: 'brand',
                                          value: value,
                                          productPage: isStore);
                                      Get.back();
                                    }),
                                // _customPopupButton(
                                //     title: 'Item Type',
                                //     items: con.filterConfig!.itemTypes,
                                //     onSelected: (value) {
                                //       searchController.resetFilter();
                                //       searchController.sortItemSearchList(
                                //           type: 'item_type',
                                //           value: value,
                                //           productPage: isStore);
                                //       Get.back();
                                //     }),
                                _customPopupButton(
                                    title: 'Size',
                                    items: con.filterConfig!.units
                                        .map((e) => e)
                                        .toList(),
                                    onSelected: (value) {
                                      searchController.resetFilter();
                                      searchController.sortItemSearchList(
                                          type: 'unit',
                                          value: value,
                                          productPage: isStore);
                                      Get.back();
                                    }),
                              ],
                            ),
                          )),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Column(children: [
                    Text('price'.tr,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                    RangeSlider(
                      values: RangeValues(searchController.lowerValue,
                          searchController.upperValue),
                      max: 1000000.toDouble(),
                      min: 0,
                      divisions: 1000000.toInt(),
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor:
                          Theme.of(context).primaryColor.withOpacity(0.3),
                      labels: RangeLabels(
                          searchController.lowerValue.toString(),
                          searchController.upperValue.toString()),
                      onChanged: (RangeValues rangeValues) {
                        searchController.setLowerAndUpperValue(
                            rangeValues.start, rangeValues.end);
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ]),
                  Text('rating'.tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge)),
                  Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: ListView.builder(
                      itemCount: 5,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => searchController.setRating(index + 1),
                          child: Icon(
                            searchController.rating < (index + 1)
                                ? Icons.star_border
                                : Icons.star,
                            size: 30,
                            color: searchController.rating < (index + 1)
                                ? Theme.of(context).disabledColor
                                : Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    buttonText: 'apply_filters'.tr,
                    onPressed: () {
                      searchController.sortItemSearchList(productPage: isStore);
                      Get.back();
                    },
                  ),
                ]),
          );
        }),
      ),
    );
  }

  Widget _customPopupButton(
      {required String title,
      required List<dynamic> items,
      required Function(dynamic) onSelected}) {
    return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: PopupMenuButton(
          onSelected: onSelected,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(title,
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      fontWeight: FontWeight.normal)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          itemBuilder: (context) {
            return items
                .map((e) => PopupMenuItem(
                    child: Text(e is Brand
                        ? e.name
                        : e is Unit
                            ? e.unit
                            : e),
                    onTap: () => onSelected(e is Brand
                        ? e.id
                        : e is Unit
                            ? e.unit
                            : e)))
                .toList();
          },
        ));
  }
}
