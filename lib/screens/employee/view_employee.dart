import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/models/employee_obj.dart';
import 'package:fullcomm_crm/screens/employee/add_employee.dart';
import '../../common/constant/assets_constant.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_appbar.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';

class ViewEmployees extends StatefulWidget {
  const ViewEmployees({super.key});

  @override
  State<ViewEmployees> createState() => _ViewEmployeesState();
}

class _ViewEmployeesState extends State<ViewEmployees> {
  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
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
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1230 > MediaQuery.of(context).size.width - 200
                          ? 1150
                          : MediaQuery.of(context).size.width - 200,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          20.height,
                          utils.headingBox(
                              width: MediaQuery.of(context).size.width - 200,
                              text: "All Employees"),
                          40.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                height: 50,
                                child: TextField(
                                  textCapitalization: TextCapitalization.words,
                                  keyboardType: TextInputType.text,
                                  onChanged: (value) {},
                                  decoration: InputDecoration(
                                    hoverColor: Colors.white,
                                    hintText: "Employee Name, Position",
                                    hintStyle: TextStyle(
                                      color: colorsConst.secondary,
                                      fontSize: 15,
                                      fontFamily: "Lato",
                                    ),
                                    //prefixIcon: SvgPicture.asset(assets.search,width: 1,height: 1,),
                                    suffixIcon: IconButton(
                                        onPressed: () {},
                                        icon: SvgPicture.asset(assets.search,
                                            width: 15, height: 15)),
                                    fillColor: Colors.white,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
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
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: colorsConst.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                  onPressed: () {
                                    Future.delayed(Duration.zero, () async {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              const AddEmployee(),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      );
                                      //Get.to(const AddEmployee());
                                    });

                                    //controllers.isEmployee.value=false;
                                  },
                                  child: const CustomText(
                                    text: "Add Employee",
                                    colors: Colors.white,
                                    size: 15,
                                  ))
                            ],
                          ),
                          20.height,
                          Expanded(
                            child: FutureBuilder<List<EmployeeObj>>(
                              future: controllers.allEmployeeFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          2, // number of items in each row
                                      //mainAxisSpacing: 2.0, // spacing between rows
                                      crossAxisSpacing:
                                          20.0, // spacing between columns
                                    ),
                                    //padding: const EdgeInsets.all(8.0), // padding around the grid
                                    itemCount: snapshot
                                        .data!.length, // total number of items
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                200 / 2,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                CustomText(
                                                  text: snapshot
                                                      .data![index].doj
                                                      .toString(),
                                                  colors: Colors.grey.shade400,
                                                  size: 15,
                                                )
                                              ],
                                            ),
                                            Container(
                                              height: 200,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: Colors.grey)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      CustomText(
                                                        text: "Employee ID",
                                                        colors: Colors
                                                            .grey.shade400,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: "Name",
                                                        colors: Colors
                                                            .grey.shade400,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: "Position/Title",
                                                        colors: Colors
                                                            .grey.shade400,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: "Department",
                                                        colors: Colors
                                                            .grey.shade400,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: "Email",
                                                        colors: Colors
                                                            .grey.shade400,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      CustomText(
                                                        text: snapshot
                                                            .data![index].empId
                                                            .toString(),
                                                        colors:
                                                            colorsConst.primary,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: snapshot
                                                            .data![index].name
                                                            .toString(),
                                                        colors:
                                                            colorsConst.primary,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: snapshot
                                                            .data![index]
                                                            .position
                                                            .toString(),
                                                        colors:
                                                            colorsConst.primary,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: snapshot
                                                            .data![index]
                                                            .department
                                                            .toString(),
                                                        colors:
                                                            colorsConst.primary,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: snapshot
                                                            .data![index].email
                                                            .toString(),
                                                        colors:
                                                            colorsConst.primary,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      CustomText(
                                                        text: "Phone Number",
                                                        colors: Colors
                                                            .grey.shade400,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: "Address \n ",
                                                        colors: Colors
                                                            .grey.shade400,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: "Status",
                                                        colors: Colors
                                                            .grey.shade400,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: "Salary",
                                                        colors: Colors
                                                            .grey.shade400,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: "Manager Name",
                                                        colors: Colors
                                                            .grey.shade400,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      CustomText(
                                                        text: snapshot
                                                            .data![index]
                                                            .phoneNumber
                                                            .toString(),
                                                        colors:
                                                            colorsConst.primary,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        textAlign:
                                                            TextAlign.start,
                                                        text:
                                                            "${snapshot.data![index].doorNo} ${snapshot.data![index].streetName}\n${snapshot.data![index].area}, ${snapshot.data![index].state}.",
                                                        colors:
                                                            colorsConst.primary,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: "Active",
                                                        colors:
                                                            colorsConst.primary,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text:
                                                            "\u{20B9}${snapshot.data![index].salary}",
                                                        colors:
                                                            colorsConst.primary,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                      CustomText(
                                                        text: snapshot
                                                            .data![index]
                                                            .managerName
                                                            .toString(),
                                                        colors:
                                                            colorsConst.primary,
                                                        size: 13,
                                                        isBold: true,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                } else if (snapshot.hasError) {
                                  return const Text("No Employees");
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ),
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
