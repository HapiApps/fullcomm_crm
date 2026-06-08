import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/models/employee_details.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/constant/app_colors.dart';
import 'Customtext.dart';


class KeyboardDropdownField<T extends Object> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final String Function(T item) labelBuilder;
  final void Function(T item)? onSelected;
  final String? initialText;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final double borderRadius;
  final Color borderColor;
  final TextEditingController? textEditingController;
  final bool Function(String input, T item)? filterFn;
  final VoidCallback? onClear;


  const KeyboardDropdownField({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.labelBuilder,
    this.onSelected,
    this.initialText,
    this.filterFn,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.textEditingController,
    this.onClear, required this.borderRadius, required this.borderColor,
  });

  @override
  State<KeyboardDropdownField<T>> createState() =>
      _KeyboardDropdownFieldState<T>();
}

class _KeyboardDropdownFieldState<T extends Object>
    extends State<KeyboardDropdownField<T>> {
  late final TextEditingController controller;
  late final FocusNode focusNode;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    controller = widget.textEditingController ?? TextEditingController();
    focusNode = widget.focusNode ?? FocusNode();
    scrollController = ScrollController();

    if (widget.initialText != null && controller.text.isEmpty) {
      controller.text = widget.initialText!;
    }

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    if (widget.textEditingController == null) controller.dispose();
    if (widget.focusNode == null) focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (TextEditingValue value) {
        final input = value.text.trim().toLowerCase();
        List<T> results = widget.items.toList();
        results.sort((a, b) => widget.labelBuilder(a).toLowerCase().compareTo(
          widget.labelBuilder(b).toLowerCase(),
        ));
        if (input.isEmpty) return results;
        results = results.where((item) {
          final label = widget.labelBuilder(item).toLowerCase();

          if (widget.filterFn != null) {
            return widget.filterFn!(input, item);
          }
          return label.contains(input);
        }).toList();

        return results;
      },
      displayStringForOption: widget.labelBuilder,
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, ctrl, focus, onSubmit) {
        return SizedBox(
          height: 40,
          child: GestureDetector(
            onTap: (){
              FocusScope.of(context).requestFocus(focusNode);
            },
            child: TextField(
              controller: ctrl,
              focusNode: focus,
              onSubmitted: (_) => onSubmit(),
              style: GoogleFonts.lato(fontSize: 15),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                filled: true,
                fillColor: Colors.white,
                labelText: widget.labelText,
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                hintText: widget.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    width: 0,
                    color: widget.borderColor,
                  ),
                ),
                suffixIcon: IconButton(
                    onPressed: () {
                      // setState(() {
                      //   ctrl.clear();
                      //   controller.clear();
                      // });
                      // if (widget.onClear != null) {
                      //   widget.onClear!();
                      // }


                      controller.clear();

                      FocusScope.of(context).requestFocus(focusNode);

                      widget.onClear?.call();
                    },
                    icon: Icon(
                      controller.text.isEmpty?Icons.arrow_drop_down:Icons.clear,
                      color: Colors.black,
                      size: 25,
                    )
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    width: 0,
                    color: widget.borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    width: 0,
                    color:widget.borderColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final highlightedIndex = AutocompleteHighlightedOption.of(context);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients && highlightedIndex >= 0) {
            scrollController.animateTo(
              highlightedIndex * 48.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
            );
          }
        });

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              width: 450,
              child: options.isEmpty && controller.text.isNotEmpty
                  ? const ListTile(title: Text("No results found"))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        final isHighlighted = index == highlightedIndex;
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Container(
                            color: isHighlighted
                                ? Theme.of(context).highlightColor
                                : null,
                            height: 45,
                            width: 450,
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: widget.itemBuilder(option),
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}

class KeyboardDropdownField2<T extends Object> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final String Function(T item) labelBuilder;
  final void Function(T item)? onSelected;
  final String? initialText;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final double borderRadius;
  final Color borderColor;
  final TextEditingController? textEditingController;
  final bool Function(String input, T item)? filterFn;
  final VoidCallback? onClear;


  const KeyboardDropdownField2({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.labelBuilder,
    this.onSelected,
    this.initialText,
    this.filterFn,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.textEditingController,
    this.onClear, required this.borderRadius, required this.borderColor,
  });

  @override
  _KeyboardDropdownFieldState2<T> createState() =>
      _KeyboardDropdownFieldState2<T>();
}

