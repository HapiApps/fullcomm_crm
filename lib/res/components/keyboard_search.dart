import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';

// class KeyboardDropdownField<T extends Object> extends StatefulWidget {
//   final List<T> items;
//   final Widget Function(T item) itemBuilder;
//   final String Function(T item) labelBuilder;
//   final void Function(T item)? onSelected;
//   final String? initialText;
//   final FocusNode? focusNode;
//   final String? hintText;
//   final String? labelText;
//   final TextEditingController? textEditingController;
//   final bool Function(String input, T item)? filterFn;
//   final VoidCallback? onClear;
//
//
//   const KeyboardDropdownField({
//     super.key,
//     required this.items,
//     required this.itemBuilder,
//     required this.labelBuilder,
//     this.onSelected,
//     this.initialText,
//     this.filterFn,
//     this.focusNode,
//     this.hintText,
//     this.labelText,
//     this.textEditingController, this.onClear,
//   });
//
//   @override
//   State<KeyboardDropdownField<T>> createState() =>
//       _KeyboardDropdownFieldState<T>();
// }
//
// class _KeyboardDropdownFieldState<T extends Object>
//     extends State<KeyboardDropdownField<T>> {
//   late TextEditingController controller;
//   late FocusNode focusNode;
//   late ScrollController scrollController;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = widget.textEditingController ?? TextEditingController();
//     focusNode = widget.focusNode ?? FocusNode();
//     scrollController = ScrollController();
//
//     if (widget.initialText != null && controller.text.isEmpty) {
//       controller.text = widget.initialText!;
//     }
//   }
//
//   @override
//   void dispose() {
//     if (widget.textEditingController == null) controller.dispose();
//     if (widget.focusNode == null) focusNode.dispose();
//     scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return RawAutocomplete<T>(
//       textEditingController: controller,
//       focusNode: focusNode,
//       optionsBuilder: (TextEditingValue value) {
//         final input = value.text.trim().toLowerCase();
//         if (input.isEmpty) return widget.items;
//
//         return widget.items.where((item) {
//           final label = widget.labelBuilder(item).toLowerCase();
//           if (widget.filterFn != null) {
//             return widget.filterFn!(input, item);
//           }
//           return label.contains(input);
//         });
//       },
//       displayStringForOption: widget.labelBuilder,
//       onSelected: widget.onSelected,
//       fieldViewBuilder: (context, ctrl, focus, onSubmit) {
//         return TextField(
//           controller: ctrl,
//           focusNode: focus,
//           onSubmitted: (_) => onSubmit(),
//           style: GoogleFonts.lato(fontSize: 15),
//           decoration: InputDecoration(
//             contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
//             filled: true,
//             fillColor: AppColors.textFieldBackground,
//             labelText: widget.labelText,
//             hintText: widget.hintText,
//
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(20),
//               borderSide: const BorderSide(
//                 width: 0,
//                 color: AppColors.textFieldBackground,
//               ),
//             ),
//             suffixIcon: IconButton(
//                onPressed: (){
//                setState(() {
//                  ctrl.clear();
//                  controller.clear();
//                });
//                if (widget.onClear != null) {
//                  widget.onClear!();
//                }
//                },
//                 icon: const Icon(Icons.clear,color: AppColors.black,size: 14,)),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(20),
//               borderSide: const BorderSide(
//                 width: 0,
//                 color: AppColors.textFieldBackground,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(20),
//               borderSide: const BorderSide(
//                 width: 0,
//                 color: AppColors.primary,
//               ),
//             ),
//           ),
//         );
//       },
//       optionsViewBuilder: (context, onSelected, options) {
//         final highlightedIndex = AutocompleteHighlightedOption.of(context);
//
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (scrollController.hasClients && highlightedIndex >= 0) {
//             scrollController.animateTo(
//               highlightedIndex * 48.0,
//               duration: const Duration(milliseconds: 100),
//               curve: Curves.easeInOut,
//             );
//           }
//         });
//
//         return Align(
//           alignment: Alignment.topLeft,
//           child: Material(
//             elevation: 4,
//             child: Container(
//               constraints: const BoxConstraints(maxHeight: 200),
//               width: 400,
//               child: options.isEmpty
//                   ? const ListTile(title: Text("No results found"))
//                   : ListView.builder(
//                 controller: scrollController,
//                 itemCount: options.length,
//                 itemBuilder: (context, index) {
//                   final option = options.elementAt(index);
//                   final isHighlighted = index == highlightedIndex;
//                   return InkWell(
//                     onTap: () => onSelected(option),
//                     child: Container(
//                       color: isHighlighted ? Theme.of(context).highlightColor : null,
//                       height: 50,
//                       width: 400,
//                       alignment: Alignment.centerLeft,
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: widget.itemBuilder(option),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


class KeyboardDropdownField<T extends Object> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final String Function(T item) labelBuilder;
  final void Function(T item)? onSelected;
  final String? initialText;
  final FocusNode? focusNode;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? linkStyle;
  final String? labelText;
  final TextEditingController? textEditingController;
  final bool Function(String input, T item)? filterFn;
  final VoidCallback? onClear;
  final Function(String)? onScan;

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
    this.textEditingController, this.onClear,    this.onScan, this.hintStyle, this.linkStyle,
  });

  @override
  State<KeyboardDropdownField<T>> createState() =>
      _KeyboardDropdownFieldState<T>();
}

