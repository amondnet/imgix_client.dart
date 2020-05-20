import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:imgix/imgix.dart';
import 'package:test/test.dart';

void main() {
  group('srcSet', () {
    Map<String, String> params;
    var srcsetSplit;
    var srcsetWidthSplit;
    var srcsetHeightSplit;
    var srcsetAspectRatioSplit;
    var srcsetWidthAndHeightSplit;
    var srcsetWidthAndAspectRatioSplit;
    var srcsetHeightAndAspectRatioSplit;
    setUp(() {
      String srcset,
          srcsetWidth,
          srcsetHeight,
          srcsetAspectRatio,
          srcsetWidthAndHeight,
          srcsetWidthAndAspectRatio,
          srcsetHeightAndAspectRatio;

      var ub = UrlBuilder('test.imgix.net', true, 'MYT0KEN', false);
      params = HashMap<String, String>();

      srcset = ub.createSrcSet('image.jpg');
      srcsetSplit = srcset.split(',');

      params['w'] = '300';
      srcsetWidth = ub.createSrcSet('image.jpg', params: params);
      srcsetWidthSplit = srcsetWidth.split(',');
      params.clear();

      params['h'] = '300';
      srcsetHeight = ub.createSrcSet('image.jpg', params: params);
      srcsetHeightSplit = srcsetHeight.split(',');
      params.clear();

      params['ar'] = '3:2';
      srcsetAspectRatio = ub.createSrcSet('image.jpg', params: params);
      srcsetAspectRatioSplit = srcsetAspectRatio.split(',');
      params.clear();

      params['w'] = '300';
      params['h'] = '300';
      srcsetWidthAndHeight = ub.createSrcSet('image.jpg', params: params);
      srcsetWidthAndHeightSplit = srcsetWidthAndHeight.split(',');
      params.clear();

      params['w'] = '300';
      params['ar'] = '3:2';
      srcsetWidthAndAspectRatio = ub.createSrcSet('image.jpg', params: params);
      srcsetWidthAndAspectRatioSplit = srcsetWidthAndAspectRatio.split(',');
      params.clear();

      params['h'] = '300';
      params['ar'] = '3:2';
      srcsetHeightAndAspectRatio = ub.createSrcSet('image.jpg', params: params);
      srcsetHeightAndAspectRatioSplit = srcsetHeightAndAspectRatio.split(',');
      params.clear();
    });

    test('testNoParametersGeneratesCorrectWidths', () {
      var targetWidths = [
        100,
        116,
        135,
        156,
        181,
        210,
        244,
        283,
        328,
        380,
        441,
        512,
        594,
        689,
        799,
        927,
        1075,
        1247,
        1446,
        1678,
        1946,
        2257,
        2619,
        3038,
        3524,
        4087,
        4741,
        5500,
        6380,
        7401,
        8192
      ];

      String generatedWidth;
      var index = 0;
      int widthInt;

      for (var src in srcsetSplit) {
        generatedWidth = src.split(' ')[1];
        widthInt =
            int.parse(generatedWidth.substring(0, generatedWidth.length - 1));
        expect(widthInt, targetWidths[index]);
        index++;
      }
    });

    test('testNoParametersReturnsExpectedNumberOfPairs', () {
      var expectedPairs = 31;
      expect(srcsetSplit.length, expectedPairs);
    });

    test('testNoParametersDoesNotExceedBounds', () {
      String minWidth = srcsetSplit[0].split(' ')[1];
      String maxWidth = srcsetSplit[srcsetSplit.length - 1].split(' ')[1];

      var minWidthInt = int.parse(minWidth.substring(0, minWidth.length - 1));
      var maxWidthInt = int.parse(maxWidth.substring(0, maxWidth.length - 1));

      expect(minWidthInt, greaterThanOrEqualTo(100));
      expect(maxWidthInt, lessThanOrEqualTo(8192));
    });

    /// a 17% testing threshold is used to account for rounding
    test('testNoParametersDoesNotIncreaseMoreThan17Percent', () {
      final INCREMENT_ALLOWED = .17;
      String width;
      int widthInt, prev;

      // convert and store first width (typically: 100)
      width = srcsetSplit[0].split(' ')[1];
      prev = int.parse(width.substring(0, width.length - 1));

      for (var src in srcsetSplit) {
        width = src.split(' ')[1];
        widthInt = int.parse(width.substring(0, width.length - 1));

        assert((widthInt / prev) < (1 + INCREMENT_ALLOWED));
        prev = widthInt;
      }
    });

    test('testNoParametersSignsUrls', () {
      String src,
          parameters,
          generatedSignature,
          expectedSignature = '',
          signatureBase;

      for (String srcLine in srcsetSplit) {
        src = srcLine.split(' ')[0];
        assert(src.contains('s='));
        generatedSignature = src.substring(src.indexOf('s=') + 2);

        parameters = src.substring(src.indexOf('?'), src.indexOf('s=') - 1);
        signatureBase = 'MYT0KEN/image.jpg' + parameters;

        expectedSignature = md5Hex(signatureBase);

        expect(generatedSignature, expectedSignature);
      }
    });

    test('testWidthInDPRForm', () {
      String generatedRatio;
      var expectedRatio = 1;
      assert(srcsetWidthSplit.length == 5);

      for (String src in srcsetWidthSplit) {
        generatedRatio = src.split(' ')[1];
        expect(generatedRatio, '${expectedRatio}x');
        expectedRatio++;
      }
    });

    test('testMd5 1', () {
      var sign = 'FOO123bar/users/1.png';

      var signature = UrlHelper.MD5(sign);
      expect(signature, '6797c24146142d5b40bde3141fd3600c');
    });

    test('testMd5 2', () {
      var sign = 'FOO123bar/http%3A%2F%2Favatars.com%2Fjohn-smith.png';

      var signature = UrlHelper.MD5(sign);
      expect(signature, '493a52f008c91416351f8b33d4883135');
    });

    test('testWidthSignsUrls', () {
      String src,
          parameters,
          generatedSignature,
          expectedSignature = '',
          signatureBase;

      for (String srcLine in srcsetWidthSplit) {
        src = srcLine.split(' ')[0];
        assert(src.contains('s='));
        generatedSignature = src.substring(src.indexOf('s=') + 2);

        parameters = src.substring(src.indexOf('?'), src.indexOf('s=') - 1);
        signatureBase = 'MYT0KEN/image.jpg' + parameters;
        expectedSignature = md5Hex(signatureBase);
        expect(generatedSignature, expectedSignature);
      }
    });

    test('testWidthIncludesDPRParam', () {
      String src;

      for (var i = 0; i < srcsetWidthSplit.length; i++) {
        src = srcsetWidthSplit[i].split(' ')[0];
        assert(src.contains('dpr=${i + 1}'));
      }
    });
    test('testWidthSignsUrls', () {
      var targetWidths = [
        100,
        116,
        135,
        156,
        181,
        210,
        244,
        283,
        328,
        380,
        441,
        512,
        594,
        689,
        799,
        927,
        1075,
        1247,
        1446,
        1678,
        1946,
        2257,
        2619,
        3038,
        3524,
        4087,
        4741,
        5500,
        6380,
        7401,
        8192
      ];

      String generatedWidth;
      var index = 0;
      int widthInt;

      for (String src in srcsetHeightSplit) {
        generatedWidth = src.split(' ')[1];
        widthInt =
            int.parse(generatedWidth.substring(0, generatedWidth.length - 1));
        expect(widthInt, targetWidths[index]);
        index++;
      }
    });
    test('testHeightContainsHeightParameter', () {
      String url;

      for (String src in srcsetHeightSplit) {
        url = src.split(' ')[0];
        expect(url.contains('h='), isTrue);
      }
    });
    test('testHeightReturnsExpectedNumberOfPairs', () {
      var expectedPairs = 31;
      expect(srcsetHeightSplit.length, expectedPairs);
    });
    test('testHeightDoesNotExceedBounds', () {
      String minWidth = srcsetHeightSplit[0].split(' ')[1];
      String maxWidth =
          srcsetHeightSplit[srcsetHeightSplit.length - 1].split(' ')[1];

      var minWidthInt = int.parse(minWidth.substring(0, minWidth.length - 1));
      var maxWidthInt = int.parse(maxWidth.substring(0, maxWidth.length - 1));

      assert(minWidthInt >= 100);
      assert(maxWidthInt <= 8192);
    });
    test('testHeightDoesNotIncreaseMoreThan17Percent', () {
      final INCREMENT_ALLOWED = .17;
      String width;
      int widthInt, prev;

      // convert and store first width (typically: 100)
      width = srcsetHeightSplit[0].split(' ')[1];
      prev = int.parse(width.substring(0, width.length - 1));

      for (String src in srcsetHeightSplit) {
        width = src.split(' ')[1];
        widthInt = int.parse(width.substring(0, width.length - 1));

        assert((widthInt / prev) < (1 + INCREMENT_ALLOWED));
        prev = widthInt;
      }
    });
    test('testHeightSignsUrls', () {
      String src,
          parameters,
          generatedSignature,
          expectedSignature = '',
          signatureBase;

      for (String srcLine in srcsetHeightSplit) {
        src = srcLine.split(' ')[0];
        assert(src.contains('s='));
        generatedSignature = src.substring(src.indexOf('s=') + 2);

        parameters = src.substring(src.indexOf('?'), src.indexOf('s=') - 1);
        signatureBase = 'MYT0KEN/image.jpg' + parameters;

        // create MD5 hash
        expectedSignature = md5Hex(signatureBase);

        expect(generatedSignature, expectedSignature);
      }
    });
    test('testWidthAndHeightInDPRForm', () {
      String generatedRatio;
      var expectedRatio = 1;
      assert(srcsetWidthAndHeightSplit.length == 5);

      for (String src in srcsetWidthAndHeightSplit) {
        generatedRatio = src.split(' ')[1];
        expect(
          generatedRatio,
          expectedRatio.toString() + 'x',
        );
        expectedRatio++;
      }
    });

    test('testWidthAndHeightSignsUrls', () {
      String src,
          parameters,
          generatedSignature,
          expectedSignature = '',
          signatureBase;

      for (String srcLine in srcsetWidthAndHeightSplit) {
        src = srcLine.split(' ')[0];
        assert(src.contains('s='));
        generatedSignature = src.substring(src.indexOf('s=') + 2);

        parameters = src.substring(src.indexOf('?'), src.indexOf('s=') - 1);
        signatureBase = 'MYT0KEN/image.jpg' + parameters;

        expectedSignature = md5Hex(signatureBase);
        expect(generatedSignature, expectedSignature);
      }
    });
    test('testWidthAndHeightIncludesDPRParam', () {
      String src;

      for (var i = 0; i < srcsetWidthAndHeightSplit.length; i++) {
        src = srcsetWidthAndHeightSplit[i].split(' ')[0];
        expect(src, contains('dpr=${i + 1}'));
      }
    });

    test('testAspectRatioContainsARParameter', () {
      var targetWidths = [
        100,
        116,
        135,
        156,
        181,
        210,
        244,
        283,
        328,
        380,
        441,
        512,
        594,
        689,
        799,
        927,
        1075,
        1247,
        1446,
        1678,
        1946,
        2257,
        2619,
        3038,
        3524,
        4087,
        4741,
        5500,
        6380,
        7401,
        8192
      ];

      String generatedWidth;
      var index = 0;
      int widthInt;

      for (String src in srcsetAspectRatioSplit) {
        generatedWidth = src.split(' ')[1];
        widthInt =
            int.parse(generatedWidth.substring(0, generatedWidth.length - 1));
        expect(widthInt, targetWidths[index]);
        index++;
      }
    });

    test('testAspectRatioContainsARParameter', () {
      String url;

      for (String src in srcsetAspectRatioSplit) {
        url = src.split(' ')[0];
        expect(url.contains('ar='), isTrue);
      }
    });

    test('testAspectRatioReturnsExpectedNumberOfPairs', () {
      var expectedPairs = 31;
      expect(srcsetAspectRatioSplit.length, expectedPairs);
    });

    test('testAspectRatioDoesNotExceedBounds', () {
      String minWidth = srcsetAspectRatioSplit[0].split(' ')[1];
      String maxWidth =
          srcsetAspectRatioSplit[srcsetAspectRatioSplit.length - 1]
              .split(' ')[1];

      var minWidthInt = int.parse(minWidth.substring(0, minWidth.length - 1));
      var maxWidthInt = int.parse(maxWidth.substring(0, maxWidth.length - 1));

      expect(minWidthInt, greaterThanOrEqualTo(100));
      expect(maxWidthInt, lessThanOrEqualTo(8192));
    });

    // a 17% testing threshold is used to account for rounding

    test('testAspectRatioDoesNotIncreaseMoreThan17Percent', () {
      final INCREMENT_ALLOWED = .17;
      String width;
      int widthInt, prev;

      // convert and store first width (typically: 100)
      width = srcsetAspectRatioSplit[0].split(' ')[1];
      prev = int.parse(width.substring(0, width.length - 1));

      for (String src in srcsetAspectRatioSplit) {
        width = src.split(' ')[1];
        widthInt = int.parse(width.substring(0, width.length - 1));

        expect((widthInt / prev), lessThan((1 + INCREMENT_ALLOWED)));
        prev = widthInt;
      }
    });

    test('testAspectRatioSignsUrls', () {
      String src,
          parameters,
          generatedSignature,
          expectedSignature = '',
          signatureBase;

      for (String srcLine in srcsetAspectRatioSplit) {
        src = srcLine.split(' ')[0];
        assert(src.contains('s='));
        generatedSignature = src.substring(src.indexOf('s=') + 2);

        parameters = src.substring(src.indexOf('?'), src.indexOf('s=') - 1);
        signatureBase = 'MYT0KEN/image.jpg' + parameters;
        // create MD5 hash
        expectedSignature = md5Hex(signatureBase);

        expect(generatedSignature, expectedSignature);
      }
    });
    test('testWidthAndAspectRatioInDPRForm', () {
      String generatedRatio;
      var expectedRatio = 1;
      assert(srcsetWidthAndAspectRatioSplit.length == 5);

      for (String src in srcsetWidthAndAspectRatioSplit) {
        generatedRatio = src.split(' ')[1];
        expect(
          generatedRatio,
          '${expectedRatio}x',
        );
        expectedRatio++;
      }
    });

    test('testWidthAndAspectRatioSignsUrls', () {
      String src,
          parameters,
          generatedSignature,
          expectedSignature = '',
          signatureBase;

      for (String srcLine in srcsetWidthAndAspectRatioSplit) {
        src = srcLine.split(' ')[0];
        assert(src.contains('s='));
        generatedSignature = src.substring(src.indexOf('s=') + 2);

        parameters = src.substring(src.indexOf('?'), src.indexOf('s=') - 1);
        signatureBase = 'MYT0KEN/image.jpg' + parameters;

        // create MD5 hash
        expectedSignature = md5Hex(signatureBase);

        expect(
          generatedSignature,
          expectedSignature,
        );
      }
    });
    test('testWidthAndAspectRatioIncludesDPRParam', () {
      String src;

      for (var i = 0; i < srcsetWidthAndAspectRatioSplit.length; i++) {
        src = srcsetWidthAndAspectRatioSplit[i].split(' ')[0];
        expect(src, contains('dpr=${i + 1}'));
      }
    });

    test('testHeightAndAspectRatioInDPRForm', () {
      String generatedRatio;
      var expectedRatio = 1;
      assert(srcsetHeightAndAspectRatioSplit.length == 5);

      for (String src in srcsetHeightAndAspectRatioSplit) {
        generatedRatio = src.split(' ')[1];
        expect(
          generatedRatio,
          '${expectedRatio}x',
        );
        expectedRatio++;
      }
    });
    test('testHeightAndAspectRatioSignsUrls', () {
      String src,
          parameters,
          generatedSignature,
          expectedSignature = '',
          signatureBase;

      for (String srcLine in srcsetHeightAndAspectRatioSplit) {
        src = srcLine.split(' ')[0];
        assert(src.contains('s='));
        generatedSignature = src.substring(src.indexOf('s=') + 2);

        parameters = src.substring(src.indexOf('?'), src.indexOf('s=') - 1);
        signatureBase = 'MYT0KEN/image.jpg' + parameters;

        // create MD5 hash
        expectedSignature = md5Hex(signatureBase);

        expect(generatedSignature, expectedSignature);
      }
    });

    test('testHeightAndAspectRatioIncludesDPRParam', () {
      String src;

      for (var i = 0; i < srcsetHeightAndAspectRatioSplit.length; i++) {
        src = srcsetHeightAndAspectRatioSplit[i].split(' ')[0];
        expect(src, contains('dpr=${i + 1}'));
      }
    });
    test('testDisableVariableQualityOffByDefault', () {
      var ub = UrlBuilder('test.imgix.net', false, '', false);
      var params = HashMap<String, String>();
      params['w'] = '320';
      // Ensure calling 2-param `createSrcSet` yields same results as
      // calling 3-param `createSrcSet`.
      var actualWith2Param = ub.createSrcSet('image.png', params: params);
      var actualWith3Param = ub.createSrcSet('image.png',
          params: params, disableVariableQuality: false);
      var expected = 'http://test.imgix.net/image.png?dpr=1&q=75&w=320 1x,\n'
          'http://test.imgix.net/image.png?dpr=2&q=50&w=320 2x,\n'
          'http://test.imgix.net/image.png?dpr=3&q=35&w=320 3x,\n'
          'http://test.imgix.net/image.png?dpr=4&q=23&w=320 4x,\n'
          'http://test.imgix.net/image.png?dpr=5&q=20&w=320 5x';

      expect(actualWith2Param, expected);
      expect(actualWith3Param, expected);
    });
    test('testDisableVariableQuality', () {
      var ub = UrlBuilder('test.imgix.net', false, '', false);
      var params = new HashMap<String, String>();
      params['w'] = '320';
      var actual = ub.createSrcSet('image.png',
          params: params, disableVariableQuality: true);
      var expected = 'http://test.imgix.net/image.png?dpr=1&w=320 1x,\n'
          'http://test.imgix.net/image.png?dpr=2&w=320 2x,\n'
          'http://test.imgix.net/image.png?dpr=3&w=320 3x,\n'
          'http://test.imgix.net/image.png?dpr=4&w=320 4x,\n'
          'http://test.imgix.net/image.png?dpr=5&w=320 5x';

      expect(actual, expected);
    });
    test('testDisableVariableQualityWithQuality', () {
      var ub = UrlBuilder('test.imgix.net', false, '', false);
      var params = HashMap<String, String>();
      params['w'] = '320';
      params['q'] = '99';
      var actual = ub.createSrcSet('image.png',
          params: params, disableVariableQuality: true);
      var expected = "http://test.imgix.net/image.png?dpr=1&q=99&w=320 1x,\n"
          "http://test.imgix.net/image.png?dpr=2&q=99&w=320 2x,\n"
          "http://test.imgix.net/image.png?dpr=3&q=99&w=320 3x,\n"
          "http://test.imgix.net/image.png?dpr=4&q=99&w=320 4x,\n"
          "http://test.imgix.net/image.png?dpr=5&q=99&w=320 5x";

      expect(actual, expected);
    });
    test('testCreateSrcSetQandVariableQualityEnabled', () {
      var ub = UrlBuilder('test.imgix.net', false, '', false);
      var params = HashMap<String, String>();
      params['ar'] = "4:3";
      params['h'] = '100';
      params['q'] = '99';

      var actual = ub.createSrcSet('image.png', params: params);
      var expected =
          'http://test.imgix.net/image.png?ar=4%3A3&dpr=1&h=100&q=99 1x,\n'
          'http://test.imgix.net/image.png?ar=4%3A3&dpr=2&h=100&q=99 2x,\n'
          'http://test.imgix.net/image.png?ar=4%3A3&dpr=3&h=100&q=99 3x,\n'
          'http://test.imgix.net/image.png?ar=4%3A3&dpr=4&h=100&q=99 4x,\n'
          'http://test.imgix.net/image.png?ar=4%3A3&dpr=5&h=100&q=99 5x';

      expect(expected, actual);
    });
    test('testCreateSrcSetPairsBeginEnd', () {
      var ub = UrlBuilder('test.imgix.net', false, '', false);
      var params = HashMap<String, String>();
      var actual =
          ub.createSrcSet('image.png', params: params, begin: 100, end: 380);
      var expected = 'http://test.imgix.net/image.png?w=100 100w,\n'
          'http://test.imgix.net/image.png?w=116 116w,\n'
          'http://test.imgix.net/image.png?w=135 135w,\n'
          'http://test.imgix.net/image.png?w=156 156w,\n'
          'http://test.imgix.net/image.png?w=181 181w,\n'
          'http://test.imgix.net/image.png?w=210 210w,\n'
          'http://test.imgix.net/image.png?w=244 244w,\n'
          'http://test.imgix.net/image.png?w=283 283w,\n'
          'http://test.imgix.net/image.png?w=328 328w,\n'
          'http://test.imgix.net/image.png?w=380 380w';

      expect(actual, expected);
    });
    test('testCreateSrcSetTol', () {
      var ub = UrlBuilder('test.imgix.net', false, '', false);
      var params = HashMap<String, String>();
      var actual = ub.createSrcSet('image.png', params: params, tol: 50);
      var expected = 'http://test.imgix.net/image.png?w=100 100w,\n'
          'http://test.imgix.net/image.png?w=200 200w,\n'
          'http://test.imgix.net/image.png?w=400 400w,\n'
          'http://test.imgix.net/image.png?w=800 800w,\n'
          'http://test.imgix.net/image.png?w=1600 1600w,\n'
          'http://test.imgix.net/image.png?w=3200 3200w,\n'
          'http://test.imgix.net/image.png?w=6400 6400w,\n'
          'http://test.imgix.net/image.png?w=8192 8192w';

      expect(actual, expected);
    });
    test('testCreateSrcSetBeginEqualsEnd', () {
      var ub = UrlBuilder('test.imgix.net', false, '', false);
      var params = new HashMap<String, String>();
      var actual =
          ub.createSrcSet('image.png', params: params, begin: 640, end: 640);
      var expected = 'http://test.imgix.net/image.png?w=640 640w';

      expect(expected, actual);
    });
    test('testCreateSrcSetWidthTargets', () {
      var ub = UrlBuilder('test.imgix.net', false, '', false);
      var params = HashMap<String, String>();
      var actual = ub.createSrcSet('image.png',
          params: params, targets: [100, 200, 300, 400, 500, 600]);
      var expected = 'http://test.imgix.net/image.png?w=100 100w,\n'
          'http://test.imgix.net/image.png?w=200 200w,\n'
          'http://test.imgix.net/image.png?w=300 300w,\n'
          'http://test.imgix.net/image.png?w=400 400w,\n'
          'http://test.imgix.net/image.png?w=500 500w,\n'
          'http://test.imgix.net/image.png?w=600 600w';

      expect(actual, expected);
    });
  });
}

String md5Hex(String input) {
  return md5.convert(utf8.encode(input)).toString();
}
