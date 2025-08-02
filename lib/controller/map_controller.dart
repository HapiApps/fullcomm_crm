import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

final mapController = Get.put(MapController());
class MapController extends GetxController {
  var latitude = "".obs;
  var longitude = "".obs;


  late StreamSubscription<Position> streamSubscription;

  @override
  void onInit() {
    super.onInit();
    getLocation();
  }


  Future<void> determinePosition() async {
    print('Location Permission');
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
     print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    mapController.latitude.value=position.latitude.toString();
    mapController.longitude.value=position.longitude.toString();
      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    try {
      List<Location> locations = await locationFromAddress("Chidambara Nagar, Subbiah Puram, Thoothukudi");
      print("location $locations");
      if (locations.isNotEmpty){
          print("Latitude: ${locations[0].latitude}, Longitude: ${locations[0].longitude}");
      } else {
          print("No coordinates found for the given address.");
      }
    } catch (e) {
       print("Failed to get coordinates: $e");
    }
  }


  void requestPermissions() async {
    print("Location permission");
    try {
      LocationPermission permission;
      var status = await Permission.locationAlways.request();



      if (status.isGranted) {
        var position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        latitude.value = position.latitude.toString();
        longitude.value = position.longitude.toString();
        log("Latitude: ${latitude.value}, Longitude: ${longitude.value}");
      } else if (status.isDenied) {
        permission = await Geolocator.requestPermission();
        if (status.isPermanentlyDenied) {
          // Handle permanent denial
        }
      }
    } catch (e) {
      log("Location error: $e");
    }
  }
  getLocation() async {
    try {
      if (kIsWeb) {
        log("Is web");
        var status = await Permission.locationWhenInUse.status;
        log("Status $status");
        if(!status.isGranted){
          var status = await Permission.locationWhenInUse.request();
          if(status.isGranted){
            var status = await Permission.locationAlways.request();
            if(status.isGranted){
              log("Do some stuff");
              //Do some stuff
            }else{
              log("Do another stuff");
              //Do another stuff
            }
          }else{
            log("The user deny the permission");
            //The user deny the permission
          }
          if(status.isPermanentlyDenied){
            log("Open the screen of settings");
          await openAppSettings();
          }
        }else{
          log("In use is available, check the always in use");
          var status = await Permission.locationAlways.status;
          if(!status.isGranted){
            var status = await Permission.locationAlways.request();

            if(status.isGranted){
              var position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high);
              log(position.longitude.toString()); //Output: 80.24599079
              log(position.latitude.toString()); //Output: 29.6593457
              streamSubscription = Geolocator.getPositionStream().listen(
                      (Position position) {
                    latitude.value = "${position.latitude}";
                    longitude.value = "${position.longitude}";
                  });
            }else{
              log("Do another stuff");
            }
          }else{
            log("previously available, do some stuff or nothing");
          }
        }
      } else {
        PermissionStatus permissionStatus = await Permission.locationWhenInUse.request();
        if (permissionStatus.isPermanentlyDenied) {
          log("isPermanentlyDenied");
           await Geolocator.requestPermission();
        } else if (permissionStatus.isDenied){
          log("isDenied");
          await Geolocator.requestPermission();
        } else if (permissionStatus.isGranted){
          log("isGranted");
          var position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          log(position.longitude.toString()); //Output: 80.24599079
          log(position.latitude.toString()); //Output: 29.6593457
          streamSubscription = Geolocator.getPositionStream().listen(
                  (Position position) {
                latitude.value = "${position.latitude}";
                longitude.value = "${position.longitude}";
              });
          // The permission is granted. Proceed with location-related operations.
        } else if (permissionStatus.isRestricted || permissionStatus.isLimited){
          log("isRestricted,isLimited");
        }
      }


    } catch (e) {
      log("Location error $e");
    }
  }



}
