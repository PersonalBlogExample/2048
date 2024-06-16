import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // 导入 provider 包以便使用状态管理
import 'package:flutter/services.dart';  // 导入 services 包以便处理键盘事件
import 'game_model.dart';  // 导入之前定义的游戏模型

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameModel(4),  // 创建 GameModel 实例并提供给子树
      child: MaterialApp(
        title: '2048',
        theme: ThemeData(
          primarySwatch: Colors.blue,  // 设置主题颜色
        ),
        home: GamePage(),  // 设置主页为 GamePage
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

    // 固定容器的大小，这里设置为 300x300
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
                game.moveUp();
                break;
              case 's':
              case 'Arrow Down':
                game.moveDown();
                break;
              case 'a':
              case 'Arrow Left':
                game.moveLeft();
                break;
              case 'd':
              case 'Arrow Right':
                game.moveRight();
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
                          aspectRatio: 1,  // 保持 1:1 的长宽比
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
