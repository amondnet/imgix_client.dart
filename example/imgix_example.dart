import 'package:imgix_client/imgix_client.dart';

void main() {
  var urlBuilder = UrlBuilder('example.imgix.net');
  print('awesome: ${urlBuilder.createURL('image/file.png')}');
}
