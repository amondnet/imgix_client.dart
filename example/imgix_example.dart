import 'package:imgix/imgix.dart';

void main() {
  var urlBuilder = UrlBuilder('example.imgix.net');
  print('awesome: ${urlBuilder.createURL('image/file.png')}');
}
