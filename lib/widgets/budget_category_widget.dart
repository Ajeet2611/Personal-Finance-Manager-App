import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BudgetCategoryWidget extends StatefulWidget {
  final String category;
  const BudgetCategoryWidget({super.key, required this.category});

  @override
  State<BudgetCategoryWidget> createState() => _BudgetCategoryWidgetState();
}

class _BudgetCategoryWidgetState extends State<BudgetCategoryWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Future<int> getSalary() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['monthlySalary'];
  }

  Future<void> _addTransaction() async {
    final user = FirebaseAuth.instance.currentUser;
    final title = _titleController.text.trim();
    final amount = int.tryParse(_amountController.text.trim());

    if (title.isEmpty || amount == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('budget')
        .doc(widget.category)
        .collection('transactions')
        .add({
      'title': title,
      'amount': amount,
      'createdAt': Timestamp.now(),
    });

    _titleController.clear();
    _amountController.clear();
    Navigator.pop(context);
    setState(() {});
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add to ${widget.category}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: _addTransaction, child: const Text("Add"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<int>(
        future: getSalary(),
        builder: (context, salarySnap) {
          if (!salarySnap.hasData) return const CircularProgressIndicator();
          final salary = salarySnap.data!;
          final categoryBudget = widget.category == 'needs'
              ? (salary * 0.5).toInt()
              : widget.category == 'wants'
              ? (salary * 0.3).toInt()
              : (salary * 0.2).toInt();

          return Column(
            children: [
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add),
                label: Text("Add ${widget.category} item"),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .collection('budget')
                      .doc(widget.category)
                      .collection('transactions')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();

                    final docs = snapshot.data!.docs;
                    final totalSpent = docs.fold(0, (sum, doc) => sum + (doc['amount'] as int));
                    final remaining = categoryBudget - totalSpent;

                    return Column(
                      children: [
                        Text("Total Budget: ₹$categoryBudget"),
                        Text("Spent: ₹$totalSpent"),
                        Text("Remaining: ₹$remaining", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: ListView(
                            children: docs.map((doc) {
                              return ListTile(
                                title: Text(doc['title']),
                                trailing: Text("₹${doc['amount']}"),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          );
          },
        );
    }
}