import 'package:sixam_mart/controller/category_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    Get.find<CategoryController>().getCategoryList(false);

    return Scaffold(
      appBar: CustomAppBar(title: 'categories'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
          child: Scrollbar(
              child: SingleChildScrollView(
                  child: FooterView(
                      child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: GetBuilder<CategoryController>(builder: (catController) {
          return catController.categoryList != null
              ? catController.categoryList!.isNotEmpty
                  ? ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      itemCount: catController.categoryList!.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        );
                      },
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () =>
                              Get.toNamed(RouteHelper.getCategoryItemRoute(
                            catController.categoryList![index].id,
                            catController.categoryList![index].name!,
                          )),
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
                                            .categoryList![index].name!,
                                        textAlign: TextAlign.center,
                                        style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        AppConstants.appName,
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
                                      width: 100,
                                      fit: BoxFit.cover,
                                      image:
                                          '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${catController.categoryList![index].image}',
                                    ),
                                  ),
                                ]),
                          ),
                        );
                      },
                    )
                  : NoDataScreen(text: 'no_category_found'.tr)
              : const Center(child: CircularProgressIndicator());
        }),
      ))))),
    );
  }
}
