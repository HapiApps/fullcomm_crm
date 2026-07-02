import 'package:flutter/material.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';

import '../common/styles/decoration.dart';
import 'Customtext.dart';

class SearchObjectDropdown<T> extends StatefulWidget {
  final List<T> items;

  final String hint;

  final String Function(T item) title;
  final String Function(T item)? subTitle;
  final String Function(T item)? trailingText;

  final Function(T value)? onSelected;

  const SearchObjectDropdown({
    super.key,
    required this.items,
    required this.title,
    this.subTitle,
    this.trailingText,
    this.onSelected,
    this.hint = "Search",
  });

  @override
  State<SearchObjectDropdown<T>> createState() =>
      _SearchObjectDropdownState<T>();
}

class _SearchObjectDropdownState<T>
    extends State<SearchObjectDropdown<T>> {

  final TextEditingController controller =
  TextEditingController();

  OverlayEntry? overlay;

  List<T> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = widget.items;
  }
  @override
  void dispose() {
    closeDropdown();
    controller.dispose();
    super.dispose();
  }
  void openDropdown() {
    closeDropdown();

    final renderBox =
    context.findRenderObject() as RenderBox;

    final size = renderBox.size;

    // overlay = OverlayEntry(
    //   builder: (context) {
    //     return Positioned(
    //       width: size.width,
    //       child: CompositedTransformFollower(
    //         link: layerLink,
    //         offset: Offset(0, size.height + 5),
    //         child: Material(
    //           elevation: 8,
    //           child: Container(
    //             constraints:
    //             BoxConstraints(maxHeight: 350),
    //             color: Colors.white,
    //             child: Column(
    //               children: [
    //
    //                 Expanded(
    //                   child: ListView.builder(
    //                     itemCount: filtered.length,
    //                     itemBuilder: (context, index) {
    //
    //                       final item =
    //                       filtered[index];
    //
    //                       return InkWell(
    //                         onTap: () {
    //
    //                           controller.text =
    //                               widget.title(item);
    //
    //                           widget.onSelected
    //                               ?.call(item);
    //
    //                           closeDropdown();
    //                         },
    //                         child: Container(
    //                           padding:
    //                           EdgeInsets.all(12),
    //                           child: Row(
    //                             children: [
    //
    //                               Container(
    //                                 height: 30,
    //                                 width: 30,
    //                                 decoration: customDecoration
    //                                     .baseBackgroundDecoration(
    //                                     color: colorsConst.primary,
    //                                     radius: 10),
    //                                 child: Image.asset(
    //                                     "assets/images/people1.png"),
    //                               ),
    //
    //                               12.width,
    //
    //                               Expanded(
    //                                 child: Column(
    //                                   crossAxisAlignment:
    //                                   CrossAxisAlignment
    //                                       .start,
    //                                   children: [
    //
    //                                     CustomText(text:widget.title(item), isCopy: false,isBold: true,),
    //                                     if (widget.subTitle !=null)
    //                                     CustomText(text:widget.subTitle!(item),isCopy: false,colors: Colors.grey,),
    //                                   ],
    //                                 ),
    //                               ),
    //
    //                               if (widget .trailingText != null)
    //                                 CustomText(text:widget.trailingText!(item),isCopy: false,colors: colorsConst.primary,),
    //                             ],
    //                           ),
    //                         ),
    //                       );
    //                     },
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // );
    //
    // Overlay.of(context).insert(overlay!);

    overlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [

            /// Outside click detect
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  closeDropdown();
                },
                child: const SizedBox(),
              ),
            ),

            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: layerLink,
                offset: Offset(0, size.height + 5),
                child: Material(
                  elevation: 8,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 350),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];

                              return InkWell(
                                  onTap: () {
                                    controller.text = widget.title(item);
                                    widget.onSelected?.call(item);
                                    closeDropdown();
                                  },
                                  child: Container(
                                    padding:
                                    EdgeInsets.all(12),
                                    child: Row(
                                      children: [

                                        Container(
                                          height: 30,
                                          width: 30,
                                          decoration: customDecoration
                                              .baseBackgroundDecoration(
                                              color: colorsConst.primary,
                                              radius: 10),
                                          child: Image.asset(
                                              "assets/images/people1.png"),
                                        ),

                                        12.width,

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [

                                              CustomText(text:widget.title(item), isCopy: false,isBold: true,),
                                              if (widget.subTitle !=null)
                                                CustomText(text:widget.subTitle!(item),isCopy: false,colors: Colors.grey,),
                                            ],
                                          ),
                                        ),

                                        if (widget .trailingText != null)
                                          CustomText(text:widget.trailingText!(item),isCopy: false,colors: colorsConst.primary,),
                                      ],
                                    ),
                                  ),
                              );
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
        );
      },
    );

    Overlay.of(context).insert(overlay!);
  }

  void closeDropdown() {
    overlay?.remove();
    overlay = null;
  }
  void filter(String value) {

    final search =
    value.toLowerCase().trim();

    setState(() {

      filtered = widget.items.where((e) {

        final title =
        widget.title(e)
            .toLowerCase();

        final subTitle =
            widget.subTitle
                ?.call(e)
                .toLowerCase() ??
                "";

        final trailing =
            widget.trailingText
                ?.call(e)
                .toLowerCase() ??
                "";

        return title.contains(search) ||
            subTitle.contains(search) ||
            trailing.contains(search);

      }).toList();

    });

    openDropdown();
  }

  final layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {

    return CompositedTransformTarget(
      link: layerLink,
      child: TextField(
        controller: controller,
        onTap: openDropdown,
        onChanged: filter,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: widget.hint,
          prefixIcon:Image.asset("assets/images/search.png"),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                controller.clear();
              });
              // widget.onClear?.call();
            },
            icon: Icon(
              controller.text.isEmpty
                  ? Icons.arrow_drop_down
                  : Icons.clear,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}