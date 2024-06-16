import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool is4x4 = true; // 初始显示4x4排行榜

  // 示例排行榜数据
  List<Map<String, dynamic>> leaderboardData4x4 = [
    {"name": "Alice", "score": 15000},
    {"name": "Bob", "score": 12000},
    {"name": "Charlie", "score": 18000},
    {"name": "David", "score": 9000},
    {"name": "Eve", "score": 20000},
  ];

  List<Map<String, dynamic>> leaderboardData5x5 = [
    {"name": "Frank", "score": 17000},
    {"name": "Grace", "score": 13000},
    {"name": "Heidi", "score": 11000},
    {"name": "Ivan", "score": 16000},
    {"name": "Judy", "score": 19000},
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentLeaderboardData = is4x4 ? leaderboardData4x4 : leaderboardData5x5;

    // 对排行榜数据按分数降序排序
    currentLeaderboardData.sort((a, b) => b['score'].compareTo(a['score']));

    return Scaffold(
      appBar: AppBar(
        title: Text('2048'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            '排行榜',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: currentLeaderboardData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${index + 1}. ${currentLeaderboardData[index]["name"]}'),
                  trailing: Text('${currentLeaderboardData[index]["score"]} 分'),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('4x4 排行榜'),
                onPressed: () {
                  setState(() {
                    is4x4 = true;
                  });
                },
              ),
              SizedBox(width: 20),
              ElevatedButton(
                child: Text('5x5 排行榜'),
                onPressed: () {
                  setState(() {
                    is4x4 = false;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}