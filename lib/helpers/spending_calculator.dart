import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, double>> getSpendingDetails(double salary) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return {};

  // 50/30/20 rule allocations
  final needsAllocated = salary * 0.5;
  final wantsAllocated = salary * 0.3;
  final savingsAllocated = salary * 0.2;

  // Firestore data fetch
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('transactions')
      .get();

  double needsSpent = 0;
  double wantsSpent = 0;
  double savingsSpent = 0;

  for (var doc in snapshot.docs) {
    final data = doc.data();

    if (!data.containsKey('amount') || !data.containsKey('category')) continue;

    final category = (data['category'] ?? '').toString().toLowerCase();
    final amount = double.tryParse(data['amount'].toString()) ?? 0.0;

    if (category == 'needs') {
      needsSpent += amount;
    } else if (category == 'wants') {
      wantsSpent += amount;
    } else if (category == 'savings') {
      savingsSpent += amount;
    }
  }

  final totalSpent = needsSpent + wantsSpent + savingsSpent;
  final remaining = salary - totalSpent;

  return {
  'totalSpent': totalSpent,
  'remaining': remaining,
  'needsAllocated': needsAllocated,
  'needsSpent': needsSpent,
  'needsRemaining': needsAllocated - needsSpent,
  'wantsAllocated': wantsAllocated,
  'wantsSpent': wantsSpent,
  'wantsRemaining': wantsAllocated - wantsSpent,
  'savingsAllocated': savingsAllocated,
  'savingsSpent': savingsSpent,
  'savingsRemaining': savingsAllocated - savingsSpent,
  };
}