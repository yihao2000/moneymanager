import 'package:flutter/material.dart';

class CustomBottomSheet {
  static void show(
      BuildContext context, Function(String) onSelected, List<dynamic> items) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(items[index]),
              onTap: () {
                onSelected(
                    items[index]); // Pass the selected category to the callback
                Navigator.pop(context); // Close the bottom sheet
              },
            );
          },
        );
      },
    );
  }
}
