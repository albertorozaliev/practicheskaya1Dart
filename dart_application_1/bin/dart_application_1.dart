// import 'package:dart_application_1/dart_application_1.dart' as dart_application_1;
// late int mylet;
// void main(List<String> arguments) {
//   final String b2;
//   print('Hello world: ${dart_application_1.calculate()}!');
//   int a = 5;
//   var b = 10.5;
//   var mylist = <int>[1,2,3,4];
//   List<int> mylist2 =[1,2,3];

//   var myrecord = (1,2.5,"qwef",true);

//   print(myrecord.$3);
//   var myset = {1,1,1,2,2,34,5};
//   print(myset);

//   var mymap = {1:"sd",2:"rfq"};
//   Map<String,String> mymap2 = {"1":"first"};

//   const int a2=123;
//   print(a2);
//   mylet = 22;
//   print(mylet);
//   mylet = 123;
//   print(mylet);

//   var a3 = 5;
//   var b3="22";
//   var resultString = a3.toString();
//   var resultDouble = double.tryParse(b3);
//   if (resultString is String){
//     print(true);
//   }
//   else{
//     print(false);
//   }
// }

// import 'dart:io';
//  void main(List<String> argements){
//   String? a = stdin.readLineSync();
//   String? b = stdin.readLineSync();
//   //даем возможность использовать пустую переменную
//    var el1 = int.parse(a!);
//    var el2 = int.parse(b!);

//    var summ = el1+el2;
//    print(summ);
//   dynamic test = true;
//   print(test);
//   test = [1,2,3,4,5];
//   print(test);
//   test = {1:"asas",2:"afgareg"};
//   print(test);

//   String? s = stdin.readLineSync();
//   String? d = stdin.readLineSync();
//   var el3 = int.parse(s!);
//   var el4 = int.parse(d!);
//   var del = el3 ~/ el4;
//   print(del);
//  }
import 'dart:io';
import 'dart:math';
void main (List<String> arguments){
    bool otvet = false;

    while(otvet==false){
      print("Добро пожаловать!");
        Game game = Game();
        game.as();
        print("Хотите продолжить? Нажмите '1', если хотите выйти");
            String? otv = stdin.readLineSync();
            var otv1 = int.parse(otv!);
        if (otv1==1){
          otvet=!otvet;
        }


    }
    
}
class Game{
  late int el; 
  late List<List<String>> stringMatrix; 
  var Flag = Random().nextBool();
  late List<List<int>> ravnoNumber=[];
  bool Win = false;
  bool vsRobot = false; 
  final _random = Random();
  void as() {
    print("Выберите режим:\n1 - Игра против друга\n2 - Игра против робота");
    final mode = stdin.readLineSync()!;
    vsRobot = (mode == "2");
    print("Напишите размеры поля");
    String? a = stdin.readLineSync();
    var el0 = int.parse(a!);
    el = el0 + 1;

    
    List<List<int>> matrix = List.generate(el, (i) => List.filled(el, 0));
    for (int i = 0; i < el; i++) {
      for (int j = 0; j < el; j++) {
        matrix[i][j] = i + j;
      }
    }

   
    stringMatrix = matrix.map(
      (row) => row.map((number) => number.toString()).toList(),
    ).toList();
    stringMatrix[0][0] = ' ';

    for (int i = 1; i < el; i++) {
      for (int j = 1; j < el; j++) {
        stringMatrix[i][j] = '.';
      }
    }
    displayStringMatrix();
    
    
    while (Win == false) {
      try {
        if (vsRobot && !Flag) {
        
          print("Ход робота: ");
          _robotMove();
          displayStringMatrix();
        } else {

          print("Сейчас ходит: ${Flag ? 'x' : '0'}");
          print("Номер строки и номер столбца:");
          String? line_num = stdin.readLineSync();
          String? column_num = stdin.readLineSync();
          var line_number = int.parse(line_num!);
          var column_number = int.parse(column_num!);
          placeSymbol(line_number, column_number);
          displayStringMatrix();
        }
      } catch (e) {
        print("Неверно");
      }
    }
  
}




  void placeSymbol(int line_number,int column_number){
      if (line_number < 0 || line_number >= el || column_number < 0 || column_number >= el) {
      print("Неверные координаты");
      return;
    }


    if (ravnoNumber.any((cell) => cell[0] == line_number && cell[1] == column_number)) {
      print("Ячейка занята");
      return;
    }

  
    ravnoNumber.add([line_number, column_number]);

    
    
  
    String symbol = Flag ? 'x' : '0';
    stringMatrix[line_number][column_number] = symbol;
    

    if (check(symbol)) {
      print("Победа $symbol");
      Win = true;
      
    }
    else if (ravnoNumber.length == (el - 1) * (el - 1)) {
      print("Ничья!");
      Win = true;
    }

    Flag = !Flag;
  }






  void displayStringMatrix() {
    for (int i = 0; i < el; i++) {
      String joinMatrix = stringMatrix[i].join(' ');
      print(joinMatrix);
    }
  }

void _robotMove() {
  int line, column;
  do {

    line = _random.nextInt(el - 1) + 1; 
    column = _random.nextInt(el - 1) + 1; 
  } while (ravnoNumber.any((cell) => cell[0] == line && cell[1] == column));
  
  placeSymbol(line, column);
}

  bool check(String symbol){

    for (int i = 1;i<el;i++){
      bool lineWin = true;
      for (int j = 1;j<el;j++){
        if (stringMatrix[i][j] != symbol){
          lineWin = false;
          break;
        }
      }
       if (lineWin) return true;
    }
    for (int j=1;j<el;j++){
      bool colWin = true;
      for (int i = 1; i<el;i++){
        if (stringMatrix[i][j] != symbol){
          colWin = false;
          break;
        }

      }
      if (colWin) return true;
    }

  bool DiagonalWin = true;
  for (int i = 1; i < el; i++) {
    if (stringMatrix[i][i] != symbol) {
      DiagonalWin = false;
      break;
    }
  }
  if (DiagonalWin) return true;

  bool antiDiagonalWin = true;
  for (int i = 1; i < el; i++) {
    if (stringMatrix[i][el  - i] != symbol) {
      antiDiagonalWin = false;
      break;
    }
  }
  if (antiDiagonalWin) return true;

  return false;
  }
}


    


