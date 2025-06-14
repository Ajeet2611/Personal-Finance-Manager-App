import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final amountController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedCategory = 'Food';

  final Map<String, String> categoryTypeMap = {
    'Food': 'Needs',
    'Rent': 'Needs',
    'Shopping': 'Wants',
    'Movies': 'Wants',
    'Savings Deposit': 'Savings',
    'Investment': 'Savings',
  };

  final List<String> categories = [
    'Food',
    'Rent',
    'Shopping',
    'Movies',
    'Savings Deposit',
    'Investment',
  ];

  void _saveTransaction() async {
    final amount = int.tryParse(amountController.text.trim());
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (amount == null || amount <= 0 || title.isEmpty || description.isEmpty) return;

    final type = categoryTypeMap[selectedCategory] ?? 'Needs';
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('transactions')
        .add({
      'amount': amount,
      'category': selectedCategory,
      'title': title,
      'description': description,
      'type': type,
      'date': DateTime.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1FF), // soft lavender background
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLabel("Category"),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedCategory = val);
              },
              decoration: inputDecoration("Select category"),
            ),
            const SizedBox(height: 16),

            buildLabel("Title"),
            TextField(
              controller: titleController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              ],
              decoration: inputDecoration("e.g. Pizza, Electricity Bill"),
            ),
            const SizedBox(height: 16),

            buildLabel("Description"),
            TextField(
              controller: descriptionController,
              decoration: inputDecoration("e.g. Zomato, Shop No. 5"),
            ),
            const SizedBox(height: 16),

            buildLabel("Amount (₹)"),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: inputDecoration("Enter amount in INR"),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "SAVE TRANSACTION",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple),
            ),
        );
    }
}