import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreen extends StatefulWidget {
  final String image;
  final bool isNetwork;
  final bool isAssets;
  const FullScreen(
      {Key? key,
      required this.image,
      required this.isNetwork,
      this.isAssets = false})
      : super(key: key);

  @override
  State<FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.isNetwork == true
          ? InteractiveViewer(
              child: Center(
                child: Container(
                  // height: 500,
                  // width: 500,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Image.memory(base64Decode(widget.image)),
                  //  child: CachedNetworkImage(
                  //     imageUrl: widget.image,
                  //     imageBuilder: (context, imageProvider) =>
                  //         Container(
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(5),
                  //             image: DecorationImage(
                  //               image: imageProvider,
                  //               // fit: BoxFit.fill,
                  //               // colorFilter:
                  //               // ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                  //             ),
                  //           ),
                  //         ),
                  //     errorWidget: (context,url,error)=>const Icon(Icons.error),
                  //     placeholder: (context,url)=>Image.asset("assets/gif/loading.gif",width: 50,height: 50,)
                  //   //Image.network(snapshot.data!.img1.toString(),fit: BoxFit.cover)
                  // ),
                ),
              ),
            )
          : widget.isAssets == true
              ? InteractiveViewer(
                  child: Center(
                    child: Container(
                      // height: 500,
                      // width: 500,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      child: Image.asset(widget.image),
                      //  child: CachedNetworkImage(
                      //     imageUrl: widget.image,
                      //     imageBuilder: (context, imageProvider) =>
                      //         Container(
                      //           decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(5),
                      //             image: DecorationImage(
                      //               image: imageProvider,
                      //               // fit: BoxFit.fill,
                      //               // colorFilter:
                      //               // ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                      //             ),
                      //           ),
                      //         ),
                      //     errorWidget: (context,url,error)=>const Icon(Icons.error),
                      //     placeholder: (context,url)=>Image.asset("assets/gif/loading.gif",width: 50,height: 50,)
                      //   //Image.network(snapshot.data!.img1.toString(),fit: BoxFit.cover)
                      // ),
                    ),
                  ),
                )
              : InteractiveViewer(
                  child: Center(
                    child: Container(
                      // height: 500,
                      // width: 500,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      child: CachedNetworkImage(
                          imageUrl: widget.image,
                          imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    // fit: BoxFit.fill,
                                    // colorFilter:
                                    // ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                                  ),
                                ),
                              ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          placeholder: (context, url) => Image.asset(
                              "assets/gif/loading.gif",
                              width: 50,
                              height: 50)
                          //Image.network(snapshot.data!.img1.toString(),fit: BoxFit.cover)
                          ),
                    ),
                    // InteractiveViewer(
                    //         child: Container(
                    //     decoration:  BoxDecoration(
                    //         image:  DecorationImage(
                    //           image:FileImage(File(widget.image)),fit: BoxFit.cover,),
                    //     ),
                  ),
                ),
    );
  }
}
