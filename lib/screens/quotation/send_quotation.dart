import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/constant/app_colors.dart';
import '../../components/Customtext.dart';
import '../../controller/controller.dart';
import '../../controller/product_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../models/product_model.dart';

class CustomerDropdown extends StatefulWidget {
  final double width;
  final List<AllCustomersObj> custList;
  final ValueChanged<AllCustomersObj?> onChanged;

  const CustomerDropdown({
    super.key,
    required this.custList,
    required this.onChanged,
    required this.width,
  });

  @override
  State<CustomerDropdown> createState() => _CustomerDropdownState();
}

class _CustomerDropdownState extends State<CustomerDropdown> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _formatCustomer(AllCustomersObj customer) {
    return '${customer.name}'
        '${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} '
        '${customer.name.toString().isEmpty ? "" : "-"} '
        '${customer.phoneNo} - ${customer.category}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: 40,
      decoration: customDecoration.baseBackgroundDecoration(
        color: Colors.white,
        radius: 5,
      ),
      child: DropdownSearch<AllCustomersObj>(
        items: widget.custList,
        itemAsString: (customer) => _formatCustomer(customer),
        onChanged: widget.onChanged,
        filterFn: (customer, filter) {
          final q = filter.toLowerCase().trim();
          if (q.isEmpty) return true;

          final text = _formatCustomer(customer).toLowerCase();

          final textNoSpace = text.replaceAll(RegExp(r'\s+'), '');
          final qNoSpace = q.replaceAll(RegExp(r'\s+'), '');

          if (textNoSpace.contains(qNoSpace)) return true;

          final words = q.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
          return words.every((w) => text.contains(w));
        },
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: controllers.cusController.text.isEmpty
                ? "Search Mobile Number"
                : controllers.cusController.text,
            hintStyle: GoogleFonts.lato(
              color: Colors.grey,
              fontSize: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                width: 0,
                color: Colors.grey.shade300,
              ),
            ),
            suffixIcon: InkWell(
              onTap: () {
                controllers.cusController.clear();
                controllers.clearSelectedCustomer();
              },
              child: const Icon(Icons.clear),
            ),
            contentPadding: const EdgeInsets.all(10),
          ),
        ),

        popupProps: PopupProps.menu(
          showSearchBox: true,
          fit: FlexFit.loose,
          searchFieldProps: TextFieldProps(
            focusNode: _searchFocusNode,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Type to search...",
            ),
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          itemBuilder: (context, AllCustomersObj customer, bool isSelected) {
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


class ProductDropdown extends StatefulWidget {
  final List<ProductModel> prdList;
  final ValueChanged<ProductModel?> onChanged;
  const ProductDropdown({super.key, required this.prdList, required this.onChanged});

  @override
  State<ProductDropdown> createState() => _ProductDropdownState();
}

class _ProductDropdownState extends State<ProductDropdown> {
  @override
  Widget build(BuildContext context) {

    return Container(
      width: MediaQuery.of(context).size.width*0.35,
      height: 47,
      decoration: customDecoration.baseBackgroundDecoration(
        color: Colors.white,
        radius: 5,
      ),
      child: DropdownSearch<ProductModel>(
        items: widget.prdList,
        itemAsString: (ProductModel product) => '${product.title}${product.brand.toString().isEmpty ? "" : ", ${product.brand}"}',
        onChanged: widget.onChanged,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
              hintText: "Search Product Name",
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              )
          ),
        ),
        popupProps: PopupProps.menu(
          showSearchBox: true,
          fit: FlexFit.loose,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          itemBuilder: (context, ProductModel product, bool isSelected) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomText(
                textAlign: TextAlign.start,
                text:'${product.title}${product.brand.toString().isEmpty ? "" : ", ${product.brand}"}', isCopy: false,),
            );
          },
        ),
      ),
    );
  }
}

class ProductSearchDropdown extends StatefulWidget {
  final List<ProductModel> products;
  final Function(ProductModel) onSelected;

  const ProductSearchDropdown({
    super.key,
    required this.products,
    required this.onSelected,
  });

  @override
  State<ProductSearchDropdown> createState() => _ProductSearchDropdownState();
}

class _ProductSearchDropdownState extends State<ProductSearchDropdown> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  List<ProductModel> filtered = [];
  bool showList = false;

  @override
  void initState() {
    super.initState();
    filtered = widget.products;
  }

  void search(String value) {
    setState(() {
      showList = true;

      filtered = widget.products.where((c) {
        return (c.title ?? "")
            .toLowerCase()
            .contains(value.toLowerCase()) ||
            (c.brand ?? "")
                .toLowerCase()
                .contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,

          onTap: () {
            setState(() {
              showList = true;
              filtered = widget.products; // full list show
            });
          },

          onChanged: search,

          decoration: InputDecoration(
            suffixIcon: controller.text.isNotEmpty
                ? InkWell(
              onTap: () {
                setState(() {
                  controller.clear();
                  productCtr.clearProduct();
                  showList = false;
                });
              },
              child: const Icon(Icons.clear, color: Colors.grey),
            )
                : null,
            hintText: "Search Products",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),

        if (showList)
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final customer = filtered[index];

                return InkWell(
                  onTap: () {
                    controller.text =
                    '${customer.title}${customer.brand.toString().isEmpty ? "" : ", ${customer.brand}"}';

                    setState(() {
                      showList = false;
                    });

                    widget.onSelected(customer);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomText(
                      textAlign: TextAlign.start,
                      text:
                      '${customer.title}${customer.brand.toString().isEmpty ? "" : ", ${customer.brand}"}',
                      size: 14,
                      isCopy: false,
                    ),
                  ),
                );
              },
            ),
          )
      ],
    );
  }
}