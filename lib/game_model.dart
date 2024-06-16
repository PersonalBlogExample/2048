import 'dart:math';  // 导入 Dart 的数学库以便使用随机数生成器
import 'package:flutter/material.dart';  // 导入 Flutter 的核心包

// 游戏模型类，使用 ChangeNotifier 来通知监听器（如 UI）数据变化
class GameModel with ChangeNotifier {
  int gridSize = 4;
  List<List<int>> _grid = [[]];  // 内部存储网格的二维列表
  int _score = 0;  // 内部存储分数

  // 构造函数，初始化网格和添加两个新的方块
  GameModel(int size) {
    gridSize = size;
    _grid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => 0));  // 初始化网格为全 0
    _addNewTile();  // 添加第一个新的方块
    _addNewTile();  // 添加第二个新的方块
  }

  // 公共 getter 方法，获取当前网格
  List<List<int>> get grid => _grid;
  // 公共 getter 方法，获取当前分数
  int get score => _score;

  // 私有方法，在随机空白位置添加一个新的方块（2 或 4）
  void _addNewTile() {
    List<int> emptyTiles = [];  // 用于存储所有空白位置的列表
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (_grid[i][j] == 0) {
          emptyTiles.add(i * gridSize + j);  // 将空白位置的索引加入列表
        }
      }
    }

    if (emptyTiles.isNotEmpty) {  // 如果有空白位置
      int index = emptyTiles[Random().nextInt(emptyTiles.length)];  // 随机选择一个空白位置
      _grid[index ~/ gridSize][index % gridSize] = Random().nextInt(10) == 0 ? 4 : 2;  // 在该位置放置 2 或 4（10% 概率为 4）
    }
  }

  // 私有方法，将网格向左旋转 90 度
  void _rotateLeft() {
    List<List<int>> newGrid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => 0));  // 创建一个新的空白网格
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        newGrid[gridSize - j - 1][i] = _grid[i][j];  // 将原网格旋转后填入新网格
      }
    }
    _grid = newGrid;  // 更新网格
  }

  // 私有方法，将网格向右旋转 90 度
  void _rotateRight() {
    List<List<int>> newGrid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => 0));  // 创建一个新的空白网格
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        newGrid[j][gridSize - i - 1] = _grid[i][j];  // 将原网格旋转后填入新网格
      }
    }
    _grid = newGrid;  // 更新网格
  }

  // 私有方法，将网格的所有行向左滑动
  bool _slideLeft() {
    bool moved = false;  // 标记是否有方块移动
    for (int i = 0; i < gridSize; i++) {
      List<int> newRow = List.generate(gridSize, (j) => 0);  // 创建一个新的空行
      int targetIndex = 0;  // 用于记录合并或移动后的目标位置
      for (int j = 0; j < gridSize; j++) {
        if (_grid[i][j] != 0) {  // 如果当前格子不为空
          if (newRow[targetIndex] == 0) {  // 如果目标位置为空
            newRow[targetIndex] = _grid[i][j];  // 移动当前方块到目标位置
          } else if (newRow[targetIndex] == _grid[i][j]) {  // 如果目标位置的方块与当前方块相同
            newRow[targetIndex] *= 2;  // 合并方块
            _score += newRow[targetIndex];  // 更新分数
            targetIndex++;  // 移动目标位置到下一个
          } else {  // 如果目标位置的方块与当前方块不同
            targetIndex++;  // 移动目标位置到下一个
            newRow[targetIndex] = _grid[i][j];  // 移动当前方块到新的目标位置
          }
        }
      }
      if (!moved && newRow != _grid[i]) {  // 如果有任何一行发生了变化
        moved = true;  // 标记为有移动
      }
      _grid[i] = newRow;  // 更新当前行
    }
    return moved;  // 返回是否有方块移动
  }

  // 公共方法，处理向左移动
  void moveLeft() {
    if (_slideLeft()) {  // 如果有方块移动
      _addNewTile();  // 添加一个新的方块
      notifyListeners();  // 通知监听器数据变化
    }
  }

  // 公共方法，处理向右移动
  void moveRight() {
    _rotateLeft();  // 向左旋转两次相当于向右旋转
    _rotateLeft();
    if (_slideLeft()) {  // 如果有方块移动
      _addNewTile();  // 添加一个新的方块
      notifyListeners();  // 通知监听器数据变化
    }
    _rotateRight();  // 旋转回来
    _rotateRight();
  }

  // 公共方法，处理向下移动
  void moveDown() {
    _rotateRight();  // 向右旋转一次
    if (_slideLeft()) {  // 如果有方块移动
      _addNewTile();  // 添加一个新的方块
      notifyListeners();  // 通知监听器数据变化
    }
    _rotateLeft();  // 旋转回来
  }

  // 公共方法，处理向上移动
  void moveUp() {
    _rotateLeft();  // 向左旋转一次
    if (_slideLeft()) {  // 如果有方块移动
      _addNewTile();  // 添加一个新的方块
      notifyListeners();  // 通知监听器数据变化
    }
    _rotateRight();  // 旋转回来
  }
}
