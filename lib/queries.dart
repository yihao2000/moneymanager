import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moneymanager/auth.dart';
import 'package:moneymanager/globals.dart';

Future<List<Map<String, dynamic>>> fetchUserTransactionsInMonth(
    int targetYear, int targetMonth) async {
  List<Map<String, dynamic>> transactionsList = [];

  try {
    // Calculate the start date of the target month
    DateTime startOfMonth = DateTime(targetYear, targetMonth, 1);

    // Calculate the end date of the target month
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

      // Fetch and sort transactions by transactionDate
      QuerySnapshot transactionsSnapshot = await transactionsCollection
          .where('transactionDate', isGreaterThanOrEqualTo: startOfMonth)
          .where('transactionDate', isLessThanOrEqualTo: endOfMonth)
          .orderBy('transactionDate',
              descending: true) // Sort by transactionDate
          .get();

      // Loop through the fetched and sorted transactions
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

Future<void> fetchUserAccounts() async {
  try {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.email)
        .get();

    if (userSnapshot.exists) {
      // Explicitly cast the data to Map<String, dynamic>
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        // Access the 'accounts' array from the userData map
        List<dynamic>? accounts = userData['accounts'] as List<dynamic>?;

        if (accounts != null) {
          userAccounts = userAccounts + accounts;
          print(userAccounts.toString());
        } else {
          // 'accounts' is null
          print("No Default Account for User");
        }
      }
    } else {
      // Document with the specified userID doesn't exist
    }
  } catch (e) {
    print('Error fetching user accounts: $e');
  }
}

Future<void> fetchUserCategories() async {
  try {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.email)
        .get();

    if (userSnapshot.exists) {
      // Explicitly cast the data to Map<String, dynamic>
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        // Access the 'accounts' array from the userData map
        List<dynamic>? categories = userData['categories'] as List<dynamic>?;

        if (categories != null) {
          userCategories = userCategories + categories;
          print(userCategories.toString());
        } else {
          // 'accounts' is null
          print("No Default Account for User");
        }
      }
    } else {
      // Document with the specified userID doesn't exist
    }
  } catch (e) {
    print('Error fetching user accounts: $e');
  }
}

Future<void> addTransactionWithItem(DateTime transactionDate, String account,
    String category, int amount, String note, String type) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // Reference to the user's Transactions collection
  final CollectionReference transactionsCollection = firestore
      .collection('users')
      .doc(Auth().currentUser?.email)
      .collection('transactions');

  // Normalize the transactionDate by setting the time component to midnight
  final DateTime normalizedDate = DateTime(
    transactionDate.year,
    transactionDate.month,
    transactionDate.day,
  );

  // Query to check if a transaction with the same date exists
  final QuerySnapshot existingTransactions = await transactionsCollection
      .where('transactionDate', isGreaterThanOrEqualTo: normalizedDate)
      .where('transactionDate',
          isLessThan: normalizedDate.add(Duration(days: 1)))
      .get();

  // If there are no existing transactions with the same date, create a new one
  if (existingTransactions.docs.isEmpty) {
    final DocumentReference newTransactionRef =
        await transactionsCollection.add({
      'transactionDate': normalizedDate,
      // Add other transaction data fields
    });

    // Reference to the Items collection within the new transaction
    final CollectionReference itemsCollection =
        newTransactionRef.collection('items');

    // Insert item data into the Items collection
    await itemsCollection.add({
      'account': account,
      'amount': amount,
      'category': category,
      'note': note,
      'type': type,
      // Add other item data fields
    });
  } else {
    // If a transaction with the same date exists, update the existing transaction
    final DocumentSnapshot existingTransactionDoc =
        existingTransactions.docs[0];
    final CollectionReference itemsCollection =
        existingTransactionDoc.reference.collection('items');

    // Insert item data into the Items collection
    await itemsCollection.add({
      'account': account,
      'amount': amount,
      'category': category,
      'note': note,
      'type': type,
      // Add other item data fields
    });
  }
}
