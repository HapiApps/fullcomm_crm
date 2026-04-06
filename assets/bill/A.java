SizedBox(
  width: screenWidth * 0.45,
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.grey.shade600,
        width: 1.4,
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 0),
    child: KeyboardDropdownField<ProductData>(
      focusNode: dropdownFocusNode,
      items: billingProvider.productsList
        ..sort((a, b) {
          String titleA = a.pTitle?.toLowerCase().trim() ?? "";
          String titleB = b.pTitle?.toLowerCase().trim() ?? "";
          titleA = titleA.replaceAll(RegExp(r'\s+'), '');
          titleB = titleB.replaceAll(RegExp(r'\s+'), '');
          bool aStartsNum = RegExp(r'^\d').hasMatch(titleA);
          bool bStartsNum = RegExp(r'^\d').hasMatch(titleB);
          if (!aStartsNum && bStartsNum) return -1;
          if (aStartsNum && !bStartsNum) return 1;
          return titleA.compareTo(titleB);
        }),
      hintText: "Product...",
      hintStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Colors.grey.shade600,
      ),
      linkStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Colors.black,
      ),
      labelText: "Product",
      textEditingController: dropdownController,
      labelBuilder: (product) {
        return product.isLoose == '0'
            ? '${product.pTitle} ${product.pVariation}${product.unit}'
            : '${product.pTitle} (${product.pVariation})';
      },
      itemBuilder: (product) => Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText(
              text: product.isLoose == '0'
                  ? '${product.pTitle} ${product.pVariation}${product.unit}'
                  : '${product.pTitle} (${product.pVariation})',
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),

            const SizedBox(width: 10),

            // ⬇️ THIS WAS `SizedBox(width: screenWidth * 0.45, child: Row(...))`
            Expanded(
              child: Row(
                children: [
                  const Text(
                    "MRP:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    (() {
                      if (product.isLoose == "1") {
                        double pricePerGram =
                            double.tryParse(product.pricePerG.toString()) ??
                                0.0;
                        return (pricePerGram * 1000).toStringAsFixed(1);
                      } else {
                        return (double.tryParse(product.mrp.toString()) ?? 0.0)
                            .toStringAsFixed(1);
                      }
                    })(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 20),

                  const Text(
                    "Sell:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    (() {
                      if (product.isLoose == "1") {
                        double pricePerGram =
                            double.tryParse(product.pricePerG.toString()) ??
                                0.0;
                        return (pricePerGram * 1000).toStringAsFixed(1);
                      } else {
                        return double
                            .parse(product.outPrice.toString())
                            .toStringAsFixed(1);
                      }
                    })(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 20),

                  const Text(
                    "Stk:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.yellowAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    (() {
                      if (product.isLoose == "1") {
                        double stockKg =
                            double.parse(product.qtyLeft.toString()) / 1000;
                        return "${stockKg.toStringAsFixed(2)} Kg";
                      } else {
                        return (int.tryParse(product.qtyLeft.toString()) ?? 0)
                            .toString();
                      }
                    })(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onScan: (code) {
        final billingProvider =
            Provider.of<BillingProvider>(context, listen: false);
        try {
          final match = billingProvider.productsList.firstWhere(
            (p) => (p.barcode?.trim() ?? "") == code,
          );
          _setScannedProduct(match);
        } catch (_) {}
      },
      onSelected: (product) {
        billingProvider.selectedProduct = product;
        billingProvider.updateTemporaryFields(
          variation: product.isLoose == '1' ? 1.0 : null,
          quantity: product.isLoose == '0' ? 1 : null,
        );

        dropdownController.text = product.isLoose == '0'
            ? '${product.pTitle} ${product.pVariation}${product.unit}'
            : '${product.pTitle} (${product.pVariation})';

        dropdownController.selection = TextSelection.fromPosition(
          TextPosition(offset: dropdownController.text.length),
        );

        fieldFocusNode.requestFocus();
      },
      onClear: () {
        billingProvider.selectedProduct = null;
        billingProvider.updateTemporaryFields(
          quantity: 0,
          variation: 0.0,
        );
        dropdownController.clear();
        quantityVariationController.clear();
      },
    ),
  ),
)
