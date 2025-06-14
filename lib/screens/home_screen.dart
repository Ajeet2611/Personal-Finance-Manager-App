import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_transaction_screen.dart';
import 'transaction_history_screen.dart';
import 'salary_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkMonthlySalary();
  }

  void _checkMonthlySalary() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!doc.exists || !doc.data()!.containsKey('monthlySalary')) {
      _askForMonthlySalary();
    }
  }

  Future<void> _updateTotals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final transactionsSnapshot = await userDoc.collection('transactions').get();

    int totalSpent = 0;
    for (var doc in transactionsSnapshot.docs) {
      final data = doc.data();
      totalSpent += int.tryParse(data['amount'].toString()) ?? 0;
    }

    final userData = (await userDoc.get()).data();
    final salary = userData?['monthlySalary'] ?? 0;
    final remainingBalance = salary - totalSpent;

    await userDoc.set({
      'totalSpent': totalSpent,
      'remainingBalance': remainingBalance,
    }, SetOptions(merge: true));
  }

  void _askForMonthlySalary() {
    final salaryController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Enter Monthly Salary"),
        content: TextField(
          controller: salaryController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Monthly Salary (₹)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final salary = int.tryParse(salaryController.text);
              if (salary != null) {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                final userDoc = FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid);

                final snapshot = await userDoc.get();
                if (snapshot.exists) {
                  final data = snapshot.data()!;
                  if (data.containsKey('monthlySalary')) {
                    final oldSalary = data['monthlySalary'];
                    final totalSpent = data['totalSpent'] ?? 0;
                    final remaining = data['remainingBalance'] ?? (oldSalary - totalSpent);

                    int needsSpent = 0, wantsSpent = 0, savingsSpent = 0;
                    final transactions = await userDoc.collection('transactions').get();
                    for (var txn in transactions.docs) {
                      final t = txn.data();
                      final amt = int.tryParse(t['amount'].toString()) ?? 0;
                      final type = t['type'];
                      if (type == 'Needs') needsSpent += amt;
                      if (type == 'Wants') wantsSpent += amt;
                      if (type == 'Savings') savingsSpent += amt;
                    }

                    await userDoc.collection('salaryHistory').add({
                      'salary': oldSalary,
                      'totalSpent': totalSpent,
                      'remainingBalance': remaining,
                      'needsSpent': needsSpent,
                      'wantsSpent': wantsSpent,
                      'savingsSpent': savingsSpent,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    for (var doc in transactions.docs) {
                      final txnData = doc.data();
                      await userDoc
                          .collection('${txnData['type']}History')
                          .add({
                        'amount': txnData['amount'],
                        'note': txnData['note'],
                        'date': txnData['date'],
                        'type': txnData['type'],
                        'salaryAtThatTime': oldSalary,
                      });
                      await doc.reference.delete();
                    }
                  }
                }

                await userDoc.set({
                  'monthlySalary': salary,
                  'totalSpent': 0,
                  'remainingBalance': salary,
                }, SetOptions(merge: true));

                Navigator.pop(context);
                await _updateTotals();
                setState(() {});
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'User';
    final firstLetter = email.isNotEmpty ? email[0].toUpperCase() : 'U';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Welcome"),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                firstLetter,
                style: const TextStyle(fontSize: 28, color: Colors.deepPurple),
              ),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_center),
            title: const Text('Help Center'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Help Center"),
                  content: const Text(
                      "Kisi bhi samasya ke liye contact kare: support@email.com"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    )
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finance Manager"),
        actions: [
          IconButton(
            tooltip: "Salary History",
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalaryHistoryScreen()),
              );
            },
          )
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          ).then((_) async {
            await _updateTotals();
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final userData =
          userSnapshot.data!.data() as Map<String, dynamic>?;
          final salary = userData?['monthlySalary'] ?? 0;
          final needsLimit = (salary * 0.5).toInt();
          final wantsLimit = (salary * 0.3).toInt();
          final savingsLimit = (salary * 0.2).toInt();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .collection('transactions')
                .snapshots(),
            builder: (context, txSnapshot) {
              if (!txSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = txSnapshot.data!.docs;
              int needsSpent = 0, wantsSpent = 0, savingsSpent = 0;

              for (var d in docs) {
                final data = d.data() as Map<String, dynamic>;
                final amount = int.tryParse(data['amount'].toString()) ?? 0;
                final type = data['type'];
                if (type == 'Needs') needsSpent += amount;
                if (type == 'Wants') wantsSpent += amount;
                if (type == 'Savings') savingsSpent += amount;
              }

              final totalSpent = needsSpent + wantsSpent + savingsSpent;
              final remaining = salary - totalSpent;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: () => _askForMonthlySalary(),
                      child: _buildSummaryCard(
                        "Monthly Salary",
                        "₹$salary",
                        Colors.deepPurple,
                        Icons.attach_money,
                        "Tap to update",
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      "Total Spent",
                      "₹$totalSpent",
                      Colors.redAccent,
                      Icons.money_off,
                      "",
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      "Remaining",
                      "₹$remaining",
                      remaining < 0 ? Colors.red : Colors.green,
                      remaining < 0
                          ? Icons.warning
                          : Icons.account_balance_wallet,
                      "",
                    ),
                    const SizedBox(height: 20),
                    _buildBudgetTile("Needs", needsLimit, needsSpent,
                        Colors.blue, Icons.home),
                    _buildBudgetTile("Wants", wantsLimit, wantsSpent,
                        Colors.orange, Icons.shopping_cart),
                    _buildBudgetTile("Savings", savingsLimit, savingsSpent,
                        Colors.green, Icons.savings),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color,
      IconData icon, String subtitle) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey[800])),
                  const SizedBox(height: 6),
                  Text(value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: color)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetTile(String type, int allocated, int spent, Color color,
      IconData icon) {
    final remaining = allocated - spent;
    final percent =
    allocated == 0 ? 0.0 : (spent / allocated).clamp(0.0, 1.0);
    DateTime now = DateTime.now();
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionHistoryScreen(
                category: type,
                month: now.month,
                year: now.year,
              ),
            ),
          );
        },
        child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(icon, color: color),
                      const SizedBox(width: 10),
                      Text("$type History",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color)),
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey[300],
                        color: color,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Allocated: ₹$allocated"),
                    Text("Spent: ₹$spent"),
                    Text("Remaining: ₹$remaining",
                        style: TextStyle(
                            color: remaining < 0 ? Colors.red : Colors.black)),
                  ]),
            ),
            ),
        );
    }
}