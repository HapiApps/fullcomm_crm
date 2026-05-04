import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';

class PaginationWidget extends StatelessWidget {

  final int currentPage;
  final int totalPages;
  final Function(int page) onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {

    List<Widget> pageItems = [];

    // Previous Button
    pageItems.add(
      _pageButton(
        icon: Icons.chevron_left,
        onTap: currentPage > 1
            ? () => onPageChanged(currentPage - 1)
            : null,
      ),
    );

    // First Page
    pageItems.add(
      _numberButton(
        page: 1,
        isSelected: currentPage == 1,
      ),
    );

    // Dots
    if (currentPage > 3) {
      pageItems.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text("..."),
        ),
      );
    }

    // Middle Pages
    for (
    int i = currentPage - 1;
    i <= currentPage + 1;
    i++
    ) {

      if (i > 1 && i < totalPages) {

        pageItems.add(
          _numberButton(
            page: i,
            isSelected: currentPage == i,
          ),
        );
      }
    }

    // Last Dots
    if (currentPage < totalPages - 2) {
      pageItems.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text("..."),
        ),
      );
    }

    // Last Page
    if (totalPages > 1) {

      pageItems.add(
        _numberButton(
          page: totalPages,
          isSelected: currentPage == totalPages,
        ),
      );
    }

    // Next Button
    pageItems.add(
      _pageButton(
        icon: Icons.chevron_right,
        onTap: currentPage < totalPages
            ? () => onPageChanged(currentPage + 1)
            : null,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pageItems,
    );
  }

  Widget _numberButton({
    required int page,
    required bool isSelected,
  }) {

    return InkWell(

      onTap: () => onPageChanged(page),

      child: Container(

        margin: const EdgeInsets.symmetric(horizontal: 4),

        width: 36,
        height: 36,

        alignment: Alignment.center,

        decoration: BoxDecoration(

          color: isSelected
              ? colorsConst.primary
              : Colors.grey.shade100,

          borderRadius: BorderRadius.circular(8),
        ),

        child: Text(
          page.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _pageButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {

    return InkWell(

      onTap: onTap,

      child: Container(

        margin: const EdgeInsets.symmetric(horizontal: 4),

        width: 36,
        height: 36,

        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),

        child: Icon(
          icon,
          size: 20,
        ),
      ),
    );
  }
}