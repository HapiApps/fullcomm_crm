

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import '../../controller/map_controller.dart';
import '../constant/colors_constant.dart';
import '../utilities/utils.dart';


class ViaMap extends StatefulWidget {
  // double? lat;
  // double? lng;
  // String? dNo;
  // String? street;
  // String? area;
  // String? city;
  // String? state;
  // String? country;
  // String? pinCode;
   const ViaMap({Key? key,
    //  required this.lat,required this.lng,
    // this.dNo,required this.street,required this.area,required this.city,required this.state,
    // required this.country,required this.pinCode
  }) : super(key: key);


  @override
  State<ViaMap> createState() => _ViaMapState();
}

class _ViaMapState extends State<ViaMap> {

  late GoogleMapController googleMapController;
  double lat=0.0;
  double lng=0.0;
  TextEditingController searchController= TextEditingController();
  final List<Marker> _marker =[];
  var isSearch=false.obs;

  late CameraPosition initialCameraPosition;
  LatLng? _currentPosition;
  void getAdd(double lat,double lng) async {
    List<Placemark> placeMark=await placemarkFromCoordinates(lat,lng);
    Placemark place = placeMark[0];
    setState((){
      name=place.name.toString();
      // widget.dNo=place.street.toString();
      // widget.street=place.thoroughfare.toString()==""?"":",${place.thoroughfare}"==""?"":place.thoroughfare.toString();
      // widget.area=place.subLocality.toString();
      // widget.city=place.locality.toString();
      // widget.country=place.country.toString();
      // widget.pinCode=place.postalCode.toString();
      // widget.state=place.administrativeArea.toString();
    });
  }

