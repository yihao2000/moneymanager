import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moneymanager/auth.dart';

Future<List<Map<String, dynamic>>> fetchUserTransactionsInMonth(
    int targetYear, int targetMonth) async {
  List<Map<String, dynamic>> transactionsList = [];

  try {
    DateTime startOfMonth = DateTime(targetYear, targetMonth, 1);
    DateTime endOfMonth =
        DateTime(targetYear, targetMonth + 1, 1).subtract(Duration(days: 1));

    // Fetch the user document
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.email)
        .get();

    // Check if the user document exists
    if (userSnapshot.exists) {
      // Get a reference to the user's 'transactions' subcollection
      CollectionReference transactionsCollection =
          userSnapshot.reference.collection('transactions');

      // Fetch transactions from the 'transactions' subcollection
      QuerySnapshot transactionsSnapshot = await transactionsCollection
          .where('transactionDate', isGreaterThanOrEqualTo: startOfMonth)
          .where('transactionDate', isLessThanOrEqualTo: endOfMonth)
          .get();

      // Loop through the fetched transactions
      for (QueryDocumentSnapshot transactionDoc in transactionsSnapshot.docs) {
        Map<String, dynamic> transactionData =
            transactionDoc.data() as Map<String, dynamic>;

        // Get a reference to the 'items' subcollection within the transaction
        CollectionReference itemsCollection =
            transactionDoc.reference.collection('items');

        // Fetch items from the 'items' subcollection
        QuerySnapshot itemsSnapshot = await itemsCollection.get();
        List<Map<String, dynamic>> itemsList = itemsSnapshot.docs
            .map((itemDoc) => itemDoc.data() as Map<String, dynamic>)
            .toList();

        // Add the 'items' subcollection data to the transaction data
        transactionData['items'] = itemsList;

        transactionsList.add(transactionData);
      }
    }
  } catch (error) {
    print("Error fetching transactions: $error");
  }

  return transactionsList;
}

Future<void> saveUser(String email, String name, String profilePic) async {
  FirebaseFirestore.instance.collection("users").doc(email).set({
    "email": email,
    "name": name,
    "profilepic": profilePic,
  });

  print("Successfully Saved User Data !");
}
