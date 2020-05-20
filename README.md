# Imgix Dart

<!-- ix-docs-ignore -->
![imgix logo](https://assets.imgix.net/sdk-imgix-logo.svg)

A Dart client library for generating URLs with imgix.

![Build](https://github.com/amondnet/imgix.dart/workflows/Build/badge.svg?branch=master)
[![codecov](https://codecov.io/gh/amondnet/imgix.dart/branch/master/graph/badge.svg)](https://codecov.io/gh/amondnet/imgix.dart)
[![License](https://img.shields.io/github/license/amondnet/imgix.dart)](https://github.com/amondnet/imgix.dart/blob/master/LICENSE)
## Usage

A simple usage example:

```dart
import 'package:imgix/imgix_client.dart';

void main() {
  var urlBuilder = UrlBuilder('example.imgix.net');
  print('awesome: ${urlBuilder.createURL('image/file.png')}');
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/amondnet/imgix.dart/issues
