import 'dart:convert';
import 'dart:math';
import 'package:executor/executor.dart';
import 'package:http/http.dart';
import 'dart:async';

// Challenge 1
// Flutter module makes multiple, parallel, requests to a web service, and
// shares the result with the host app. We'll use the "balldontlie" API for this
// purpose, since it's open and supports cross-domain requests for web apps. in
// this case, the input value represents the number of calls to be made, eg a
// value of 3 means we will fetch data for players 1, 2, 3. The URL for player 2,
// for example, is:
// https://www.balldontlie.io/api/v1/players/1
// Once all calls have been made, the Flutter module should calculate average
// weight of all queried players and print it in console.
//  The calls must occur in parallel, always using up to *four* separate threads,
// in a typical "worker" pattern, to ensure there are always three pending requests
// until no further requests are needed. The requests should be logged when initiated
// and again when completed.

// Challenge 2
// A point on the screen (pt1) wants to move a certain distance (dist) closer to
// another point on the screen (pt2) The function has three arguments,
// two of which are objects with x & y values, and the third being the distance,
// e.g. {x:50, y:60}, {x: 100, y: 100}, 10. The expected result is a similar
// object with the new co-ordinate.

Map coordinates(Map firstPoint, Map secondPoint, int distance){

  Map newCoords = {};
  double totalDistance = sqrt((secondPoint['x'] * secondPoint['x'] -
      firstPoint['x'] * firstPoint['x']) + (secondPoint['y'] * secondPoint['y'] -
      firstPoint['y'] * firstPoint['y']));
  double remainingDistance = totalDistance - distance;

  dynamic newXCoord = ((distance * secondPoint['x'] + remainingDistance * firstPoint['x']) / (distance+remainingDistance));
  dynamic newYCoord = ((distance * secondPoint['y'] + remainingDistance * firstPoint['y']) / (distance+remainingDistance));

  newCoords['x'] = double.parse(newXCoord.toStringAsFixed(2));
  newCoords['y'] = double.parse(newYCoord.toStringAsFixed(2));

  return newCoords;

}

Future<double> avgWeight(int n)async {
  List <int> weightOfPlayers = [];
  Executor executor = Executor(concurrency: 4);
  for(int i = 0; i < n; i++){
    executor.scheduleTask(() async{
      int currentPlayerWeight = await fetchPlayerWeight(i);
      if(currentPlayerWeight != null){
        weightOfPlayers.add(currentPlayerWeight);
      }
    });
  }
  await executor.join(withWaiting: true);
  return weightOfPlayers.reduce((a, b)=> a + b)/weightOfPlayers.length;
}

Future fetchPlayerWeight(int i) async {
  print('request ${i + 1} made');
  Response response =
  await get('https://www.balldontlie.io/api/v1/players/${i + 1}');
  Map map = jsonDecode(response.body);
  print('request ${i + 1} completed and average weight is ${map['weight_pounds']}');

  return map['weight_pounds'];
}

main() {

  print(coordinates({'x':50, 'y':60}, {'x': 100, 'y': 100}, 10));
  print(avgWeight(5));
}
