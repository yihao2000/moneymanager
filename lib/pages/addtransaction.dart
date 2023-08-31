import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class Addtransaction extends StatefulWidget {
  const Addtransaction({super.key});

  @override
  State<Addtransaction> createState() => _AddtransactionState();
}

class _AddtransactionState extends State<Addtransaction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          titleSpacing: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios), // Add the menu icon
            onPressed: () {
              Navigator.of(context).pop();
            }, // Open the drawer on icon press
          ),
          title: Text("YOWW"),
          toolbarHeight: 60.0,
        ),
      ),
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(onPressed: () {}, child: Text("Income")),
            TextButton(onPressed: () {}, child: Text("Expense")),
            TextButton(onPressed: () {}, child: Text("Transfer")),
          ],
        )
      ]),
    );
  }
}
