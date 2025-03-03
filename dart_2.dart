import 'dart:io';
import 'dart:math';

void main() {
  Game game = Game();
  game.start();
}

class Game {
  final int size = 10;
  late List<List<String>> player1Board;
  late List<List<String>> player2Board;
  late List<List<bool>> player1Ships;
  late List<List<bool>> player2Ships;
  late List<List<String>> player1AttackBoard;
  late List<List<String>> player2AttackBoard;
  int player1ShipsCount = 10;
  int player2ShipsCount = 10;
  Random random = Random();
  bool isAgainstFriend = false;

  Game() {
    _initializeBoards();
    print("Выберите режим игры: 1 - против робота, 2 - против друга");
    int mode = _getIntInput(1, 2);
    isAgainstFriend = mode == 2;

    print("Игрок 1, хотите расставить корабли вручную (1) или автоматически (2)?");
    int player1Choice = _getIntInput(1, 2);
    if (player1Choice == 1) {
      _placePlayerShips(player1Board, player1Ships, "Игрок 1");
    } else {
      _autoPlaceShips(player1Board, player1Ships, "Игрок 1");
    }

    if (isAgainstFriend) {
      print("Игрок 2, хотите расставить корабли вручную (1) или автоматически (2)?");
      int player2Choice = _getIntInput(1, 2);
      if (player2Choice == 1) {
        _placePlayerShips(player2Board, player2Ships, "Игрок 2");
      } else {
        _autoPlaceShips(player2Board, player2Ships, "Игрок 2");
      }
    } else {
      _autoPlaceShips(player2Board, player2Ships, "Робот");
    }
  }

  void _initializeBoards() {
    player1Board = List.generate(size, (_) => List.filled(size, '.'));
    player2Board = List.generate(size, (_) => List.filled(size, '.'));
    player1Ships = List.generate(size, (_) => List.filled(size, false));
    player2Ships = List.generate(size, (_) => List.filled(size, false));
    player1AttackBoard = List.generate(size, (_) => List.filled(size, '.'));
    player2AttackBoard = List.generate(size, (_) => List.filled(size, '.'));
  }

  bool _canPlaceShip(List<List<bool>> board, int x, int y, int length, bool horizontal) {
    for (int i = 0; i < length; i++) {
      int newX = horizontal ? x : x + i;
      int newY = horizontal ? y + i : y;
      if (newX >= size || newY >= size || board[newX][newY]) return false;
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          int checkX = newX + dx;
          int checkY = newY + dy;
          if (checkX >= 0 && checkX < size && checkY >= 0 && checkY < size && board[checkX][checkY]) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void _placeShip(List<List<bool>> board, List<List<String>> visualBoard, int x, int y, int length, bool horizontal) {
    for (int i = 0; i < length; i++) {
      int newX = horizontal ? x : x + i;
      int newY = horizontal ? y + i : y;
      board[newX][newY] = true;
      visualBoard[newX][newY] = 'S';
    }
  }

  void _placePlayerShips(List<List<String>> board, List<List<bool>> ships, String playerName) {
    List<int> shipSizes = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1];
    print("$playerName, расставьте свои корабли:");
    for (int length in shipSizes) {
      print("Разместите корабль длиной $length");
      bool placed = false;
      while (!placed) {
        try {
          print("Введите номер столбца (0-9):");
          int y = _getIntInput(0, size - 1);
          print("Введите номер строки (0-9):");
          int x = _getIntInput(0, size - 1);
          print("Горизонтальное (1) или вертикальное (0) расположение корабля:");
          bool horizontal = _getIntInput(0, 1) == 1;
          if (_canPlaceShip(ships, x, y, length, horizontal)) {
            _placeShip(ships, board, x, y, length, horizontal);
            placed = true;
            _printBoard(board);
          } else {
            print("Нельзя разместить корабль здесь!");
          }
        } catch (e) {
          print("Ошибка ввода. Пожалуйста, введите корректные данные.");
        }
      }
    }
  }

  void _autoPlaceShips(List<List<String>> board, List<List<bool>> ships, String playerName) {
    List<int> shipSizes = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1];
    print("$playerName, корабли расставляются автоматически...");
    for (int length in shipSizes) {
      bool placed = false;
      while (!placed) {
        int x = random.nextInt(size);
        int y = random.nextInt(size);
        bool horizontal = random.nextBool();
        if (_canPlaceShip(ships, x, y, length, horizontal)) {
          _placeShip(ships, board, x, y, length, horizontal);
          placed = true;
        }
      }
    }
    print("Корабли $playerName расставлены:");
    _printBoard(board);
  }

