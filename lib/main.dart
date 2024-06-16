import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 导入 provider 包以便使用状态管理
import 'package:flutter/services.dart'; // 导入 services 包以便处理键盘事件
import 'game_model.dart'; // 导入之前定义的游戏模型
import 'leaderboard.dart'; // 导入排行榜页面

int highestScore = 0;
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
      home: HomePage(), // 初始页面设置为 HomePage
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('2048主页'),
        centerTitle: true, // 将标题居中
      ),
      body: WillPopScope(
        onWillPop: () async {
          setState(() {
            // 根据需要在返回时刷新一些状态, 例如从数据库加载数据等
          });
          return true;
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '用户名: Player',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '历史最高分: ${highestScore}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 200, // 按钮的宽度
                height: 60, // 按钮的高度
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  child: const Text('4x4'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return ChangeNotifierProvider(
                          create: (context) => GameModel(4),
                          child: GamePage(),
                        );
                      }),
                    ).then((_) {
                      setState(() {}); // 刷新主界面
                    });
                  },
                ),
              ),
              const SizedBox(height: 20), // 按钮之间的间距
              // 5x5 按钮
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  child: const Text('5x5'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return ChangeNotifierProvider(
                          create: (context) => GameModel(5),
                          child: GamePage(),
                        );
                      }),
                    ).then((_) {
                      setState(() {}); // 刷新主界面
                    });
                  },
                ),
              ),
              const SizedBox(height: 20), // 按钮之间的间距
              // 排行榜按钮
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  child: const Text('排行榜'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LeaderboardPage()),
                    ).then((_) {
                      setState(() {}); // 刷新主界面
                    });
                  },
                ),
              ),
            ],
          ),
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
  final FocusNode _focusNode = FocusNode(); // 创建一个焦点节点以便监听键盘事件
  final Set<LogicalKeyboardKey> _keysPressed =
      Set<LogicalKeyboardKey>(); // 追踪按下的键

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus(); // 请求焦点以便能够接收键盘事件
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameModel>(context); // 获取 GameModel 实例

    // 固定容器的大小
    double fixedContainerSize;
    int size = game.gridSize;
    // 显示游戏结束对话框
    void _showGameOverDialog(BuildContext context, int score) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("游戏结束"),
            content: Text("你的分数: ${score}"),
            actions: [
              TextButton(
                child: Text("重新开始"),
                onPressed: () {
                  Navigator.of(context).pop();
                  game.reset();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('2048-${size}x${size}'), // 应用程序的标题
          centerTitle: true,
        ),
        body: RawKeyboardListener(
          focusNode: _focusNode, // 绑定焦点节点
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              if (!_keysPressed.contains(event.logicalKey)) {
                _keysPressed.add(event.logicalKey);
                switch (event.logicalKey.keyLabel) {
                  // 根据按键标签执行不同的移动操作
                  case 'w':
                  case 'Arrow Up':
                    game.moveUp(); // 向上移动
                    break;
                  case 's':
                  case 'Arrow Down':
                    game.moveDown(); // 向下移动
                    break;
                  case 'a':
                  case 'Arrow Left':
                    game.moveLeft(); // 向左移动
                    break;
                  case 'd':
                  case 'Arrow Right':
                    game.moveRight(); // 向右移动
                    break;
                }
                if (game.score > highestScore) {
                  highestScore = game.score;
                }
                if (game.checkGameOver()) {
                  _showGameOverDialog(context, game.score);
                }
              }
            } else if (event is RawKeyUpEvent) {
              _keysPressed.remove(event.logicalKey); // 删除已释放的键
            }
          },
          child: LayoutBuilder(builder: (context, constraints) {
            fixedContainerSize = constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth * 0.8
                : constraints.maxHeight * 0.8;
            return Center(
              child: Container(
                width: fixedContainerSize,
                height: fixedContainerSize * 1.2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 计算网格大小
                    double gridSize =
                        constraints.maxWidth < constraints.maxHeight
                            ? constraints.maxWidth * 0.8
                            : constraints.maxHeight * 0.8;

                    // 根据网格大小计算每个格子的大小
                    double cellSize =
                        (gridSize - 2 * 16 - (game.gridSize - 1) * 8) /
                            game.gridSize;

                    // 根据网格大小计算分数的字体大小
                    double scoreFontSize = gridSize * 0.05;

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '分数: ${game.score}',
                                style: TextStyle(
                                  fontSize: scoreFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: gridSize * 0.5, // 按钮的宽度
                                height: gridSize * 0.1, // 按钮的高度
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    textStyle: const TextStyle(fontSize: 24),
                                  ),
                                  child: const Text('新游戏'),
                                  onPressed: () {
                                    game.reset();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // 游戏网格
                          GestureDetector(
                            // 手势动作
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
                              aspectRatio: 1, // 保持长宽比为1：1
                              child: SizedBox(
                                width: gridSize,
                                height: gridSize,
                                child: GridView.builder(
                                  padding: EdgeInsets.all(16),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: game.gridSize, // 设置列数为网格大小
                                    crossAxisSpacing: 8, // 设置列间距
                                    mainAxisSpacing: 8, // 设置行间距
                                  ),
                                  itemCount:
                                      game.gridSize * game.gridSize, // 设置网格项的总数
                                  itemBuilder: (context, index) {
                                    int value =
                                        game.grid[index ~/ game.gridSize]
                                            [index % game.gridSize]; // 计算当前格子的值
                                    return Container(
                                      width: cellSize,
                                      height: cellSize,
                                      decoration: BoxDecoration(
                                        color: value == 0
                                            ? Colors.grey[300]
                                            : Colors.orange[
                                                100 * (value % 10)], // 根据值设置颜色
                                        borderRadius:
                                            BorderRadius.circular(8), // 设置圆角
                                      ),
                                      child: Center(
                                        child: Text(
                                          value == 0
                                              ? ''
                                              : value
                                                  .toString(), // 显示值（如果值为 0 则显示为空）
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
            );
          }),
        ));
  }

  @override
  void dispose() {
    _focusNode.dispose(); // 释放焦点节点资源
    super.dispose();
  }
}
