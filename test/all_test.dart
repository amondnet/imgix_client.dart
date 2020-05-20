import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverless/imgix.dart';
import 'package:serverless/url_builder.dart';
import 'package:serverless/url_helper.dart';
import 'package:test/test.dart';

void main() {
  group('srcSet', () {
    test('testURLBuilderRaisesExceptionOnNoDomains', () {
      expect(() => UrlBuilder(''), throwsArgumentError);
    });

    test('testURLBuilderUsesHttpsByDefault', () {
      // Test `URLBuilder` uses https by default.
      // This test uses the single-parameter constructor.
      // The single parameter constructor is the only constructor
      // where "default" makes sense. E.g. calling
      // `URLBuilder("example.imgix.net", true)`
      // passes `true` to the constructor explicitly.
      var ub = UrlBuilder('example.imgix.net');
      var expected = 'https://example.imgix.net/image/file.png?ixlib=dart-' +
          UrlBuilder.VERSION;
      expect(ub.createURL('image/file.png'), expected);
    });
    test('testSetUseHttpsFalse', () {
      // Test `setUseHttps` to `false`.
      var ub = UrlBuilder('example.imgix.net');
      ub.useHttps = false;
      var expected = 'http://example.imgix.net/image/file.png?ixlib=dart-' +
          UrlBuilder.VERSION;
      expect(ub.createURL('image/file.png'), expected);
    });
    test('testSetUseHttpsTrue', () {
      // Test `setUseHttps` to `false`.
      var ub = UrlBuilder('example.imgix.net');
      ub.useHttps = true;
      var expected = 'https://example.imgix.net/image/file.png?ixlib=dart-' +
          UrlBuilder.VERSION;
      expect(ub.createURL('image/file.png'), expected);
    });

    test('testHelperBuildAbsolutePath', () {
      var uh = UrlHelper(
          'securejackangers.imgix.net', "/example/chester.png", 'http');
      expect(
          'http://securejackangers.imgix.net/example/chester.png', uh.getURL());
    });

    test('testHelperBuildRelativePath', () {
      var uh = UrlHelper(
          'securejackangers.imgix.net', 'example/chester.png', 'http');
      expect(
          'http://securejackangers.imgix.net/example/chester.png', uh.getURL());
    });

    test('testHelperBuildNestedPath', () {
      var uh = new UrlHelper('securejackangers.imgix.net',
          'http://www.somedomain.com/example/chester.png', 'http');
      expect(
          'http://securejackangers.imgix.net/http%3A%2F%2Fwww.somedomain.com%2Fexample%2Fchester.png',
          uh.getURL());
    });

    test('testHelperBuildAbsolutePathWithParams', () {
      var uh = UrlHelper(
          'securejackangers.imgix.net', "/example/chester.png", 'http');
      uh.setParameter('w', 500);
      expect('http://securejackangers.imgix.net/example/chester.png?w=500',
          uh.getURL());
    });
    test('testHelperBuildRelativePathWithParams', () {
      var uh = UrlHelper(
          'securejackangers.imgix.net', "example/chester.png", 'http');
      uh.setParameter('w', 500);
      expect('http://securejackangers.imgix.net/example/chester.png?w=500',
          uh.getURL());
    });
    test('testHelperBuildNestedPathWithParams', () {
      var uh = new UrlHelper('securejackangers.imgix.net',
          'http://www.somedomain.com/example/chester.png', 'http');
      uh.setParameter('w', 500);

      expect(
        'http://securejackangers.imgix.net/http%3A%2F%2Fwww.somedomain.com%2Fexample%2Fchester.png?w=500',
        uh.getURL(),
      );
    });
    test('testHelperBuildSignedURLWithHashMapParams', () {
      var params = HashMap<String, String>();
      params['w'] = '500';

      var uh = UrlHelper('securejackangers.imgix.net', 'example/chester.png',
          'http', "Q61NvXIy", params);
      expect(
          'http://securejackangers.imgix.net/example/chester.png?w=500&s=787b9057d5c077fe168b4849737d8a90',
          uh.getURL());
    });
    test('testHelperBuildSignedURLWithHashSetterParams', () {
      var uh = UrlHelper('securejackangers.imgix.net', 'example/chester.png',
          'http', "Q61NvXIy");
      uh.setParameter("w", 500);

      expect(
          'http://securejackangers.imgix.net/example/chester.png?w=500&s=787b9057d5c077fe168b4849737d8a90',
          uh.getURL());
    });
    test('testHelperBuildSignedURLWithWebProxyWithNoEncoding', () {
      var uh = UrlHelper(
          'jackttl2.imgix.net',
          'http%3A%2F%2Fa.abcnews.com%2Fassets%2Fimages%2Fnavigation%2Fabc-logo.png%3Fr%3D20',
          'http',
          'JHrM2ezd');
      expect(
        'http://jackttl2.imgix.net/http%3A%2F%2Fa.abcnews.com%2Fassets%2Fimages%2Fnavigation%2Fabc-logo.png%3Fr%3D20?s=cf82defe3436a957262d0e64c21e72f9',
        uh.getURL(),
      );
    });
    test('testBuildSignedURLWithWebProxyWithUnencodedInput', () {
      var uh = UrlHelper(
          'imgix-library-web-proxy-test-source.imgix.net',
          'https://paulstraw.imgix.net/colon:test/benice.jpg',
          'https',
          'qN5VOqaLGQUFzETO');
      expect(
        'https://imgix-library-web-proxy-test-source.imgix.net/https%3A%2F%2Fpaulstraw.imgix.net%2Fcolon%3Atest%2Fbenice.jpg?s=175a054524d75840735855b9263be591',
        uh.getURL(),
      );
    });

    test('testBuilderWithFullyQualifiedURL', () {
      var ub =
          UrlBuilder('my-social-network.imgix.net', true, 'FOO123bar', false);
      expect(
        'https://my-social-network.imgix.net/http%3A%2F%2Favatars.com%2Fjohn-smith.png?s=493a52f008c91416351f8b33d4883135',
        ub.createURL('http://avatars.com/john-smith.png'),
      );
    });

    test('testBuilderWithFullyQualifiedURLAndParameters', () {
      var ub =
          UrlBuilder('my-social-network.imgix.net', true, 'FOO123bar', false);
      Map<String, String> params = HashMap<String, String>();
      params['w'] = '400';
      params['h'] = '300';
      expect(
        'https://my-social-network.imgix.net/http%3A%2F%2Favatars.com%2Fjohn-smith.png?h=300&w=400&s=a201fe1a3caef4944dcb40f6ce99e746',
        ub.createURL('http://avatars.com/john-smith.png', params),
      );
    });

    test('testHelperBuildSignedUrlWithIxlibParam', () {
      var domains = ['assets.imgix.net'];
      var ub = UrlBuilder('assets.imgix.net', true, '', true);
      expect(hasURLParameter(ub.createURL('/users/1.png'), 'ixlib'), isTrue);

      ub = UrlBuilder('assets.imgix.net', true, '', false);
      expect(hasURLParameter(ub.createURL('/users/1.png'), 'ixlib'), isFalse);
    });

    test('testTargetWidths', () {
      var actual = UrlBuilder.targetWidths(100, 8192, 8);
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
      for (var i = 0; i < targetWidths.length; ++i) {
        expect(actual[i], targetWidths[i]);
      }
    });

    test('testParamKeysAreEscaped', () {
      var params = HashMap<String, String>();
      params['hello world'] = 'interesting';

      var uh = UrlHelper('demo.imgix.net', 'demo.png', 'https', null, params);

      expect(uh.getURL(),
          'https://demo.imgix.net/demo.png?hello%20world=interesting');
    });

    test('testParamValuesAreEscaped', () {
      var params = HashMap<String, String>();
      params['hello_world'] = '/foo\"> <script>alert(\"hacked\")</script><';

      var uh = UrlHelper('demo.imgix.net', 'demo.png', 'https', null, params);

      expect(uh.getURL(),
          'https://demo.imgix.net/demo.png?hello_world=%2Ffoo%22%3E%20%3Cscript%3Ealert(%22hacked%22)%3C%2Fscript%3E%3C');
    });

    test('testBase64ParamVariantsAreBase64Encoded', () {
      var params = HashMap<String, String>();
      params['txt64'] = 'I cannøt belîév∑ it wors! 😱';

      var uh = UrlHelper('demo.imgix.net', '~text', 'https', null, params);

      expect(uh.getURL(),
          'https://demo.imgix.net/~text?txt64=SSBjYW5uw7h0IGJlbMOuw6l24oiRIGl0IHdvcu-jv3MhIPCfmLE');
    });

    test('testExtractDomain', () {
      var url = 'http://jackangers.imgix.net/chester.png';
      expect('jackangers.imgix.net', extractDomain(url));
    });

    test('testEncodeDecode', () {
      final url =
          'http://a.abcnews.com/assets/images/navigation/abc-logo.png?r=20';
      final encodedUrl =
          'http%3A%2F%2Fa.abcnews.com%2Fassets%2Fimages%2Fnavigation%2Fabc-logo.png%3Fr%3D20';

      expect(
        encodedUrl,
        UrlHelper.encodeURIComponent(url),
      );
      expect(url, UrlHelper.decodeURIComponent(encodedUrl));
      expect(
          encodedUrl,
          UrlHelper.encodeURIComponent(
              UrlHelper.decodeURIComponent(encodedUrl)));
    });

    test('testInvalidDomainAppendSlash', () {
      expect(() => UrlBuilder('test.imgix.net/'), throwsArgumentError);
    });

    test('testInvalidDomainPrependScheme', () {
      expect(() => UrlBuilder('https://test.imgix.net/'), throwsArgumentError);
    });

    test('testInvalidDomainAppendDash', () {
      expect(() => UrlBuilder('test.imgix.net-'), throwsArgumentError);
    });
  });
}

String extractDomain(String url) {
  try {
    var parsed = Uri.parse(url);
    var curDomain = parsed.authority;
    return curDomain;
  } catch (e) {
    print(e);
  }

  return '';
}

bool hasURLParameter(String url, String param) {
  try {
    var parsed = Uri.parse(url);
    var query = parsed.query;
    return query != null && query.contains(param);
  } catch (e) {
    return false;
  }
}
