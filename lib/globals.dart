import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

DateTime CURRENT = DateTime.now();

DateTime now = CURRENT;
var formatter = DateFormat('MMM yyyy');

//Default Accounts for User
List userAccounts = ["Cash", "Accounts", "Card"];
List userCategories = ["Allowance", "Salary", "Petty Cash", "Bonus", "Other"];

String formatSpecifiedDate(DateTime dateTime) {
  print(dateTime.toString());
  var currFormatter = DateFormat('dd-MMM-yyyy');
  String formattedDate = currFormatter.format(dateTime);
  print(formattedDate);
  return formattedDate;
}

String formattedDate() {
  String formattedDate = formatter.format(now);
  return formattedDate;
}

int getDate(Timestamp time) {
  return time.toDate().day;
}

String getWeekday(Timestamp time) {
  return DateFormat('EEEE').format(time.toDate()).substring(0, 3);
}

void decrementMonth(int month) {
  now = DateTime(now.year, now.month - 1, now.day);
}

void incrementMonth(int month) {
  now = DateTime(now.year, now.month + 1, now.day);
}

void decrementDate(int day) {
  now = now.subtract(const Duration(days: 1));
}

void incrementdate(int day) {
  now = now.add(const Duration(days: 1));
}
