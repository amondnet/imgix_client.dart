import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:quiver/strings.dart';

class UrlHelper {
  final String _domain;
  String _path;
  final String _scheme;
  final String? _signKey;
  final Map<String, String> _parameters;

  UrlHelper(this._domain, this._path,
      [this._scheme = 'http',
      this._signKey = '',
      Map<String, String> parameters = const {}])
      : _parameters = SplayTreeMap.of(parameters) {
    if (!_path.startsWith('/')) {
      _path = '/$_path';
    }
  }

  void setParameter(String key, dynamic value) {
    if (value is String || value is num) {
      var stringValue = value.toString();
      if (isNotBlank(stringValue)) {
        _parameters[key] = stringValue;
      } else {
        _parameters.remove(key);
      }
    }
  }

  void deleteParameter(String key) {
    setParameter(key, '');
  }

  // URL Safe base64
  String _encodeBase64(String str) {
    String b64EncodedString;

    try {
      var stringBytes = utf8.encode(str);
      b64EncodedString = base64UrlEncode(stringBytes);
      b64EncodedString = b64EncodedString.replaceAll('=', '');
    } catch (e) {
      throw ArgumentError(e);
    }

    return b64EncodedString;
  }

  String getURL() {
    var queryPairs = <String>[];

    for (var entry in _parameters.entries) {
      var k = Uri.encodeComponent(entry.key);
      var v = entry.value;

      String encodedValue;

      if (k.endsWith('64')) {
        encodedValue = _encodeBase64(v);
      } else {
        encodedValue = Uri.encodeComponent(v);
      }
      queryPairs.add('$k=$encodedValue');
    }

    var query = queryPairs.join('&');

    var decodedPath = Uri.decodeComponent(_path.substring(1));
    if (decodedPath.startsWith('http://') ||
        decodedPath.startsWith('https://')) {
      _path = '/${Uri.encodeComponent(decodedPath)}';
    }

    if (isNotBlank(_signKey)) {
      var delim = query == '' ? '' : '?';
      var toSign = _signKey! + _path + delim + query;
      var signature = md5.convert(utf8.encode(toSign)).toString();

      if (query.isNotEmpty) {
        query += '&s=$signature';
      } else {
        query = 's=$signature';
      }

      return buildURL(_scheme, _domain, _path, query);
    }

    return buildURL(_scheme, _domain, _path, query);
  }

  ///////////// Static

  static String buildURL(
      String scheme, String host, String path, String query) {
    // do not use URI to build URL since it will do auto-encoding which can break our previous signing
    var url = '$scheme://$host$path?$query';
    if (url.endsWith('#')) {
      url = url.substring(0, url.length - 1);
    }

    if (url.endsWith('?')) {
      url = url.substring(0, url.length - 1);
    }

    return url;
  }

  static String MD5(String input) {
    var array = utf8.encode(input);
    return md5.convert(array).toString();
  }

  static String encodeURIComponent(String s) {
    String result;

    try {
      result = Uri.encodeComponent(s)
          .replaceAll('\\+', '%20')
          .replaceAll('\\%21', '!')
          .replaceAll('\\%27', "'")
          .replaceAll('\\%28', '(')
          .replaceAll('\\%29', ')')
          .replaceAll('\\%7E', '~');
    } catch (e) {
      result = s;
    }

    return result;
  }

  static String decodeURIComponent(String s) {
    String result;

    try {
      result = Uri.decodeComponent(s);
    } catch (e) {
      result = s;
    }

    return result.toString();
  }
}
