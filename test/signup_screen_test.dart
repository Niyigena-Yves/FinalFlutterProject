import 'package:alu_connect/screens/auth/signup_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts only ALU-approved email domains', () {
    expect(isValidAluEmail('student@alustudent.com'), isTrue);
    expect(isValidAluEmail('student@alueducation.com'), isTrue);
    expect(isValidAluEmail('student@gmail.com'), isFalse);
    expect(isValidAluEmail('student@alu.com'), isFalse);
    expect(isValidAluEmail('not-an-email'), isFalse);
  });
}
