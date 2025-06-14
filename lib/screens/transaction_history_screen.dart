import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final String category;
  final int? month;
  final int? year;

  const TransactionHistoryScreen({
    super.key,
    required this.category,
    this.month,
    this.year,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
        appBar: AppBar(
          title: Text('$category Transactions'),
          backgroundColor: Colors.deepPurple,
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .collection('transactions')
                .where('type', isEqualTo: category)
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading data"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final transactions = snapshot.data?.docs ?? [];

              if (transactions.isEmpty) {
                return const Center(child: Text("No transactions found."));
              }

              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final data = transactions[index].data() as Map<String, dynamic>;
                  final title = data['title'] ?? 'No title';
                  final amount = data['amount'] ?? '0';
                  final description = data['description'] ?? 'No description';
                  final timestamp = data['date'];
                  final formattedDate = timestamp != null && timestamp is Timestamp
                      ? DateFormat.yMMMd().add_jm().format(timestamp.toDate())
                      : 'No date';

                  return Card(
                    color: Colors.deepPurple[50],
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: const Icon(Icons.currency_rupee, color: Colors.white),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        "$description\n$formattedDate",
                        style: const TextStyle(color: Colors.black54, height: 1.4),
                      ),
                      trailing: Text(
                        '₹$amount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            ),
        );
    }
}