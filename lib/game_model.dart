import 'dart:math';  // 导入 Dart 的数学库以便使用随机数生成器
import 'package:flutter/material.dart';  // 导入 Flutter 的核心包
import 'package:collection/collection.dart';  // 导入 collection 包用于列表内容的相等性比较

// ChangeNotifier 用于通知监听器（如 UI）更新数据的游戏模型类
class GameModel with ChangeNotifier {
  int gridSize = 4;  // 定义网格尺寸为 4 行 4 列
  List<List<int>> _grid = [[]];  // 用于存储网格数据的内部二维列表
  int _score = 0;  // 用于存储游戏得分的内部变量
  final ListEquality _equality = const ListEquality();  // 用于列表内容的相等性比较

  // 构造函数：初始化网格并添加两个初始方块
  GameModel(int size) {
    gridSize = size;
    _grid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => 0));  // 将网格初始化为全 0
    _addNewTile();  // 添加第一个新方块
    _addNewTile();  // 添加第二个新方块
  }

  // 获取当前网格的公共方法
  List<List<int>> get grid => _grid;
  // 获取当前分数的公共方法
  int get score => _score;

  // 在随机空白位置添加一个新的方块（2 或 4）的私有方法
  void _addNewTile() {
    List<int> emptyTiles = [];  // 用于存储所有空白位置的列表
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (_grid[i][j] == 0) {
          emptyTiles.add(i * gridSize + j);  // 将空白位置的索引存值在列表中
        }
      }
    }

    if (emptyTiles.isNotEmpty) {  // 如果有空白位置
      int index = emptyTiles[Random().nextInt(emptyTiles.length)];  // 随机选择一个空白位置索引
      _grid[index ~/ gridSize][index % gridSize] = Random().nextInt(10) == 0 ? 4 : 2;  // 在该位置插入 2 或 4（10% 概率为 4）
    }
  }


  // 私有方法：将网格向左旋转 90 度
  void _rotateLeft() {
    List<List<int>> newGrid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => 0));  // 创建一个新的空网格
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        newGrid[gridSize - j - 1][i] = _grid[i][j];  // 填充旋转后的新网格
      }
    }
    _grid = newGrid;  // 更新网格
  }

  // 私有方法：将网格向右旋转 90 度
  void _rotateRight() {
    List<List<int>> newGrid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => 0));  // 创建一个新的空网格
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        newGrid[j][gridSize - i - 1] = _grid[i][j];  // 填充旋转后的新网格
      }
    }
    _grid = newGrid;  // 更新网格
  }

  // 将网格的所有行向左滑动的私有方法
  bool _slideLeft() {
    bool moved = false;  // 用于标记是否有方块移动
    for (int i = 0; i < gridSize; i++) {
      List<int> newRow = List.generate(gridSize, (j) => 0);  // 创建一个新的空行
      int targetIndex = 0;  // 用于记录目标位置索引
      for (int j = 0; j < gridSize; j++) {
        if (_grid[i][j] != 0) {  // 如果当前格子不为空
          if (newRow[targetIndex] == 0) {  // 如果目标位置为空
            newRow[targetIndex] = _grid[i][j];  // 将当前方块移动到目标位置
          } else if (newRow[targetIndex] == _grid[i][j]) {  // 如果目标位置的方块与当前方块相同
            newRow[targetIndex] *= 2;  // 合并方块
            _score += newRow[targetIndex];  // 更新分数
            targetIndex++;  // 目标位置后移
          } else {  // 如果目标位置的方块与当前方块不同
            targetIndex++;  // 目标位置后移
            newRow[targetIndex] = _grid[i][j];  // 将当前方块移动到新的目标位置
          }
        }
      }
      if (!moved && !_equality.equals(newRow, _grid[i])) {  // 使用 ListEquality 比较行内容是否改变
        moved = true;  // 标记为有移动
      }
      _grid[i] = newRow;  // 更新当前行
    }
    return moved;  // 返回是否有方块移动
  }

  // 公共方法：处理向左移动
  void moveLeft() {
    if (_slideLeft()) {  // 如果有方块移动
      _addNewTile();  // 添加一个新的方块
      notifyListeners();  // 通知监听器数据发生变化
    }
  }

  // 公共方法：处理向右移动
  void moveRight() {
    _rotateLeft();  // 向左旋转两次相当于向右旋转
    _rotateLeft();
    if (_slideLeft()) {  // 如果有方块移动
      _addNewTile();  // 添加一个新的方块
      notifyListeners();  // 通知监听器数据发生变化
    }
    _rotateRight();  // 将网格旋转回来
    _rotateRight();
  }

  // 公共方法：处理向下移动
  void moveDown() {
    _rotateRight();  // 向右旋转一次
    if (_slideLeft()) {  // 如果有方块移动
      _addNewTile();  // 添加一个新的方块
      notifyListeners();  // 通知监听器数据发生变化
    }
    _rotateLeft();  // 将网格旋转回来
  }

  // 公共方法：处理向上移动
  void moveUp() {
    _rotateLeft();  // 向左旋转一次
    if (_slideLeft()) {  // 如果有方块移动
      _addNewTile();  // 添加一个新的方块
      notifyListeners();  // 通知监听器数据发生变化
    }
    _rotateRight();  // 将网格旋转回来
  }
}