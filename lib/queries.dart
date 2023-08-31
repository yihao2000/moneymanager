import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<List<Map<String, dynamic>>> fetchExpensesInMonth(
    int targetYear, int targetMonth) async {
  List<Map<String, dynamic>> expensesList = [];

  try {
    DateTime startOfMonth = DateTime(targetYear, targetMonth, 1);
    DateTime endOfMonth =
        DateTime(targetYear, targetMonth + 1, 1).subtract(Duration(days: 1));

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('transactionDate', isGreaterThanOrEqualTo: startOfMonth)
        .where('transactionDate', isLessThanOrEqualTo: endOfMonth)
        .get();

    for (QueryDocumentSnapshot expenseDoc in querySnapshot.docs) {
      Map<String, dynamic> expenseData =
          expenseDoc.data() as Map<String, dynamic>;

      // Fetch the 'items' subcollection within the expense document
      QuerySnapshot itemsSnapshot =
          await expenseDoc.reference.collection('items').get();
      List<Map<String, dynamic>> itemsList = itemsSnapshot.docs
          .map((itemDoc) => itemDoc.data() as Map<String, dynamic>)
          .toList();

      // Add the 'items' subcollection data to the expense data
      expenseData['items'] = itemsList;

      expensesList.add(expenseData);
    }
  } catch (error) {
    print("Error fetching expenses: $error");
  }

  // print(expensesList);
  return expensesList;
}

Future<void> saveUser(String email, String name, String profilePic) async {
  FirebaseFirestore.instance.collection("users").doc(email).set({
    "email": email,
    "name": name,
    "profilepic": profilePic,
  });

  print("Successfully Saved User Data !");
}
