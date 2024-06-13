import 'dart:math' as mt;

String generateMathQuestion(List<String> operations) {
  final mt.Random random = mt.Random();
  final int num1 = random.nextInt(10) + 1;
  final int num2 = random.nextInt(10) + 1;
  final String operation = operations[random.nextInt(operations.length)];

  return '$num1 $operation $num2';
}

int calculateAnswer(String question) {
  final List<String> parts = question.split(' ');
  final int num1 = int.parse(parts[0]);
  final String operation = parts[1];
  final int num2 = int.parse(parts[2]);

  switch (operation) {
    case '+':
      return num1 + num2;
    case '-':
      return num1 - num2;
    case '*':
      return num1 * num2;
    default:
      throw Exception('Invalid operation');
  }
}
