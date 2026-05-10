import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  int points = 0;

  final List<Map<String, dynamic>> rewards = [
    {
      'title': '☕ Free Coffee',
      'cost': 100,
    },
    {
      'title': '👜 Eco Bag',
      'cost': 250,
    },
    {
      'title': '🌱 Plant a Tree',
      'cost': 500,
    },
  ];

  int get level => (points ~/ 100) + 1;

  @override
  void initState() {
    super.initState();
    loadPoints();
  }

  // LOAD SAVED POINTS
  Future<void> loadPoints() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      points = prefs.getInt('points') ?? 0;
    });
  }

  // SAVE POINTS
  Future<void> savePoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', points);
  }

  // ADD POINTS
  void addPoints() async {
    setState(() {
      points += 10;
    });

    await savePoints();
  }

  // REMOVE POINTS
  void takePoints() async {
    setState(() {
      points -= 15;
    });

    await savePoints();
  }

  // ACHIEVEMENT TITLE
  String getAchievement() {
    if (points >= 500) {
      return '🌍 Planet Protector';
    } else if (points >= 250) {
      return '🏆 Recycling Master';
    } else if (points >= 100) {
      return '♻️ Eco Hero';
    } else if (points >= 50) {
      return '🌱 Beginner Recycler';
    } else {
      return 'Start recycling to unlock achievements!';
    }
  }

  // BADGES
  List<String> getBadges() {
    List<String> badges = [];

    if (points >= 50) {
      badges.add('🌱 Beginner Recycler');
    }

    if (points >= 100) {
      badges.add('♻️ Eco Hero');
    }

    if (points >= 250) {
      badges.add('🏆 Recycling Master');
    }

    if (points >= 500) {
      badges.add('🌍 Planet Protector');
    }

    return badges;
  }

  // REDEEM REWARD
  void redeemReward(Map<String, dynamic> reward) async {
    final int cost = reward['cost'] as int;

    if (points >= cost) {
      setState(() {
        points -= cost;
      });

      await savePoints();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 You redeemed ${reward['title']}!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TOP ICON
              const Icon(
                Icons.workspace_premium,
                size: 120,
                color: Colors.orange,
              ),

              const SizedBox(height: 20),

              // LEVEL
              Text(
                'Level $level',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 10),

              // POINTS
              Text(
                '$points Points',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 25),

              // PROGRESS BAR
              LinearProgressIndicator(
                value: (points % 100) / 100,
                minHeight: 14,
                borderRadius: BorderRadius.circular(20),
              ),

              const SizedBox(height: 10),

              Text(
                '${100 - (points % 100)} points until next level',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 30),

              // ACHIEVEMENTS CARD
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    children: [
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: getBadges().map((badge) {
                          return Chip(
                            label: Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.green,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 15,),
                       // REMOVE POINTS BUTTON
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(
                    double.infinity,
                    55,
                  ),
                ),

                onPressed: takePoints,

                icon: const Icon(Icons.delete),

                label: const Text(
                  'Log Trashing Action',
                  style: TextStyle(fontSize: 18),
                ),
              ),

                      const SizedBox(height: 20),

                      Text(
                        getAchievement(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ADD POINTS BUTTON
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(
                    double.infinity,
                    55,
                  ),
                ),

                onPressed: addPoints,

                icon: const Icon(Icons.recycling),

                label: const Text(
                  'Log Recycling Action',
                  style: TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 30),

              // REWARDS SHOP TITLE
              const Text(
                'Rewards Shop',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // REWARD CARDS
              ...rewards.map((reward) {
                final int cost = reward['cost'] as int;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    title: Text(
                      reward['title'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    subtitle: Text(
                      '$cost points',
                    ),

                    trailing: ElevatedButton(
                      onPressed: points >= cost
                          ? () => redeemReward(reward)
                          : null,

                      child: const Text('Redeem'),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}