import 'package:flutter/material.dart';
import 'package:moneymanager/globals.dart';
import 'package:moneymanager/queries.dart';
import 'package:moneymanager/widget/bottom_sheet_selection.dart';
import 'package:moneymanager/widget/clickable_field.dart';
import 'package:moneymanager/widget/numeric_text_field.dart';

class Addtransaction extends StatefulWidget {
  const Addtransaction({super.key});

  @override
  State<Addtransaction> createState() => _AddtransactionState();
}

class _AddtransactionState extends State<Addtransaction>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, Color> tabColorMap = {};

  String selectedTabText = 'Income';
  Color selectedIndicatorColor = Colors.blue;

  DateTime selectedDate = DateTime.now();

  late TextEditingController _dateController;
  late TextEditingController _accountController;
  late TextEditingController _categoryController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        setState(() {
          print(userAccounts.toString());
          selectedTabText = tabColorMap.keys.toList()[_tabController.index];
          selectedIndicatorColor = tabColorMap[selectedTabText]!;
        });
      });

    _dateController = TextEditingController();
    _accountController = TextEditingController();
    _categoryController = TextEditingController();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    setSelectedDate(selectedDate);

    //Whenever user is trying to add new transaction it refetches the data
    fetchUserAccounts();
    fetchUserCategories();
  }

  void _handleSubmit() async {
    await addTransactionWithItem(
        selectedDate,
        _accountController.text,
        _categoryController.text,
        int.parse(_amountController.text),
        _noteController.text,
        selectedTabText);

    Navigator.of(context).pop();
  }

  Widget Label(String text) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.20,
      child: Text(
        text,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget SpacingBox(double height) {
    return SizedBox(
      height: height,
    );
  }

  void setSelectedDate(DateTime dateTime) {
    selectedDate = dateTime;
    _dateController.text = formatSpecifiedDate(dateTime);
  }

  void dateFieldOnTap() async {
    final DateTime? dateTime = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(3000));

    if (dateTime != null) {
      setState(() {
        setSelectedDate(dateTime);
      });
    }
  }

  Widget CustomTab() {
    Color buttonColor;

    // Set the button color based on the selected tab
    if (selectedTabText == 'Income') {
      buttonColor = Colors.blue;
    } else if (selectedTabText == 'Expense') {
      buttonColor = Colors.red;
    } else {
      buttonColor = Theme.of(context).primaryColor;
    }
    return Column(
      children: <Widget>[
        SpacingBox(20),
        SizedBox(
            height: 30,
            child: Row(
              children: [
                Label('Date'),
                ClickableTextField(
                  controller: _dateController,
                  onTap: dateFieldOnTap,
                )
              ],
            )),
        SpacingBox(20),
        SizedBox(
            height: 30,
            child: Row(
              children: [
                Label('Account'),
                ClickableTextField(
                  controller: _accountController,
                  onTap: () {
                    CustomBottomSheet.show(context, (selectedAccount) {
                      _accountController.text = selectedAccount;
                    }, userAccounts);
                  },
                )
              ],
            )),
        SpacingBox(20),
        SizedBox(
            height: 30,
            child: Row(
              children: [
                Label('Category'),
                ClickableTextField(
                  controller: _categoryController,
                  onTap: () {
                    CustomBottomSheet.show(context, (selectedCategory) {
                      _categoryController.text = selectedCategory;
                    }, userCategories);
                  },
                )
              ],
            )),
        SpacingBox(20),
        SizedBox(
            height: 30,
            child: Row(
              children: [
                Label('Amount'),
                Expanded(
                    child: NumericTextField(
                  controller: _amountController,
                ))
              ],
            )),
        SpacingBox(20),
        SizedBox(
            height: 30,
            child: Row(
              children: [
                Label('Note'),
                Expanded(
                  child: TextField(
                    // maxLines: null,
                    controller: _noteController,
                  ),
                )
              ],
            )),
        SpacingBox(30),
        SizedBox(
            height: 45,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _handleSubmit();
                    },
                    child: Text("Save"),
                    style: ElevatedButton.styleFrom(
                        primary: buttonColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
              ],
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    tabColorMap = {
      'Income': Colors.blue,
      'Expense': Colors.red,
      'Transfer': Theme.of(context).primaryColor,
    };
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            titleSpacing: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text("Transaction"),
            toolbarHeight: 60.0,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              TabBar(
                indicatorColor: selectedIndicatorColor,
                unselectedLabelColor: Colors.grey,
                controller: _tabController,
                tabs: [
                  Tab(
                    icon: (Text(
                      'Income',
                      style: TextStyle(
                        color: selectedTabText == 'Income'
                            ? tabColorMap['Income']
                            : Theme.of(context).primaryColor,
                      ),
                    )),
                  ),
                  Tab(
                    icon: (Text(
                      'Expense',
                      style: TextStyle(
                        color: selectedTabText == 'Expense'
                            ? tabColorMap['Expense']
                            : Theme.of(context).primaryColor,
                      ),
                    )),
                  ),
                  Tab(
                    icon: (Text(
                      'Transfer',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    )),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CustomTab(),
                    CustomTab(),
                    CustomTab(),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