  @override
  void initState(){
    super.initState();
    var latitude=double.parse(mapController.latitude.value);
    var longitude=double.parse(mapController.longitude.value);

    lat=latitude;
    lng=longitude;
    _currentPosition = LatLng(double.parse(mapController.latitude.value), double.parse(mapController.longitude.value));
    _marker.add(
      Marker(
        markerId: const MarkerId("1"),
        position:LatLng(lat,lng),
        infoWindow: const InfoWindow(title: "Current Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet
        ),
      ),
    );

    //getAdd(lat,lng);
    // searchController.text="Current Location";
    //  }

  }
  final FocusNode focusNode = FocusNode();
  CameraPosition? cameraPosition;
  var isViaMap=false.obs,isLoaded=false.obs;
  var name="";
  DateTime timeBackPressed=DateTime.now();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: SizedBox(
          width: 400,
          height: 50,
          child:TextField(
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.text,
            controller:searchController,
            focusNode:focusNode,
            onEditingComplete:()async{
              focusNode.unfocus();
              if(searchController.text!=""){
                setState((){
                  isViaMap.value=!isViaMap.value;
                });
                try{
                  isLoaded.value=true;
                  List<Location> locations = await locationFromAddress(searchController.text.trim());
                  googleMapController.animateCamera
                    (CameraUpdate.newCameraPosition(CameraPosition
                    (target: LatLng(locations[0].latitude,locations[0].longitude),zoom: 20)));
                  log("lat mark ${locations[0].latitude}");
                  log("lng ${locations[0].longitude}");
                  setState((){
                    lat=locations[0].latitude;
                    lng=locations[0].longitude;
                    _marker.add(
                      Marker(
                        markerId:const MarkerId("1"),
                        position:LatLng(locations[0].latitude,locations[0].longitude),
                        infoWindow: InfoWindow(title:searchController.text),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet
                        ),
                      ),
                    );
                  });
                  List<Placemark> placeMark=await placemarkFromCoordinates(locations[0].latitude,locations[0].longitude);
                  Placemark place = placeMark[0];
                  Placemark placeName = placeMark[1];

                  log("place $place");
                  setState((){
                    name=placeName.name.toString();
                    // widget.dNo=place.street.toString();
                    // widget.street=place.thoroughfare.toString()==""?"":",${place.thoroughfare}"==""?"":place.thoroughfare.toString();
                    // widget.area=place.subLocality.toString();
                    // widget.city=place.locality.toString();
                    // widget.country=place.country.toString();
                    // widget.pinCode=place.postalCode.toString();
                    // widget.state=place.administrativeArea.toString();
                  });
                  isLoaded.value=false;
                }catch(e){
                  isLoaded.value=false;
                  log("error $e");
                  utils.snackBar(context: Get.context!, msg: "Address not found", color: colorsConst.primary);
                }
              }else{
                utils.snackBar(context: Get.context!, msg: "Search your address", color: colorsConst.primary);
              }
            },
            decoration: InputDecoration(
              hintText:"Search your address",
              hintStyle: const TextStyle(
                  fontSize:14,
                  fontFamily: "Lato",
                  color: Colors.grey
              ),
              labelText:"Search Unit",
              labelStyle: const TextStyle(
                  fontSize:14,
                  fontFamily: "Lato",
                  color: Colors.grey
              ),
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),

              suffixIcon:GestureDetector(
                  onTap:()async {
                    focusNode.unfocus();
                    if(searchController.text!=""){
                      setState((){
                        isViaMap.value=!isViaMap.value;
                      });
                      try{
                        isLoaded.value=true;
                        List<Location> locations = await locationFromAddress(searchController.text.trim());
                        googleMapController.animateCamera
                          (CameraUpdate.newCameraPosition(CameraPosition
                          (target: LatLng(locations[0].latitude,locations[0].longitude),zoom: 20)));
                        log("lat ${locations[0].latitude}");
                        log("lng ${locations[0].longitude}");
                        _marker.add(
                          Marker(
                            markerId:const MarkerId("1"),
                            position:LatLng(locations[0].latitude,locations[0].longitude),
                            infoWindow: InfoWindow(title:searchController.text),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet
                            ),
                          ),
                        );

                        List<Marker> updatedMarkers = List.from(_marker);
                        googleMapController.animateCamera(
                          CameraUpdate.newLatLng(LatLng(locations[0].latitude, locations[0].longitude)),
                        );
                        setState(() {
                          _marker.clear();
                          _marker.addAll(updatedMarkers);
                        });
                        List<Placemark> placeMark=await placemarkFromCoordinates(locations[0].latitude,locations[0].longitude);
                        Placemark place = placeMark[0];
                        Placemark placeName = placeMark[1];

                        log("place $place");
                        setState((){
                          name=placeName.name.toString();
                          // widget.dNo=place.street.toString();
                          // widget.street=place.thoroughfare.toString()==""?"":",${place.thoroughfare}"==""?"":place.thoroughfare.toString();
                          // widget.area=place.subLocality.toString();
                          // widget.city=place.locality.toString();
                          // widget.country=place.country.toString();
                          // widget.pinCode=place.postalCode.toString();
                          // widget.state=place.administrativeArea.toString();
                        });
                        isLoaded.value=false;
                      }catch(e){
                        isLoaded.value=false;
                        log("error $e");
                        utils.snackBar(context: Get.context!, msg: "Address not found", color: colorsConst.primary);
                      }
                    }else{
                      utils.snackBar(context: Get.context!, msg: "Search your address", color: colorsConst.primary);
                    }
                  },
                  child:Obx(()=>
                  isLoaded.value==false?Icon(Icons.search,color:colorsConst.primary):
                  Center(child: CustomText(text: "Loading...",size: 12,colors: colorsConst.primary))
                  )),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color:Colors.grey),
                  borderRadius: BorderRadius.circular(10)
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide:  BorderSide(color:colorsConst.primary),
                  borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),
        ),
      ),
      body:PopScope(
        onPopInvoked: (bool didPop) async {
          if (didPop){
            return;
          }
            name="";
            // widget.dNo="";
            // widget.street="";
            // widget.city="";
            // widget.area="";
            // widget.country="";
            // widget.pinCode="";
            // widget.state=null;
            Get.back();
        },

        child:Stack(
          children:[
            Obx(() =>  isLoaded.value==false?GoogleMap(
              initialCameraPosition:CameraPosition(
                  target:_currentPosition!,
                  zoom: 20),
              markers:Set<Marker>.of(_marker),
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              compassEnabled: true,
              onCameraMove: (CameraPosition cameraPositions){
                cameraPosition = cameraPositions;
              },
              mapType: MapType.normal,
              onMapCreated:(GoogleMapController controller){
                googleMapController=controller;
              },
            ):Center(
              child: CustomText(
                text:"Loading",
                colors:colorsConst.primary,
                size:15,
                isBold: true,
              ),
            ),),

            // Positioned(
            //   bottom: 100,
            //   right: 20,
            //   child: Container(
            //     height: 220,
            //     width: 320,
            //     decoration: BoxDecoration(
            //         color: Colors.grey.shade100,
            //         borderRadius: BorderRadius.circular(10),
            //         border: Border.all(
            //             color: Colors.black
            //         )
            //     ),
            //     child:Column(
            //       mainAxisAlignment:MainAxisAlignment.spaceEvenly,
            //       children:[
            //         Row(
            //           mainAxisAlignment:MainAxisAlignment.spaceEvenly,
            //           children:[
            //             const Column(
            //               mainAxisAlignment:MainAxisAlignment.start,
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children:[
            //                 CustomText(
            //                     text:"Name",
            //                     colors:Colors.black,
            //                     size:13),
            //                 CustomText(
            //                     text:"Door No",
            //                     colors:Colors.black,
            //                     size:13),
            //                 SizedBox(
            //                   height:20,
            //                   width: 80,
            //                   // color: Colors.yellow,
            //                   child:CustomText(
            //                       text:"Street",
            //                       colors:Colors.black,
            //                       size:13),
            //                 ),
            //                 CustomText(
            //                     text:"Area",
            //                     colors:Colors.black,
            //                     size:13),
            //                 CustomText(
            //                     text:"City",
            //                     colors:Colors.black,
            //                     size:13),
            //                 CustomText(
            //                     text:"State",
            //                     colors:Colors.black,
            //                     size:13),
            //                 CustomText(
            //                     text:"PinCode",
            //                     colors:Colors.black,
            //                     size:13),
            //                 CustomText(
            //                     text:"Country",
            //                     colors:Colors.black,
            //                     size:13),
            //               ],
            //             ),
            //             Column(
            //               mainAxisAlignment:MainAxisAlignment.start,
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children:[
            //                 CustomText(
            //                     text:name,
            //                     colors:Colors.black,
            //                     size:13),
            //                 CustomText(
            //                     text:widget.dNo,
            //                     colors:Colors.black,
            //                     size:13),
            //                 CustomText(
            //                     text:widget.street,
            //                     colors:Colors.black,
            //                     size:13),
            //                 CustomText(
            //                     text:widget.area,
            //                     colors:Colors.black,
            //                     size:13),
            //                 CustomText(
            //                     text:widget.city,
            //                     colors:Colors.black,
            //                     size:13),
            //
            //                 CustomText(
            //                     text:widget.state ?? "",
            //                     colors:Colors.black,
            //                     size:13),
            //                 CustomText(
            //                     text:widget.pinCode,
            //                     colors:Colors.black,
            //                     size:13),
            //                 CustomText(
            //                     text:widget.country,
            //                     colors:Colors.black,
            //                     size:13),
            //               ],
            //             ),
            //           ],
            //         ),
            //         OutlinedButton(
            //             onPressed:() async {
            //                 controllers.doorNumberController.text=widget.dNo.toString();
            //                 controllers.streetNameController.text=widget.street.toString();
            //                 controllers.cityController.text=widget.city.toString();
            //                 controllers.areaController.text=widget.area.toString();
            //                 controllers.countryController.text=widget.country.toString();
            //                 controllers.pinCodeController.text=widget.pinCode.toString();
            //                 controllers.states=widget.state.toString();
            //                 setState(() {});
            //                 await Future.delayed(const Duration(milliseconds: 100));
            //                 Get.back();
            //
            //             },
            //             child:const CustomText(
            //                 text:"Continue",
            //                 colors:Colors.pink,
            //                 size:15)
            //         )
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}