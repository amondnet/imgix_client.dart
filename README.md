# Imgix Dart Client

<!-- ix-docs-ignore -->
![imgix logo](https://assets.imgix.net/sdk-imgix-logo.svg)

A Dart client library for generating URLs with imgix.

[![pub](https://badgen.net/pub/v/imgix_client)](https://pub.dev/packages/imgix_client)
![Build](https://github.com/amondnet/imgix.dart/workflows/Build/badge.svg?branch=master)
[![codecov](https://codecov.io/gh/amondnet/imgix.dart/branch/master/graph/badge.svg)](https://codecov.io/gh/amondnet/imgix.dart)
[![License](https://img.shields.io/github/license/amondnet/imgix.dart)](https://github.com/amondnet/imgix.dart/blob/master/LICENSE)
[![HitCount](http://hits.dwyl.com/amondnet/imgix_client.svg)](http://hits.dwyl.com/amondnet/imgix_client)

---
- [Install](#install)
- [Basic Usage](#basic-usage)
- [Signed URLs](#signed-urls)
- [Srcset Generation](#srcset-generation)
- [Running Tests](#running-tests)
- [Features and bugs](#features-and-bugs)

## Install

```yaml
dependencies:
  imgix_client: ^1.0.0
```

## Basic Usage

A simple usage example:

```dart
import 'package:imgix_client/imgix_client.dart';

void main() {
  var urlBuilder = UrlBuilder('demos.imgix.net');
  var params = { 'w': '100', 'h': '100' };
  print('awesome: ${urlBuilder.createURL('bridge.png', params)}');
}

// Prints out:
// https://demos.imgix.net/bridge.png?h=100&w=100
```

HTTPS support is available by default. However, if you need HTTP support, call setUseHttps on the builder:

```dart
import 'package:imgix_client/imgix_client.dart';

void main() {
  var builder = UrlBuilder('demos.imgix.net');
  builder.useHttps = false; // use http

  var params = { 'w': '100', 'h': '100' };
  print(builder.createURL("bridge.png", params));
}


// Prints out
// http://demos.imgix.net/bridge.png?h=100&w=100
```

## Signed URLs

To produce a signed URL, you must enable secure URLs on your source and then
provide your signature key to the URL builder.

```dart
import 'package:imgix_client/imgix_client.dart';

void main() {
  var builder = UrlBuilder('demos.imgix.net');
  builder.useHttps = false; // use http
  builder.signKey = 'test1234'; // set sign key

  var params = { 'w': '100', 'h': '100' };
  print(builder.createURL("bridge.png", params));
}


// Prints out
// http://demos.imgix.net/bridge.png?h=100&w=100&s=bb8f3a2ab832e35997456823272103a4
```

## Srcset Generation

The imgix-java library allows for generation of custom `srcset` attributes, which can be invoked through `createSrcSet()`. By default, the `srcset` generated will allow for responsive size switching by building a list of image-width mappings.

```dart
import 'package:imgix_client/imgix_client.dart';

void main() {
  var ub = UrlBuilder('demos.imgix.net', true, 'my-token', false);
  var srcset = ub.createSrcSet("bridge.png");

  print(srcset);
}
```

Will produce the following attribute value, which can then be served to the client:

```html
https://demos.imgix.net/bridge.png?w=100&s=494158d968e94ac8e83772ada9a83ad1 100w,
https://demos.imgix.net/bridge.png?w=116&s=6a22236e189b6a9548b531330647ffa7 116w,
https://demos.imgix.net/bridge.png?w=134&s=cbf91f556dd67c0b9e26cb9784a83794 134w,
                                    ...
https://demos.imgix.net/bridge.png?w=7400&s=503e3ba04588f1c301863c9a5d84fe91 7400w,
https://demos.imgix.net/bridge.png?w=8192&s=152551ce4ec155f7a03f60f762a1ca33 8192w
```
In cases where enough information is provided about an image's dimensions, `createSrcSet()` will instead build a `srcset` that will allow for an image to be served at different resolutions. The parameters taken into consideration when determining if an image is fixed-width are `w` (width), `h` (height), and `ar` (aspect ratio). By invoking `createSrcSet()` with either a width **or** the height and aspect ratio (along with `fit=crop`, typically) provided, a different `srcset` will be generated for a fixed-size image instead.

```dart
import 'package:imgix_client/imgix_client.dart';

void main() {
  var ub = UrlBuilder('demos.imgix.net', true, 'my-token', false);
  var params = { 'h': '200', 'ar': '3:2', 'fit': 'crop' };
  var srcset = ub.createSrcSet("bridge.png", params);

  print(srcset);
}
```

Will produce the following attribute value:

```html
https://demos.imgix.net/bridge.png?ar=3%3A2&dpr=1&fit=crop&h=200&s=4c79373f535df7e2594a8f6622ec6631 1x,
https://demos.imgix.net/bridge.png?ar=3%3A2&dpr=2&fit=crop&h=200&s=dc818ae4522494f2f750651304a4d825 2x,
https://demos.imgix.net/bridge.png?ar=3%3A2&dpr=3&fit=crop&h=200&s=ba1ec0cef6c77ff02330d40cc4dae932 3x,
https://demos.imgix.net/bridge.png?ar=3%3A2&dpr=4&fit=crop&h=200&s=b51e497d9461be62354c0ea12b6524fb 4x,
https://demos.imgix.net/bridge.png?ar=3%3A2&dpr=5&fit=crop&h=200&s=dc37c1fbee505d425ca8e3764b37f791 5x
```

For more information to better understand `srcset`, we recommend [Eric Portis' "Srcset and sizes" article](https://ericportis.com/posts/2014/srcset-sizes/) which goes into depth about the subject.


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/amondnet/imgix.dart/issues


## Running Tests

To run tests clone this project and run:

```
pub run test
```
