import 'dart:collection';

import 'package:quiver/strings.dart';

import 'url_helper.dart';

class UrlBuilder {
  static final String VERSION = '1.0.0';
  static final String DOMAIN_REGEX =
      '^(?:[a-z\\d\\-_]{1,62}\\.){0,125}(?:[a-z\\d](?:\\-(?=\\-*[a-z\\d])|[a-z]|\\d){0,62}\\.)[a-z\\d]{1,63}\$';

  static final SRCSET_TARGET_WIDTHS = [
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
  static final List<int> sss = <int>[];
  static const int SRCSET_WIDTH_TOLERANCE = 8;
  static const int MIN_WIDTH = 100;
  static const int MAX_WIDTH = 8192;
  static final DPR_QUALITIES = [75, 50, 35, 23, 20];
  static final TARGET_RATIOS = [1, 2, 3, 4, 5];

  final String domain;
  bool useHttps;
  String signKey;
  final bool includeLibraryParam;

  UrlBuilder(this.domain,
      [this.useHttps = true, this.signKey, this.includeLibraryParam = true]) {
    var domainPattern = RegExp(DOMAIN_REGEX);
    if (isBlank(domain)) {
      throw ArgumentError.value(
          domain, 'domain', 'At lease one domain must be passed to URLBuilder');
    } else if (!domainPattern.hasMatch(domain)) {
      throw ArgumentError.value(domain, 'domain',
          'Domain must be passed in as a fully-qualified domain name and should not include a protocol or any path element, i.e. \"example.imgix.net\".');
    }
  }

  String createURL(String path, [Map<String, String> params]) {
    params ??= {};
    var scheme = useHttps ? 'https' : 'http';
    if (includeLibraryParam) {
      params['ixlib'] = 'dart-$VERSION';
    }
    return UrlHelper(domain, path, scheme, signKey, params).getURL();
  }

  static List<int> targetWidths(int begin, int end, int tol) {
    return computeTargetWidths(
        begin?.toDouble(), end?.toDouble(), tol?.toDouble());
  }

  /// Create a srcset given a `path` and a map of `params`.
  ///
  /// This function creates a dpr based srcset if `params`
  /// contain either:
  /// - a width "w" param, _or_
  /// - a height "h" and aspect ratio "ar" params
  ///
  /// Otherwise, a srcset of width-pairs is created.
  /// path - path to the image, i.e. "image/file.png"
  /// @param params - map of query parameters
  /// @param tol - tolerable amount of width value variation
  /// @param disableVariableQuality - flag to toggle variable image
  //  output quality.
  ///
  /// @return srcset attribute string
  ///

  String createSrcSet(String path,
      {Map<String, String> params,
      int begin = MIN_WIDTH,
      int end = MAX_WIDTH,
      int tol = SRCSET_WIDTH_TOLERANCE,
      bool disableVariableQuality = false,
      Iterable<int> targets}) {
    params ??= SplayTreeMap();
    if (targets?.isNotEmpty == true) {
      return createSrcSetPairs(path, params, targets);
    } else if (isDpr(params)) {
      return createSrcSetDPR(path, params, disableVariableQuality);
    } else {
      var targets = targetWidths(begin, end, tol);
      return createSrcSetPairs(path, params, targets);
    }
  }

  String createSrcSetDPR(
      String path, Map<String, String> params, bool disableVariableQuality) {
    var srcset = StringBuffer();
    Map<String, String> srcsetParams = HashMap<String, String>.of(params);

    var has_quality = params['q'] != null;

    for (final ratio in TARGET_RATIOS) {
      srcsetParams['dpr'] = ratio.toString();

      if (!disableVariableQuality && !has_quality) {
        srcsetParams['q'] = DPR_QUALITIES[ratio - 1].toString();
      }
      srcset.write(createURL(path, srcsetParams));
      srcset.write(' ');
      srcset.write(ratio);
      srcset.write('x,\n');
    }
    var string = srcset.toString();
    return string.substring(0, string.length - 2);
  }

  /// Create an `ArrayList` of integer target widths.
  ///
  /// This function is the implementation details of `targetWidths`.
  /// This function exists to provide a consistent interface for
  /// callers of `targetWidths`.
  ///
  /// This function implements the syntax that fulfills the semantics
  /// of `targetWidths`. Meaning, `begin`, `end`, and `tol` are
  /// to be whole integers, but computation requires `double`s. This
  /// function hides this detail from callers.
  static List<int> computeTargetWidths(double begin, double end, double tol) {
    if (_notCustom(begin, end, tol)) {
      return List<int>.of(SRCSET_TARGET_WIDTHS);
    }

    var resolutions = <int>[];
    if (begin == end) {
      // `begin` has not been mutated; cast back to `int`.
      resolutions.add(begin?.toInt());
      return resolutions;
    }

    while (begin < end && begin < MAX_WIDTH) {
      // Round values so that the resulting `int` is truer
      // to expectations (i.e. 115.99999 --> 116).
      resolutions.add(begin.round());
      begin *= 1 + (tol / 100) * 2;
    }

    var lastIndex = resolutions.length - 1;
    if (resolutions[lastIndex] < end) {
      // `end` has not been mutated; cast back to `int`.
      resolutions.add(end.toInt());
    }

    return resolutions;
  }

  bool isDpr(Map<String, String> params) {
    var width = params['w'];
    var hasWidth = width != null && isNotBlank(params['w']);

    var height = params['h'];
    var hasHeight = (height != null) && height.isNotEmpty;

    var aspectRatio = params['ar'];
    var hasAspectRatio = (aspectRatio != null) && aspectRatio.isNotEmpty;

    // If `params` have a width param or _both_ height and aspect
    // ratio parameters then the srcset to be constructed with
    // these params _is dpr based_.
    return hasWidth || (hasHeight && hasAspectRatio);
  }

  String createSrcSetPairs(
      String path, Map<String, String> params, Iterable<int> targets) {
    var srcset = StringBuffer();

    for (var width in targets) {
      params['w'] = width.toString();
      srcset.write(createURL(path, params));
      srcset.write(' ');
      srcset.write(width);
      srcset.writeln('w,');
    }

    var string = srcset.toString();
    return string.substring(0, srcset.length - 2);
  }

  static bool _notCustom(double begin, double end, double tol) {
    var defaultBegin = (begin == MIN_WIDTH);
    var defaultEnd = (end == MAX_WIDTH);
    var defaultTol = (tol == SRCSET_WIDTH_TOLERANCE);

// A list of target widths is _NOT_ custom if `begin`, `end`,
// and `tol` are equal to their default values.
    return defaultBegin && defaultEnd && defaultTol;
  }
}
