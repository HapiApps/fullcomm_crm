import 'package:flutter/material.dart';
import 'package:fullcomm_crm/res/colors.dart';

class ShortcutHelpDialog {
  static void show(BuildContext context) {
    final List<Map<String, String>> shortcuts = [
      {"key": "F1", "action": "Print the bill you’re currently preparing"},
      {"key": "F3", "action": "Save the bill to hold bill list"},
      {"key": "Alt + S", "action": "Open the page showing all saved bills"},
      {"key": "Alt + H", "action": "Open the page showing all Hold/Release bills"},
      {"key": "Alt + C", "action": "Open the form to add a new customer"},
      {"key": "Alt + R", "action": "Open the dialog to return quantity"},
      {"key": "Alt + L", "action": "Update the stock list to see latest quantities"},
      {"key": "Alt + K", "action": "Show this list of shortcut keys"},
      {"key": "Alt + p", "action": "To search product details"},
      {"key": "Alt + A", "action": "To search customer"},
      {"key": "Alt + O", "action": "Log out of the billing system"},
      {"key": "Esc", "action": "All Screen/Dialog Back Navigation"},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.primary),
              SizedBox(width: 2),
              Text("Shortcut Keys"),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: shortcuts.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                    leading: Icon(Icons.keyboard, color: AppColors.primary),
                    title: Row(
                      children: [
                        Text(
                          shortcuts[index]['key']!,

                        ),
                        const SizedBox(width: 10),
                        Text(
                          "(${shortcuts[index]['action']!})", // <-- இங்க interpolation சரியாக

                        ),
                      ],
                    ));
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }
}
