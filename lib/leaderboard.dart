import 'package:flutter/material.dart';

// 创建一个名为LeaderboardPage的有状态小部件
class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

// 创建一个名为_LeaderboardPageState的状态类，这个类会存储LeaderboardPage的状态
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
  // 创建小部件的视觉表示
  Widget build(BuildContext context) {
    // 根据is4x4的值，选择显示4x4或5x5的排行榜数据
    List<Map<String, dynamic>> currentLeaderboardData = is4x4 ? leaderboardData4x4 : leaderboardData5x5;

    // 对排行榜数据按分数降序排序
    currentLeaderboardData.sort((a, b) => b['score'].compareTo(a['score']));

    // 返回一个Scaffold，它提供了一个应用程序的视觉结构
    return Scaffold(
      // 创建一个AppBar，显示在应用程序的顶部
      appBar: AppBar(
        title: Text('2048'),
      ),
      // 创建一个Column，它包含了若干子小部件
      body: Column(
        children: [
          SizedBox(height: 20),
          // 创建一个Text，显示"排行榜"
          Text(
            '排行榜',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          // 创建一个ListView.builder，用于显示排行榜数据
          Expanded(
            child: ListView.builder(
              itemCount: currentLeaderboardData.length,
              itemBuilder: (context, index) {
                // 对于每一项，创建一个ListTile，显示玩家的名字和分数
                return ListTile(
                  title: Text('${index + 1}. ${currentLeaderboardData[index]["name"]}'),
                  trailing: Text('${currentLeaderboardData[index]["score"]} 分'),
                );
              },
            ),
          ),
          // 创建一个Row，包含两个按钮，用于切换4x4和5x5的排行榜
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('4x4 排行榜'),
                 // 当点击4x4按钮时，设置is4x4为true
                onPressed: () {
                  setState(() {
                    is4x4 = true;
                  });
                },
              ),
              SizedBox(width: 20),
              ElevatedButton(
                child: Text('5x5 排行榜'),
                // 当点击5x5按钮时，设置is4x4为false
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