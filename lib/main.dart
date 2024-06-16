import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // 导入 provider 包以便使用状态管理
import 'package:flutter/services.dart';  // 导入 services 包以便处理键盘事件
import 'game_model.dart';  // 导入之前定义的游戏模型
import 'leaderboard.dart';  // 导入排行榜页面
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),  // 初始页面设置为 HomePage
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2048'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 新游戏按钮
            SizedBox(
              width: 200,  // 按钮的宽度
              height: 60,  // 按钮的高度
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  textStyle: TextStyle(fontSize: 24),
                ),
                child: Text('新游戏'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ChangeNotifierProvider(
                        create: (context) => GameModel(4),  // 创建4x4或者默认的格子游戏模型
                        child: GamePage(),
                      );
                    }),
                  );
                },
              ),
            ),
            SizedBox(height: 20),  // 按钮之间的间距

            SizedBox(
              width: 200,  // 按钮的宽度
              height: 60,  // 按钮的高度
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  textStyle: TextStyle(fontSize: 24),
                ),
                child: Text('4x4'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ChangeNotifierProvider(
                        create: (context) => GameModel(4),
                        child: GamePage(),
                      );
                    }),
                  );
                },
              ),
            ),
            SizedBox(height: 20),  // 按钮之间的间距
            // 5×5 按钮
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  textStyle: TextStyle(fontSize: 24),
                ),
                child: Text('5x5'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ChangeNotifierProvider(
                        create: (context) => GameModel(5),
                        child: GamePage(),
                      );
                    }),
                  );
                },
              ),
            ),
            SizedBox(height: 20),  // 按钮之间的间距
            // 排行榜 按钮
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  textStyle: TextStyle(fontSize: 24),
                ),
                child: Text('排行榜'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeaderboardPage()),
                  );
                  // 这里可以添加显示排行榜的逻辑
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  FocusNode _focusNode = FocusNode();  // 创建一个焦点节点以便监听键盘事件

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();  // 请求焦点以便能够接收键盘事件
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameModel>(context);  // 获取 GameModel 实例

    // 固定容器的大小
    double fixedContainerSize = 500.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('2048'),  // 应用程序的标题
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,  // 绑定焦点节点
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {  // 只处理按键按下事件
            switch (event.logicalKey.keyLabel) {  // 根据按键标签执行不同的移动操作
              case 'w':
              case 'Arrow Up':
                game.moveUp();  // 向上移动
                break;
              case 's':
              case 'Arrow Down':
                game.moveDown();  // 向下移动
                break;
              case 'a':
              case 'Arrow Left':
                game.moveLeft();  // 向左移动
                break;
              case 'd':
              case 'Arrow Right':
                game.moveRight();  // 向右移动
                break;
            }
          }
        },
        child: Center(
          child: Container(
            width: fixedContainerSize,
            height: fixedContainerSize,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 计算网格大小
                double gridSize = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth * 0.8
                    : constraints.maxHeight * 0.8;

                // 根据网格大小计算每个格子的大小
                double cellSize = (gridSize - 2 * 16 - (game.gridSize - 1) * 8) / game.gridSize;

                // 根据网格大小计算分数的字体大小
                double scoreFontSize = gridSize * 0.1;

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 显示分数
                      Text(
                        'Score: ${game.score}',
                        style: TextStyle(
                          fontSize: scoreFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      // 游戏网格
                      GestureDetector(
                        onVerticalDragEnd: (details) {
                          if (details.primaryVelocity != null) {
                            if (details.primaryVelocity! < 0) {
                              game.moveUp();
                            } else if (details.primaryVelocity! > 0) {
                              game.moveDown();
                            }
                          }
                        },
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity != null) {
                            if (details.primaryVelocity! < 0) {
                              game.moveLeft();
                            } else if (details.primaryVelocity! > 0) {
                              game.moveRight();
                            }
                          }
                        },
                        child: AspectRatio(
                          aspectRatio: 1,  // 保持长宽比为1：1
                          child: Container(
                            width: gridSize,
                            height: gridSize,
                            child: GridView.builder(
                              padding: EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: game.gridSize,  // 设置列数为网格大小
                                crossAxisSpacing: 8,  // 设置列间距
                                mainAxisSpacing: 8,  // 设置行间距
                              ),
                              itemCount: game.gridSize * game.gridSize,  // 设置网格项的总数
                              itemBuilder: (context, index) {
                                int value = game.grid[index ~/ game.gridSize][index % game.gridSize];  // 计算当前格子的值
                                return Container(
                                  width: cellSize,
                                  height: cellSize,
                                  decoration: BoxDecoration(
                                    color: value == 0 ? Colors.grey[300] : Colors.orange[100 * (value % 10)],  // 根据值设置颜色
                                    borderRadius: BorderRadius.circular(8),  // 设置圆角
                                  ),
                                  child: Center(
                                    child: Text(
                                      value == 0 ? '' : value.toString(),  // 显示值（如果值为 0 则显示为空）
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();  // 释放焦点节点资源
    super.dispose();
  }
}