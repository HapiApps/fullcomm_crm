import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fullcomm_crm/view_models/billing_provider.dart';

import '../../models/billing_models/category_model.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  // ---------- FocusNodes ----------
  late FocusNode nameFN,
      skuFN,
      barcodeFN,
      generateFN,
      categoryFN,
      subCategoryFN,
      variationFN,
      unitFN,
      mrpFN,
      outPriceFN,
      inPriceFN,
      looseNoFN,
      looseYesFN,
      saveFN;

  // ---------- Keys ----------
  final GlobalKey _categoryKey = GlobalKey();
  final GlobalKey _subCategoryKey = GlobalKey();

  bool _generating = false;

  @override
  void initState() {
    super.initState();

    nameFN = FocusNode();
    skuFN = FocusNode();
    barcodeFN = FocusNode();
    generateFN = FocusNode();
    categoryFN = FocusNode();
    subCategoryFN = FocusNode();
    variationFN = FocusNode();
    unitFN = FocusNode();
    mrpFN = FocusNode();
    outPriceFN = FocusNode();
    inPriceFN = FocusNode();
    looseNoFN = FocusNode();
    looseYesFN = FocusNode();
    saveFN = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<BillingProvider>();
      p.selectedCategoryId = null;
      p.selectedSubCategoryId = null;
      if (p.categories.isEmpty) p.fetchCategories();
      nameFN.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final fn in [
      nameFN,
      skuFN,
      barcodeFN,
      generateFN,
      categoryFN,
      subCategoryFN,
      variationFN,
      unitFN,
      mrpFN,
      outPriceFN,
      inPriceFN,
      looseNoFN,
      looseYesFN,
      saveFN,
    ]) {
      fn.dispose();
    }
    super.dispose();
  }

  // ---------- Dropdown auto open ----------
  void _openDropdown(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(box.size.center(Offset.zero));
    GestureBinding.instance.handlePointerEvent(PointerDownEvent(position: pos));
    GestureBinding.instance.handlePointerEvent(PointerUpEvent(position: pos));
  }

  // ---------- Barcode logic ----------
  Future<void> _handleBarcodeAction(BillingProvider p) async {
    if (p.barcode.text.trim().isNotEmpty) {
      categoryFN.requestFocus();
      Future.delayed(
        const Duration(milliseconds: 80),
            () => _openDropdown(_categoryKey),
      );
      return;
    }

    if (_generating) return;

    setState(() => _generating = true);
    await p.generateUniqueBarcode(context);
    setState(() => _generating = false);

    categoryFN.requestFocus();
    Future.delayed(
      const Duration(milliseconds: 80),
          () => _openDropdown(_categoryKey),
    );
  }

  void _save(BillingProvider p) {
    FocusScope.of(context).unfocus();
    if (p.loading) return;
    if (!p.validatePrices(p, context)) return;
    p.insert_product(context);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (e) {
        if (e is RawKeyDownEvent &&
            e.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.pop(context);
          final billing = Provider.of<BillingProvider>(context, listen: false);
          billing.dropdownFocusNode.requestFocus();
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ChangeNotifierProvider.value(
          value: context.read<BillingProvider>(),
          child: Consumer<BillingProvider>(
            builder: (context, p, _) {
              return SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Add Product",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      _field("Product Name", p.title, nameFN, skuFN, cap: true),
                      _field("HSN Code", p.sku, skuFN, barcodeFN),

                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              "Barcode",
                              p.barcode,
                              barcodeFN,
                              generateFN,
                              numbers: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          RawKeyboardListener(
                            focusNode: generateFN,
                            onKey: (e) {
                              if (e is RawKeyDownEvent &&
                                  e.logicalKey ==
                                      LogicalKeyboardKey.enter) {
                                _handleBarcodeAction(p);
                              }
                            },
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed:
                                _generating ? null : () => _handleBarcodeAction(p),
                                child: _generating
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.qr_code),
                                    SizedBox(width: 6),
                                    Text("Generate"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<Category>(
                        key: _categoryKey,
                        focusNode: categoryFN,
                        decoration:
                        const InputDecoration(labelText: "Category"),
                        value: p.selectedCategory,
                        items: p.categories
                            .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.title),
                        ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            p.setCategory(v.id);
                            Future.delayed(
                              const Duration(milliseconds: 80),
                                  () {
                                subCategoryFN.requestFocus();
                                _openDropdown(_subCategoryKey);
                              },
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      if (p.selectedCategory != null)
                        DropdownButtonFormField<SubCategory>(
                          key: _subCategoryKey,
                          focusNode: subCategoryFN,
                          decoration: const InputDecoration(
                              labelText: "Sub Category"),
                          value: p.selectedSubCategory,
                          items: p.selectedCategory!.subcategories
                              .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.title),
                          ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              p.setSubCategory(v.id);
                              variationFN.requestFocus();
                            }
                          },
                        ),

                      const SizedBox(height: 12),

                      _field("Variation", p.variations, variationFN, unitFN),
                      _field("Unit", p.units, unitFN, mrpFN),
                      _field("MRP", p.mrp, mrpFN, outPriceFN, numbers: true),

                      Row(
                        children: [
                          Expanded(
                            child: _field("Out Price", p.outPrice, outPriceFN,
                                inPriceFN,
                                numbers: true),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _field("In Price", p.inPrice, inPriceFN,
                                looseNoFN,
                                numbers: true),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        "Loose Product",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 6),

                      FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Shortcuts(
                          shortcuts: <LogicalKeySet, Intent>{
                            LogicalKeySet(LogicalKeyboardKey.arrowDown):
                            const DirectionalFocusIntent(TraversalDirection.down),
                            LogicalKeySet(LogicalKeyboardKey.arrowUp):
                            const DirectionalFocusIntent(TraversalDirection.up),
                            LogicalKeySet(LogicalKeyboardKey.enter):
                            const ActivateIntent(),
                          },
                          child: Actions(
                            actions: <Type, Action<Intent>>{
                              ActivateIntent: CallbackAction<ActivateIntent>(
                                onInvoke: (intent) {
                                  saveFN.requestFocus();
                                  return null;
                                },
                              ),
                            },
                            child: Column(
                              children: [

                                /// 🔹 NO
                                Focus(
                                  focusNode: looseNoFN,
                                  child: ListTile(
                                    tileColor: looseNoFN.hasFocus
                                        ? Colors.green.withOpacity(0.12)
                                        : null,
                                    leading: Icon(
                                      p.isLoose == 0
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: p.isLoose == 0 ? Colors.green : Colors.grey,
                                    ),
                                    title: const Text("No"),
                                    onTap: () {
                                      p.setLoose(0);
                                      saveFN.requestFocus();
                                    },
                                  ),
                                ),

                                /// 🔹 YES
                                Focus(
                                  focusNode: looseYesFN,
                                  child: ListTile(
                                    tileColor: looseYesFN.hasFocus
                                        ? Colors.green.withOpacity(0.12)
                                        : null,
                                    leading: Icon(
                                      p.isLoose == 1
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: p.isLoose == 1 ? Colors.green : Colors.grey,
                                    ),
                                    title: const Text("Yes"),
                                    onTap: () {
                                      p.setLoose(1);
                                      saveFN.requestFocus();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(height: 20),

                      RawKeyboardListener(
                        focusNode: saveFN,
                        onKey: (e) {
                          if (e is RawKeyDownEvent &&
                              e.logicalKey == LogicalKeyboardKey.enter) {
                            _save(p);
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: p.loading ? null : () => _save(p),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: const Text("SAVE PRODUCT",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, FocusNode fn,
      FocusNode? next,
      {bool numbers = false, bool cap = false})
  {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        focusNode: fn,
        keyboardType: numbers ? TextInputType.number : TextInputType.text,
        inputFormatters: numbers
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        textInputAction:
        next != null ? TextInputAction.next : TextInputAction.done,
        onChanged: cap
            ? (v) {
          if (v.isEmpty) return;
          final t = v[0].toUpperCase() + v.substring(1);
          if (t != v) {
            c.value = TextEditingValue(
              text: t,
              selection: TextSelection.collapsed(offset: t.length),
            );
          }
        }
            : null,
        onFieldSubmitted: (_) {
          if (next != null) next.requestFocus();
        },
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
