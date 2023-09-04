import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneymanager/pages/addtransaction.dart';
import 'package:moneymanager/queries.dart';
import 'package:moneymanager/widget/change_theme_button.dart';
import 'package:moneymanager/widget/custom_drawer_widget.dart';
import '../globals.dart' as globals;
import '../auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'My App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Map<String, dynamic>>> transactionsFuture;

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _fetchTransactions() async {
    transactionsFuture =
        fetchUserTransactionsInMonth(globals.now.year, globals.now.month);
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _decrementDate() {
    setState(() {
      globals.decrementDate(1);
    });
  }

  void _incrementDate() {
    setState(() {
      globals.incrementdate(1);
      _fetchTransactions();
    });
  }

  void _decrementMonth() {
    setState(() {
      globals.decrementMonth(1);
      _fetchTransactions();
    });
  }

  void _incrementMonth() {
    setState(() {
      globals.incrementMonth(1);
      _fetchTransactions();
    });
  }

  void refreshPage() {
    _fetchTransactions();
    // Add any other logic you want to run when refreshing the page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          titleSpacing: 0,
          leading: IconButton(
            icon: Icon(Icons.menu_rounded),
            onPressed: _openDrawer,
          ),
          title: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: _decrementMonth,
                ),
                Text(
                  globals.formattedDate(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: _incrementMonth,
                ),
              ],
            ),
          ),
          toolbarHeight: 60.0,
        ),
      ),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: transactionsFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No transactions data available.');
            } else {
              List<Map<String, dynamic>> transactionsData = snapshot.data!;

              final initialTotal = {"Income": 0.0, "Expense": 0.0};

              final totals = transactionsData.fold<Map<String, double>>(
                initialTotal,
                (Map<String, double> acc, transaction) {
                  for (var item in transaction["items"]) {
                    if (item["type"] == "Income") {
                      acc["Income"] =
                          (acc["Income"] ?? 0.0) + (item["amount"] ?? 0.0);
                    } else if (item["type"] == "Expense") {
                      acc["Expense"] =
                          (acc["Expense"] ?? 0.0) + (item["amount"] ?? 0.0);
                    }
                  }
                  return acc;
                },
              );

              final totalIncome = totals["Income"];
              final totalExpense = totals["Expense"];
              final total = totalIncome! - totalExpense!;

              return Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.33,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            children: [
                              Text("Income"),
                              SizedBox(height: 2),
                              Text(
                                totalIncome.toString(),
                                style: TextStyle(color: Colors.blue),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.33,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            children: [
                              Text("Expense"),
                              SizedBox(height: 2),
                              Text(
                                totalExpense.toString(),
                                style: TextStyle(color: Colors.red),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.33,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            children: [
                              Text("Total"),
                              SizedBox(height: 2),
                              Text(
                                total.toString(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  ListView.builder(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: transactionsData.length,
                    itemBuilder: (context, index) {
                      List<dynamic> items = transactionsData[index]["items"];

                      double monthlyIncomeTotal = 0;
                      double monthlyExpenseTotal = 0;

                      for (var item in items) {
                        if (item["type"] == "Income") {
                          monthlyIncomeTotal += item["amount"];
                        } else if (item["type"] == "Expense") {
                          monthlyExpenseTotal += item["amount"];
                        }
                      }
                      return Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                      globals
                                          .getDate(transactionsData[index]
                                              ["transactionDate"] as Timestamp)
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(width: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: Colors.blue.shade300,
                                    ),
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10, top: 3, bottom: 3),
                                    child: Text(globals.getWeekday(
                                        transactionsData[index]
                                            ["transactionDate"])),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 80,
                                    child: FittedBox(
                                      alignment: Alignment.centerRight,
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        monthlyIncomeTotal.toString(),
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                    width: 80,
                                    child: FittedBox(
                                      alignment: Alignment.centerRight,
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        monthlyExpenseTotal.toString(),
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(),
                          Column(
                            children: items.map<Widget>((e) {
                              Color type = Theme.of(context).primaryColor;

                              if (e["type"] == "Income") {
                                type = Colors.blue;
                              } else if (e["type"] == "Expense") {
                                type = Colors.red;
                              }
                              return Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      child: Text(
                                        e["category"],
                                        style: TextStyle(color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(e["account"]),
                                            Text(
                                              e["note"],
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            )
                                          ]),
                                    ),
                                    Container(
                                      child: Text(e["amount"].toString(),
                                          style: TextStyle(color: type)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    },
                  )
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Addtransaction()))
              .then((_) {
            refreshPage(); // Call the refreshPage method when returning from another page
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
