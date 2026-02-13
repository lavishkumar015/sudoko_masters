import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/sudoku_data.dart';

class SudokuGameScreen extends StatefulWidget {
  const SudokuGameScreen({super.key});

  @override
  State<SudokuGameScreen> createState() => _SudokuGameScreenState();
}

class _SudokuGameScreenState extends State<SudokuGameScreen> {
  late List<List<int>> board;
  int selectedRow = 0;
  int selectedCol = 0;

  Timer? timer;
  int seconds = 0;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    board = SudokuData.easy.map((e) => List<int>.from(e)).toList();
    seconds = 0;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
    selectedRow = 0;
    selectedCol = 0;
  }

  void handleKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    final key = event.logicalKey;

    // Number keys 1–9
    if (key.keyLabel.length == 1) {
      final num = int.tryParse(key.keyLabel);
      if (num != null && num >= 1 && num <= 9) {
        inputNumber(num);
        return;
      }
      if (num == 0) {
        clearCell();
        return;
      }
    }

    // Delete / Backspace
    if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      clearCell();
    }

    // Arrow keys
    if (key == LogicalKeyboardKey.arrowUp && selectedRow > 0) {
      setState(() => selectedRow--);
    }
    if (key == LogicalKeyboardKey.arrowDown && selectedRow < 8) {
      setState(() => selectedRow++);
    }
    if (key == LogicalKeyboardKey.arrowLeft && selectedCol > 0) {
      setState(() => selectedCol--);
    }
    if (key == LogicalKeyboardKey.arrowRight && selectedCol < 8) {
      setState(() => selectedCol++);
    }
  }

  void inputNumber(int num) {
    if (SudokuData.easy[selectedRow][selectedCol] != 0) return;

    setState(() {
      board[selectedRow][selectedCol] = num;
    });
  }

  void clearCell() {
    if (SudokuData.easy[selectedRow][selectedCol] != 0) return;

    setState(() {
      board[selectedRow][selectedCol] = 0;
    });
  }

  bool isWrong(int r, int c) {
    if (board[r][c] == 0) return false;
    return board[r][c] != SudokuData.solution[r][c];
  }

  String timeFormat() {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: handleKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sudoku ⏱ ${timeFormat()}"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: resetGame,
            )
          ],
          centerTitle: true,
        ),
        body: Column(
          children: [
            // GRID
            Expanded(
              flex: 7,
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 81,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9),
                  itemBuilder: (context, index) {
                    int r = index ~/ 9;
                    int c = index % 9;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRow = r;
                          selectedCol = c;
                          _focusNode.requestFocus();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedRow == r && selectedCol == c
                              ? Colors.blue.shade200
                              : Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: Text(
                            board[r][c] == 0 ? '' : board[r][c].toString(),
                            style: TextStyle(
                              fontSize: 18,
                              color: isWrong(r, c)
                                  ? Colors.red
                                  : Colors.black,
                              fontWeight: SudokuData.easy[r][c] != 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // NUMBER PAD (touch)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.count(
                  crossAxisCount: 5,
                  childAspectRatio: 1.5,
                  children: List.generate(9, (i) {
                    return ElevatedButton(
                      onPressed: () => inputNumber(i + 1),
                      child: Text("${i + 1}",
                          style: const TextStyle(fontSize: 18)),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }
}
