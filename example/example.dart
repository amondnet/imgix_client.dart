import 'package:imgix_client/imgix_client.dart';

void main() {
  var builder = UrlBuilder('demos.imgix.net');

  var params = {'w': '100', 'h': '100'};
  print(builder.createURL("bridge.png", params));
}

// Prints out
// http://demos.imgix.net/bridge.png?h=100&w=100
