import 'package:flutter/material.dart';

class Addtransaction extends StatefulWidget {
  const Addtransaction({super.key});

  @override
  State<Addtransaction> createState() => _AddtransactionState();
}

class _AddtransactionState extends State<Addtransaction>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, Color> tabColorMap = {
    'Income': Colors.blue,
    'Expense': Colors.red,
    'Transfer': Colors.white,
  };

  String selectedTabText = 'Income';
  Color selectedIndicatorColor = Colors.blue;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        setState(() {
          selectedTabText = tabColorMap.keys.toList()[_tabController.index];
          selectedIndicatorColor = tabColorMap[selectedTabText]!;
        });
      });
  }

  Widget label(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.grey),
    );
  }

  Widget IncomeTab() {
    return Column(
      children: <Widget>[
        Row(
          children: [
            label('Date'),
            ElevatedButton(
                onPressed: () async {
                  final DateTime? dateTime = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(3000));

                  if (dateTime != null) {
                    setState(() {
                      selectedDate = dateTime;
                    });
                  }
                },
                child: Text("Choose"))
            // SfDateRangePicker(),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text("TEST"),
          toolbarHeight: 60.0,
        ),
      ),
      body: Column(
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
                    color: selectedTabText == 'Transfer'
                        ? tabColorMap['Transfer']
                        : Theme.of(context).primaryColor,
                  ),
                )),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                IncomeTab(),
                Text("Hai"),
                Icon(Icons.directions_bike),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
