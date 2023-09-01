import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneymanager/pages/addtransaction.dart';
import 'package:moneymanager/queries.dart';
import 'package:moneymanager/widget/change_theme_button.dart';
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
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Map<String, dynamic>>> transactionsFuture;

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _printTransactionsWithTesting() async {
    transactionsFuture =
        fetchUserTransactionsInMonth(globals.now.year, globals.now.month);
    List<Map<String, dynamic>> transactionsData = await transactionsFuture;
    print(transactionsData);
  }

  @override
  void initState() {
    super.initState();
    _printTransactionsWithTesting();
  }

  void _decrementDate() {
    setState(() {
      globals.decrementDate(1);
    });
  }

  void _incrementDate() {
    setState(() {
      globals.incrementdate(1);
      _printTransactionsWithTesting();
    });
  }

  void _decrementMonth() {
    setState(() {
      globals.decrementMonth(1);
      _printTransactionsWithTesting();
    });
  }

  void _incrementMonth() {
    setState(() {
      globals.incrementMonth(1);
      _printTransactionsWithTesting();
    });
  }

  Future<void> _signOut() async {
    await Auth().signOut();
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
            icon: Icon(Icons.menu_rounded), // Add the menu icon
            onPressed: _openDrawer, // Open the drawer on icon press
          ),
          title: Align(
            alignment: Alignment.centerRight, // Align to the right
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align children to the end (right)
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    // Handle arrow button press
                    _decrementMonth();
                  },
                ),
                Text(
                  globals.formattedDate(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    // Handle arrow button press
                    _incrementMonth();
                  },
                ),
              ],
            ),
          ),
          toolbarHeight: 60.0,
        ),
      ),
      drawer: Drawer(
        // Define your sidebar content here
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Sidebar Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: ChangeThemeButtonWidget(),
            ),
            ListTile(
              title: Text('Sidebar Item 2'),
              onTap: () {
                // Handle sidebar item press
              },
            ),
            ElevatedButton(onPressed: _signOut, child: Text('Sign out')),

            // Add more sidebar items as needed
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: transactionsFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While the data is being fetched, show a loading indicator
              return Text('Loading');
            } else if (snapshot.hasError) {
              // If there's an error, display an error message
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
                              Text(
                                "Income",
                              ),
                              SizedBox(
                                height: 2,
                              ),
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
                              Text(
                                "Expense",
                              ),
                              SizedBox(
                                height: 2,
                              ),
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
                              Text(
                                "Total",
                              ),
                              SizedBox(
                                height: 2,
                              ),
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

                      // Calculate the total sum of transactions for this day
                      for (var item in items) {
                        print(item);
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
                                      child: Text(e["type"]),
                                    ),
                                    Container(
                                      child: Text(e["amount"].toString()),
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
              .push(MaterialPageRoute(builder: (context) => Addtransaction()));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
