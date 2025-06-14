import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import  'package:lucide_icons_flutter/lucide_icons.dart';
import 'transaction_history_screen.dart';

class SalaryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const SalaryDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // 🔧 Safe month/year fallback logic
    final int selectedMonth = (data['month'] is int && data['month'] != null)
        ? data['month']
        : (data['updatedAt'] is Timestamp)
        ? (data['updatedAt'] as Timestamp).toDate().month
        : DateTime.now().month;

    final int selectedYear = (data['year'] is int && data['year'] != null)
        ? data['year']
        : (data['updatedAt'] is Timestamp)
        ? (data['updatedAt'] as Timestamp).toDate().year
        : DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Overview'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            title: 'Total Salary',
            value: '₹${data['salary']}',
            color: Colors.green[700],
            icon: LucideIcons.wallet,
          ),
          _buildCard(
            title: 'Total Spent',
            value: '₹${data['totalSpent']}',
            color: Colors.red[600],
            icon: LucideIcons.trendingDown,
          ),
          _buildCard(
            title: 'Remaining Balance',
            value: '₹${data['remainingBalance']}',
            color: Colors.blue[600],
            icon: LucideIcons.piggyBank,
          ),
          _buildCard(
            title: 'Needs Spent',
            value: '₹${data['needsSpent']}',
            color: Colors.orange[600],
            icon: LucideIcons.shoppingBag,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionHistoryScreen(
                    category: 'Needs',
                    month: selectedMonth,
                    year: selectedYear,
                  ),
                ),
              );
            },
          ),
          _buildCard(
            title: 'Wants Spent',
            value: '₹${data['wantsSpent']}',
            color: Colors.purple[600],
            icon: LucideIcons.headphones,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionHistoryScreen(
                    category: 'Wants',
                    month: selectedMonth,
                    year: selectedYear,
                  ),
                ),
              );
            },
          ),
          _buildCard(
            title: 'Savings Spent',
            value: '₹${data['savingsSpent']}',
            color: Colors.teal[600],
            icon: LucideIcons.banknote,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionHistoryScreen(
                    category: 'Savings',
                    month: selectedMonth,
                    year: selectedYear,
                  ),
                ),
              );
            },
          ),
          _buildCard(
            title: 'Last Updated',
            value: data['updatedAt'] != null
                ? (data['updatedAt'] as Timestamp).toDate().toString()
                : 'N/A',
            color: Colors.grey[800],
            icon: LucideIcons.clock,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required Color? color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
        onTap: onTap,
        child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: color?.withOpacity(0.1),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            ),
        );
    }
}