class _KeyboardDropdownFieldState<T extends Object>
    extends State<KeyboardDropdownField<T>> {
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
    double screenWidth  = MediaQuery.of(context).size.width;
    return RawAutocomplete<T>(
      textEditingController: controller,
      focusNode: focusNode,
     
      optionsBuilder: (TextEditingValue value) {
        final raw = value.text.trim().toLowerCase();
        if (raw.isEmpty) return widget.items;
        String normalizeCompact(String s) {
          s = s.toLowerCase();
          s = s.replaceAll(RegExp(r'[\s\-\._,]'), '');
          s = s.replaceAll(RegExp(r'[^a-z0-9]'), '');
          s = s.replaceAll(RegExp(r'(kg|g|ml)\b'), '');
          return s;
        }
        List<String> tokens(String s) {
          return s
              .toLowerCase()
              .split(RegExp(r'[^a-z0-9]+'))
              .where((t) => t.isNotEmpty)
              .toList();
        }
        final q = raw;
        final qCompact = normalizeCompact(q);
        final qTokens = tokens(q);

        final List<T> startsWith = [];
        final List<T> titleStarts = [];
        final List<T> wordContains = [];
        final List<T> anyContains = [];

        for (final item in widget.items) {
          final label = widget.labelBuilder(item).toLowerCase();
          String title = label;
          try {
            final dyn = item as dynamic;
            if (dyn.pTitle != null) title = dyn.pTitle.toString().toLowerCase();
          } catch (_) {}
          final labelCompact = normalizeCompact(label);
          final titleCompact = normalizeCompact(title);
          final labelTokens = tokens(label);
          final titleTokens = tokens(title);
          if (widget.filterFn != null) {
            try {
              if (!widget.filterFn!(q, item)) continue;
            } catch (_) {}
          }
          if (label.startsWith(q) || title.startsWith(q)) {
            startsWith.add(item);
            continue;
          }
          if (labelCompact.startsWith(qCompact) || titleCompact.startsWith(qCompact)) {
            titleStarts.add(item);
            continue;
          }
          bool tokenAllMatch(List<String> qTs, List<String> hayTokens) {
            if (qTs.isEmpty) return false;
            return qTs.every((qt) => hayTokens.any((ht) => ht.contains(qt) || normalizeCompact(ht).contains(qt)));
          }

          if (RegExp(r'(^|\s)'+RegExp.escape(q)+r'($|\s)').hasMatch(label) ||
              RegExp(r'(^|\s)'+RegExp.escape(q)+r'($|\s)').hasMatch(title) ||
              tokenAllMatch(qTokens, labelTokens) ||
              tokenAllMatch(qTokens, titleTokens)) {
            wordContains.add(item);
            continue;
          }
          if (labelCompact.contains(qCompact) || titleCompact.contains(qCompact) ||
              label.contains(q) || title.contains(q)) {
            anyContains.add(item);
            continue;
          }
        }

        return [
          ...startsWith,
          ...titleStarts,
          ...wordContains,
          ...anyContains,
        ];
      },


      displayStringForOption: widget.labelBuilder,
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, ctrl, focus, onSubmit) {
        return TextField(
          controller: ctrl,
          focusNode: focus,
          showCursor: true,
          readOnly: false,
          onTap: () {
            focus.requestFocus();
            setState(() {});
          },
          onSubmitted: (value) {
            // 🔥 EMPTY text → Enter block
            if (value.trim().isEmpty) {
              debugPrint("⛔ ENTER BLOCKED (empty input)");
              focus.requestFocus();
              return;
            }

            // ✅ Text irundhaa mattum allow
            onSubmit();
          },

          onChanged: (value) {
            final cleaned = value.trim().replaceAll(RegExp(r'[\r\n]'), '');
            if (cleaned.length >= 4) {
              if (widget.onScan != null) widget.onScan!(cleaned);
            }
          },
          style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            filled: true,
            fillColor: AppColors.textFieldBackground,
            labelText: widget.labelText,
            labelStyle: widget.linkStyle,
            hintText: widget.hintText,
            hintStyle: widget.hintStyle,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  ctrl.clear();
                  controller.clear();
                });
                focus.requestFocus();
                if (widget.onClear != null) widget.onClear!();
              },
              icon: const Icon(Icons.clear, color: AppColors.black, size: 14),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final highlightedIndex = AutocompleteHighlightedOption.of(context);
        if (controller.text.isEmpty) {
          return const SizedBox.shrink();
        }
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
              constraints: const BoxConstraints(maxHeight: 250),
              width:screenWidth * 0.45,
              child: options.isEmpty
                  ? const ListTile(title: Text("No results found"))
                  :
              ListView.builder(
                controller: scrollController,
                itemCount: options.length,
                // inside optionsViewBuilder -> ListView.builder -> itemBuilder:
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  final isHighlighted = index == highlightedIndex;

                  // Wrap the original itemBuilder call in try/catch to prevent parse crashes
                  Widget safeItemWidget() {
                    try {
                      return widget.itemBuilder(option);
                    } catch (e, st) {
                      // Log details to help debug which product causes the problem
                      debugPrint('⚠️ itemBuilder threw for option: $option\nError: $e\n$st');

                      // Return a safe fallback UI (non-crashing)
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('Invalid product data', style: const TextStyle(fontSize: 14))),
                            const Text("—", style: TextStyle(color: Colors.orange, fontSize: 14)),
                          ],
                        ),
                      );
                    }
                  }

                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Container(
                      color: isHighlighted ? Colors.deepOrange : null,
                      constraints: const BoxConstraints(minHeight: 50),
                      width: 400,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: safeItemWidget(),
                    ),
                  );
                },

                // itemBuilder: (context, index) {
                //   final option = options.elementAt(index);
                //   final isHighlighted = index == highlightedIndex;
                //   return InkWell(
                //     onTap: () => onSelected(option),
                //     child: Container(
                //       color: isHighlighted ? Theme.of(context).highlightColor : null,
                //       height: 50,
                //       width: 400,
                //       alignment: Alignment.centerLeft,
                //       padding: const EdgeInsets.symmetric(horizontal: 12),
                //       child: widget.itemBuilder(option),
                //     ),
                //   );
                // },
              ),
            ),
          ),
        );
      },
    );
  }

}