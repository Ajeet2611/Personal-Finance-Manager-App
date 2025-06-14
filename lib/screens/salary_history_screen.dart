import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'salary_detail_screen.dart';

class SalaryHistoryScreen extends StatelessWidget {
  const SalaryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Salary History")),
        body: const Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Salary History'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 6,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('salaryHistory')
                .orderBy('updatedAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No Salary History Found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              final salaryDocs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: salaryDocs.length,
                itemBuilder: (context, index) {
                  final doc = salaryDocs[index];
                  final data = doc.data() as Map<String, dynamic>? ?? {};

                  final salary = data['salary'] ?? 0;
                  final timestamp = data['updatedAt'];
                  DateTime date;

                  if (timestamp is Timestamp) {
                    date = timestamp.toDate();
                  } else if (timestamp is DateTime) {
                    date = timestamp;
                  } else {
                    date = DateTime.now();
                  }

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.deepPurple, Colors.purpleAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.attach_money,
                            color: Colors.white, size: 30),
                      ),
                      title: Text(
                        "₹$salary",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.deepPurple,
                        ),
                      ),
                      subtitle: Text(
                        "${date.day.toString().padLeft(2, '0')}/"
                            "${date.month.toString().padLeft(2, '0')}/"
                            "${date.year}",
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.purpleAccent.shade200,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SalaryDetailScreen(data: data),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            ),
        );
    }
}