import "package:flutter/material.dart";

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rewards Center")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Card(
            child: ListTile(
              title: Text("Cashback Earned This Month"),
              subtitle: Text("INR 1,945"),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text("Expiring Soon"),
              subtitle: Text("INR 110 expires in the next 7 days"),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text("Streak Rewards"),
              subtitle: Text("Week 3 of 4 merchant payments completed"),
            ),
          ),
        ],
      ),
    );
  }
}