class _KeyboardDropdownFieldState2<T extends Object>
    extends State<KeyboardDropdownField2<T>> {
  late TextEditingController controller;
  late FocusNode focusNode;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    controller = widget.textEditingController ?? TextEditingController();
    focusNode = widget.focusNode ?? FocusNode();
    scrollController = ScrollController();

    if (widget.initialText != null && controller.text.isEmpty) {
      controller.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    if (widget.textEditingController == null) controller.dispose();
    if (widget.focusNode == null) focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (TextEditingValue value) {
        final input = value.text.trim().toLowerCase();
        List<T> results = widget.items.toList();
        results.sort((a, b) => widget.labelBuilder(a).toLowerCase().compareTo(
          widget.labelBuilder(b).toLowerCase(),
        ));
        if (input.isEmpty) return results;
        results = results.where((item) {
          final label = widget.labelBuilder(item).toLowerCase();

          if (widget.filterFn != null) {
            return widget.filterFn!(input, item);
          }
          return label.contains(input);
        }).toList();

        return results;
      },
      displayStringForOption: widget.labelBuilder,
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, ctrl, focus, onSubmit) {
        return SizedBox(
          height: 40,
          child: TextField(
            controller: ctrl,
            focusNode: focus,
            onSubmitted: (_) => onSubmit(),
            style: GoogleFonts.lato(fontSize: 15),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              filled: true,
              fillColor: Colors.white,
              focusColor: Colors.white,
              hintText: widget.hintText,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              // suffixIcon: IconButton(
              //     onPressed: () {
              //       setState(() {
              //         ctrl.clear();
              //         controller.clear();
              //       });
              //       if (widget.onClear != null) {
              //         widget.onClear!();
              //       }
              //     },
              //     icon: Icon(
              //       controller.text.isEmpty?Icons.arrow_drop_down:Icons.clear,
              //       color: Colors.black,
              //       size: 25,
              //     )
              // ),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final highlightedIndex = AutocompleteHighlightedOption.of(context);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients && highlightedIndex >= 0) {
            scrollController.animateTo(
              highlightedIndex * 48.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
            );
          }
        });

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              width: 450,
              child: options.isEmpty
                  ? const ListTile(title: Text("No results found"))
                  : ListView.builder(
                controller: scrollController,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  final isHighlighted = index == highlightedIndex;
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Container(
                      color: isHighlighted
                        ? Theme.of(context).highlightColor
                        : null,
                      height: 45,
                      width: 450,
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: widget.itemBuilder(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

///
class SelectKeyboardDropdownField<T extends Object> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final String Function(T item) labelBuilder;
  final void Function(T item)? onSelected;
  final String? initialText;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final double borderRadius;
  final Color borderColor;
  final TextEditingController? textEditingController;
  final bool Function(String input, T item)? filterFn;
  final VoidCallback? onClear;

  const SelectKeyboardDropdownField({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.labelBuilder,
    this.onSelected,
    this.initialText,
    this.filterFn,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.textEditingController,
    this.onClear,
    required this.borderRadius,
    required this.borderColor,
  });

  @override
  State<SelectKeyboardDropdownField<T>> createState() =>
      _SelectKeyboardDropdownFieldState<T>();
}

class _SelectKeyboardDropdownFieldState<T extends Object>
    extends State<SelectKeyboardDropdownField<T>> {

  late TextEditingController controller;
  late FocusNode focusNode;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    controller =
        widget.textEditingController ?? TextEditingController();

    focusNode =
        widget.focusNode ?? FocusNode();

    scrollController = ScrollController();

    if (widget.initialText != null &&
        controller.text.isEmpty) {
      controller.text = widget.initialText!;
    }
  }

  @override
  void dispose() {

    if (widget.textEditingController == null) {
      controller.dispose();
    }

    if (widget.focusNode == null) {
      focusNode.dispose();
    }

    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return RawAutocomplete<T>(

      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (TextEditingValue value) {

        final input =
        value.text.trim().toLowerCase();

        List<T> results =
        widget.items.toList();

        results.sort(
              (a, b) =>
              widget.labelBuilder(a)
                  .toLowerCase()
                  .compareTo(
                widget.labelBuilder(b)
                    .toLowerCase(),
              ),
        );

        if (input.isEmpty) {
          return results;
        }

        results = results.where((item) {

          final label =
          widget.labelBuilder(item)
              .toLowerCase();

          if (widget.filterFn != null) {
            return widget.filterFn!(input, item);
          }

          return label.contains(input);

        }).toList();

        return results;
      },

      displayStringForOption:
      widget.labelBuilder,

      onSelected: widget.onSelected,

      fieldViewBuilder:
          (context, ctrl, focus, onSubmit) {

        return SizedBox(

          height: 40,

          child: TextField(
            controller: ctrl,
            focusNode: focus,

            // ENTER PRESS AUTO SELECT REMOVE
            onSubmitted: (_) {},

            style: GoogleFonts.lato(
              fontSize: 15,
            ),

            decoration: InputDecoration(

              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),

              filled: true,
              fillColor: Colors.white,

              labelText: widget.labelText,

              labelStyle: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),

              hintText: widget.hintText,

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  widget.borderRadius,
                ),
                borderSide: BorderSide(
                  width: 0,
                  color: widget.borderColor,
                ),
              ),

              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  widget.borderRadius,
                ),
                borderSide: BorderSide(
                  width: 0,
                  color: widget.borderColor,
                ),
              ),

              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  widget.borderRadius,
                ),
                borderSide: BorderSide(
                  width: 0,
                  color: widget.borderColor,
                ),
              ),

              suffixIcon: IconButton(

                onPressed: () {

                  setState(() {

                    ctrl.clear();
                    controller.clear();

                  });

                  if (widget.onClear != null) {
                    widget.onClear!();
                  }
                },

                icon: Icon(

                  controller.text.isEmpty
                      ? Icons.arrow_drop_down
                      : Icons.clear,

                  color: Colors.black,
                  size: 25,
                ),
              ),
            ),
          ),
        );
      },

      optionsViewBuilder:
          (context, onSelected, options) {

        final highlightedIndex =
        AutocompleteHighlightedOption.of(
          context,
        );

        WidgetsBinding.instance
            .addPostFrameCallback((_) {

          if (scrollController.hasClients &&
              highlightedIndex >= 0) {

            scrollController.animateTo(

              highlightedIndex * 48.0,

              duration:
              const Duration(
                milliseconds: 100,
              ),

              curve: Curves.easeInOut,
            );
          }
        });

        return Align(

          alignment: Alignment.topLeft,

          child: Material(

            elevation: 4,

            child: Container(

              constraints:
              const BoxConstraints(
                maxHeight: 200,
              ),

              width: 450,

              child: options.isEmpty &&
                  controller.text.isNotEmpty

                  ? const ListTile(
                title: Text(
                  "No results found",
                ),
              )

                  : ListView.builder(

                controller:
                scrollController,

                itemCount:
                options.length,

                itemBuilder:
                    (context, index) {

                  final option =
                  options.elementAt(
                    index,
                  );

                  final isHighlighted =
                      index ==
                          highlightedIndex;

                  return InkWell(

                    onTap: () {
                      onSelected(option);
                    },

                    child: Container(

                      color: isHighlighted
                          ? Theme.of(context)
                          .highlightColor
                          : null,

                      height: 45,
                      width: 450,

                      alignment:
                      Alignment.topLeft,

                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 12,
                      ),

                      child:
                      widget.itemBuilder(
                        option,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class EmpDropdown extends StatefulWidget {
  final List<Staff> custList;
  final ValueChanged<Staff?> onChanged;

  const EmpDropdown({
    super.key,
    required this.custList,
    required this.onChanged,
  });

  @override
  State<EmpDropdown> createState() => _EmpDropdownState();
}

class _EmpDropdownState extends State<EmpDropdown> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _formatCustomer(Staff customer) {
    return '${customer.sName}'
        '${customer.roleTitle.toString().isEmpty ? "" : "-"} '
        '${customer.sMobile}';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: MediaQuery.of(context).size.width*0.4,
      height: 47,
      decoration: customDecoration.baseBackgroundDecoration(
        color: Colors.white,
        radius: 5,
        borderColor: Colors.grey.shade300,
      ),
      child: DropdownSearch<Staff>(
        items: widget.custList,

        /// Text format
        itemAsString: (customer) => _formatCustomer(customer),

        onChanged: widget.onChanged,

        /// Dropdown UI
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: "Search Employee Name",
            hintStyle: GoogleFonts.lato(
              color: Colors.black,
              fontSize: 15,
            ),
            contentPadding: const EdgeInsets.all(10),
            border: InputBorder.none,
          ),
        ),

        /// 🔥 Popup with autofocus fix
        popupProps: PopupProps.menu(
          showSearchBox: true,
          fit: FlexFit.loose,

          /// ✅ AUTO FOCUS FIX
          searchFieldProps: TextFieldProps(
            focusNode: _searchFocusNode,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Type to search...",
            ),

            /// 🔥 Force focus (important for some devices)
            onTap: () {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  FocusScope.of(context).requestFocus(_searchFocusNode);
                }
              });
            },
          ),

          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),

          itemBuilder:
              (context, Staff customer, bool isSelected) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomText(
                textAlign: TextAlign.start,
                colors: AppColors.black,
                text: _formatCustomer(customer),
                isCopy: false,
              ),
            );
          },
        ),
      ),
    );
  }
}