  void start() {
    print("Добро пожаловать в Морской Бой!");
    bool player1Turn = true;
    while (player1ShipsCount > 0 && player2ShipsCount > 0) {
      if (player1Turn) {
        _printBoards(player1Board, player1AttackBoard, "Игрок 1");
        bool hit = _playerTurn(player2Board, player2Ships, player1AttackBoard, "Игрок 1", () => player2ShipsCount--);
        if (!hit) player1Turn = !player1Turn; 
      } else {
        if (isAgainstFriend) {
          _printBoards(player2Board, player2AttackBoard, "Игрок 2");
          bool hit = _playerTurn(player1Board, player1Ships, player2AttackBoard, "Игрок 2", () => player1ShipsCount--);
          if (!hit) player1Turn = !player1Turn; 
        } else {
          bool hit = _enemyTurn();
          if (!hit) player1Turn = !player1Turn; 
        }
      }
    }
    print(player1ShipsCount == 0 ? "Игрок 2 победил!" : "Игрок 1 победил!");
  }

  bool _playerTurn(List<List<String>> enemyBoard, List<List<bool>> enemyShips, List<List<String>> attackBoard, String playerName, Function onHit) {
    while (true) {
      try {
        print("$playerName, ваш ход! Введите координаты для атаки (x y):");
        int x = _getIntInput(0, size - 1);
        int y = _getIntInput(0, size - 1);
        if (attackBoard[x][y] != '.') {
          print("Вы уже стреляли в эту клетку. Попробуйте снова.");
          continue;
        }
        bool hit = _shoot(enemyBoard, enemyShips, attackBoard, x, y, onHit);
        return hit;
      } catch (e) {
        print("Ошибка ввода. Пожалуйста, введите корректные координаты.");
      }
    }
  }

  bool _enemyTurn() {
    print("Ход противника...");
    int x, y;
    do {
      x = random.nextInt(size);
      y = random.nextInt(size);
    } while (player1Board[x][y] != '.');
    return _shoot(player1Board, player1Ships, player2AttackBoard, x, y, () => player1ShipsCount--);
  }

  bool _shoot(List<List<String>> board, List<List<bool>> ships, List<List<String>> attackBoard, int x, int y, Function onHit) {
    if (ships[x][y]) {
      print("Попадание!");
      board[x][y] = 'X';
      attackBoard[x][y] = 'X';
      ships[x][y] = false;
      onHit();
      return true; 
    } else {
      print("Промах!");
      board[x][y] = 'O';
      attackBoard[x][y] = 'O';
      return false; 
    }
  }

  void _printBoards(List<List<String>> playerBoard, List<List<String>> attackBoard, String playerName) {
    print("$playerName, ваше поле:");
    _printBoard(playerBoard);
    print("$playerName, поле для атаки:");
    _printBoard(attackBoard, hideShips: true);
  }

  void _printBoard(List<List<String>> board, {bool hideShips = false}) {
    print("  " + List.generate(size, (i) => i.toString()).join(' '));
    for (int i = 0; i < size; i++) {
      print("$i " + board[i].map((cell) => hideShips && cell == 'S' ? '.' : cell).join(' '));
    }
  }

  int _getIntInput(int min, int max) {
    while (true) {
      try {
        int input = int.parse(stdin.readLineSync()!);
        if (input >= min && input <= max) {
          return input;
        } else {
          print("Введите число от $min до $max.");
        }
      } catch (e) {
        print("Ошибка ввода. Пожалуйста, введите число.");
      }
    }
  }
}