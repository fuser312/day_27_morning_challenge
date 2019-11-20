import 'main.dart';
import 'package:test/test.dart';

void main(){
  test("Test Case 2", (){
    expect(coordinates({'x':50, 'y':60}, {'x': 100, 'y': 100}, 10), {'x': 54.24, 'y': 63.39});
  });
}