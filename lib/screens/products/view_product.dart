import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/screens/products/tfs_add_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:fullcomm_crm/common/constant/assets_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/custom_product_tile.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/models/product_obj.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_appbar.dart';

class ViewProduct extends StatefulWidget {
  const ViewProduct({super.key});

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double minPartWidth = screenSize.width - 380.0;
    final double partWidth = minPartWidth / 5;
    final double adjustedPartWidth = partWidth;
    return SelectionArea(
      child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: CustomAppbar(
              text: "Zengraf",
            ),
          ),
          body: Stack(
            children: [
              utils.sideBarFunction(context),
              Positioned(
                left: 130,
                child: Container(
                  width: 1349 > MediaQuery.of(context).size.width - 130
                      ? 1349
                      : MediaQuery.of(context).size.width - 130,
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1230 > MediaQuery.of(context).size.width - 250
                          ? 1230
                          : MediaQuery.of(context).size.width - 250,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          20.height,
                          Obx(
                            () => CustomText(
                              text:
                                  "Products(${controllers.allProductLength.value})",
                              colors: colorsConst.primary,
                              size: 23,
                              isBold: true,
                            ),
                          ),
                          20.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      assets.delete,
                                      width: 25,
                                      height: 25,
                                    ),
                                    10.width,
                                    SvgPicture.asset(
                                      assets.edit,
                                      width: 18,
                                      height: 18,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1,
                                                    animation2) =>
                                                const TFSAddProducts(),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
                                          ),
                                        );
                                        //controllers.isProduct.value=false;
                                        //Get.to(const AddProducts());
                                      },
                                      child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          onHover: (PointerEvent details) {
                                            controllers.isAdd.value = true;
                                          },
                                          onExit: (PointerEvent details) {
                                            controllers.isAdd.value = false;
                                          },
                                          child: Obx(
                                            () => CustomText(
                                              text: "Add Product",
                                              decoration:
                                                  controllers.isAdd.value
                                                      ? TextDecoration.underline
                                                      : TextDecoration.none,
                                              colors: colorsConst.primary,
                                              size: 20,
                                            ),
                                          )),
                                    ),
                                    CustomText(
                                      text: "|",
                                      colors: colorsConst.secondary,
                                      size: 20,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return AlertDialog(
                                                // backgroundColor: colorsConst.primary,
                                                actions: [
                                                  CustomLoadingButton(
                                                    callback: () {},
                                                    isLoading: false,
                                                    backgroundColor:
                                                        colorsConst.primary,
                                                    radius: 10,
                                                    width: 100,
                                                    isImage: false,
                                                    text: "Print",
                                                  )
                                                ],
                                                content: SizedBox(
                                                  width: 700,
                                                  height: 500,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: InkWell(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Icon(
                                                                Icons.clear,
                                                                size: 18,
                                                              ))),
                                                      const CustomText(
                                                        text:
                                                            "THIRUMAL FACILITIES SERVICE",
                                                        isBold: true,
                                                        colors: Colors.black,
                                                        size: 16,
                                                      ),
                                                      5.height,
                                                      const CustomText(
                                                        textAlign:
                                                            TextAlign.start,
                                                        text:
                                                            "1234,Broad Street\nDenver,Colorado\n604251",
                                                        colors: Colors.black,
                                                        size: 15,
                                                      ),
                                                      const CustomText(
                                                        text: "9898989898",
                                                        colors: Colors.black,
                                                        size: 15,
                                                      ),
                                                      const CustomText(
                                                        text:
                                                            "thirumal@gmail.com",
                                                        colors: Colors.black,
                                                        size: 15,
                                                      ),
                                                      10.height,
                                                      Divider(
                                                        thickness: 5,
                                                        color:
                                                            colorsConst.primary,
                                                      ),
                                                      20.height,
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const CustomText(
                                                                text: "BILL TO",
                                                                isBold: true,
                                                                colors: Colors
                                                                    .black,
                                                                size: 16,
                                                              ),
                                                              10.height,
                                                              const CustomText(
                                                                text:
                                                                    "Lauren Smith",
                                                                colors: Colors
                                                                    .black,
                                                                size: 15,
                                                              ),
                                                              const CustomText(
                                                                text:
                                                                    "Block Properties",
                                                                colors: Colors
                                                                    .black,
                                                                size: 15,
                                                              ),
                                                              const CustomText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                text:
                                                                    "1234,Broad Street\nDenver,Colorado\n604251",
                                                                colors: Colors
                                                                    .black,
                                                                size: 15,
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const CustomText(
                                                                text:
                                                                    "INVOICE DETAILS",
                                                                isBold: true,
                                                                colors: Colors
                                                                    .black,
                                                                size: 16,
                                                              ),
                                                              10.height,
                                                              Row(
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const CustomText(
                                                                        text:
                                                                            "Invoice Number: ",
                                                                        isBold:
                                                                            true,
                                                                        colors:
                                                                            Colors.black,
                                                                        size:
                                                                            14,
                                                                      ),
                                                                      5.height,
                                                                      const CustomText(
                                                                        text:
                                                                            "Invoice Date: ",
                                                                        isBold:
                                                                            true,
                                                                        colors:
                                                                            Colors.black,
                                                                        size:
                                                                            14,
                                                                      ),
                                                                      10.height,
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const CustomText(
                                                                        text:
                                                                            "001",
                                                                        colors:
                                                                            Colors.black,
                                                                        size:
                                                                            14,
                                                                      ),
                                                                      5.height,
                                                                      const CustomText(
                                                                        text:
                                                                            "23/05/2024",
                                                                        colors:
                                                                            Colors.black,
                                                                        size:
                                                                            14,
                                                                      ),
                                                                      10.height,
                                                                    ],
                                                                  )
                                                                ],
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      20.height,
                                                      const CustomText(
                                                        text: "INVOICE",
                                                        isBold: true,
                                                        colors: Colors.black,
                                                        size: 16,
                                                      ),
                                                      Table(
                                                        columnWidths: const {
                                                          0: FlexColumnWidth(4),
                                                          1: FlexColumnWidth(1),
                                                          2: FlexColumnWidth(1),
                                                          3: FlexColumnWidth(
                                                              1.5),
                                                        },
                                                        border: TableBorder.all(
                                                            color: Colors
                                                                .grey.shade400,
                                                            width: 1),
                                                        children: [
                                                          TableRow(children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                40.height,
                                                                const CustomText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text:
                                                                      "     DESCRIPTION",
                                                                  size: 15,
                                                                  isBold: true,
                                                                  colors: Colors
                                                                      .black,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                40.height,
                                                                const CustomText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text:
                                                                      "  QUANTITY",
                                                                  size: 15,
                                                                  isBold: true,
                                                                  colors: Colors
                                                                      .black,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                40.height,
                                                                const CustomText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text:
                                                                      "  RATE",
                                                                  size: 15,
                                                                  isBold: true,
                                                                  colors: Colors
                                                                      .black,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                40.height,
                                                                const CustomText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text:
                                                                      "  AMOUNT",
                                                                  size: 15,
                                                                  isBold: true,
                                                                  colors: Colors
                                                                      .black,
                                                                ),
                                                              ],
                                                            ),
                                                          ]),
                                                          TableRow(children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                40.height,
                                                                const CustomText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text:
                                                                      "     GUARD",
                                                                  colors: Colors
                                                                      .black,
                                                                  size: 14,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                40.height,
                                                                const CustomText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text: "  4",
                                                                  colors: Colors
                                                                      .black,
                                                                  size: 14,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                40.height,
                                                                const CustomText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text: "  100",
                                                                  colors: Colors
                                                                      .black,
                                                                  size: 14,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                40.height,
                                                                const CustomText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text: "  400",
                                                                  colors: Colors
                                                                      .black,
                                                                  size: 14,
                                                                ),
                                                              ],
                                                            ),
                                                          ]),
                                                          TableRow(children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                40.height,
                                                                const CustomText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text:
                                                                      "     LADY GUARD",
                                                                  colors: Colors
                                                                      .black,
                                                                  size: 14,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                40.height,
                                                                const CustomText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text: "  5",
                                                                  colors: Colors
                                                                      .black,
                                                                  size: 14,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                40.height,
                                                                const CustomText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text: "  100",
                                                                  colors: Colors
                                                                      .black,
                                                                  size: 14,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                40.height,
                                                                const CustomText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text: "  500",
                                                                  colors: Colors
                                                                      .black,
                                                                  size: 14,
                                                                ),
                                                              ],
                                                            ),
                                                          ]),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          const CustomText(
                                                            textAlign:
                                                                TextAlign.start,
                                                            text:
                                                                "  Total Amount : ",
                                                            size: 15,
                                                            isBold: true,
                                                            colors:
                                                                Colors.black,
                                                          ),
                                                          5.width,
                                                          const CustomText(
                                                            textAlign:
                                                                TextAlign.start,
                                                            text: "900 ",
                                                            size: 15,
                                                            isBold: true,
                                                            colors:
                                                                Colors.black,
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      child: CustomText(
                                        text: "Import",
                                        colors: colorsConst.primary,
                                        size: 20,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          20.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset(assets.manageColumn),
                              20.width,
                              SizedBox(
                                width: 1230 >
                                        MediaQuery.of(context).size.width - 250
                                    ? 1100
                                    : MediaQuery.of(context).size.width - 300,
                                height: 50,
                                child: TextField(
                                  textCapitalization: TextCapitalization.words,
                                  keyboardType: TextInputType.text,
                                  onChanged: (value) {},
                                  decoration: InputDecoration(
                                    hoverColor: Colors.white,
                                    hintText: "Search",
                                    hintStyle: TextStyle(
                                      color: colorsConst.secondary,
                                      fontSize: 15,
                                      fontFamily: "Lato",
                                    ),
                                    //prefixIcon: SvgPicture.asset(assets.search,width: 1,height: 1,),
                                    prefixIcon: IconButton(
                                        onPressed: () {},
                                        icon: SvgPicture.asset(assets.search,
                                            width: 15, height: 15)),
                                    fillColor: Colors.white,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                          10.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 1230 >
                                        MediaQuery.of(context).size.width - 250
                                    ? 1000
                                    : MediaQuery.of(context).size.width - 380,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: adjustedPartWidth,
                                      child: CustomText(
                                        textAlign: TextAlign.start,
                                        text: "Product Name",
                                        size: 15,
                                        colors: colorsConst.primary,
                                        //isBold: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: minPartWidth / 6,
                                      child: CustomText(
                                        textAlign: TextAlign.start,
                                        text: "Brand",
                                        size: 15,
                                        colors: colorsConst.primary,
                                        //isBold: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: minPartWidth / 4,
                                      child: CustomText(
                                        textAlign: TextAlign.start,
                                        text: "Compare Price(MRP)",
                                        size: 15,
                                        colors: colorsConst.primary,
                                        // isBold: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: adjustedPartWidth,
                                      child: CustomText(
                                        textAlign: TextAlign.start,
                                        text: "Discount on MRP(%)",
                                        size: 15,
                                        colors: colorsConst.primary,
                                        //isBold: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: minPartWidth / 6,
                                      child: Center(
                                        child: CustomText(
                                          textAlign: TextAlign.start,
                                          text: "Product Price",
                                          size: 15,
                                          colors: colorsConst.primary,
                                          //isBold: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: FutureBuilder<List<ProductObj>>(
                              future: controllers.allProductFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        if (snapshot.data![index].name
                                            .toString()
                                            .toLowerCase()
                                            .contains(controllers.searchText
                                                .toLowerCase())) {
                                          return CustomProductTile(
                                              productName: snapshot
                                                  .data![index].name
                                                  .toString(),
                                              brand: snapshot.data![index].brand
                                                  .toString(),
                                              comparePrice: snapshot
                                                  .data![index].comparePrice
                                                  .toString(),
                                              discountPrice: snapshot
                                                  .data![index].discount
                                                  .toString(),
                                              productPrice: snapshot
                                                  .data![index].productPrice
                                                  .toString());
                                        }
                                        return const SizedBox();
                                      });
                                } else if (snapshot.hasError) {
                                  return const Center(
                                      child: CustomText(text: "No Products"));
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ),
                          20.height,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
