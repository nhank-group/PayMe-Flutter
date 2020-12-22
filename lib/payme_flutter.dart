import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'debug.dart';

typedef Function OnSuccess({String key, dynamic value});
typedef Function OnError(String error);

class PaymeFlutter {
  String _appId;
  String _publicKey;
  String _privateKey;
  String _connectToken;
  List<Color> _colors = [Colors.black];

  static const MethodChannel _channel = const MethodChannel('payme_flutter');
  bool _isInited = false;

  PaymeFlutter();

  Future init(
      {@required appId,
      @required publicKey,
      @required privateKey,
      connectToken,
      colors}) async {
    assert(appId != null &&
        appId.isNotEmpty &&
        publicKey != null &&
        publicKey.isNotEmpty &&
        privateKey != null &&
        privateKey.isNotEmpty &&
        connectToken != null &&
        connectToken.isNotEmpty &&
        privateKey.isNotEmpty &&
        colors != null &&
        colors.length > 0);
    _appId = appId;
    _publicKey = publicKey;
    _privateKey = privateKey;
    _connectToken = connectToken;
    _colors = colors;
    final bool isInited = await _channel.invokeMethod('init');

    if (isInited) {
      _isInited = isInited;
    }

    return isInited;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<bool> get isConnected async {
    final bool isConnected = await _channel.invokeMethod('is_connected');
    return isConnected;
  }

  void setDebug(bool enable) {
    Debug.enabled = enable;
  }

  Future<String> openWallet() async {
    if (_isInited) {
      try {
        return await _channel.invokeMethod('open_wallet');
      } catch (e) {
        Debug.log(e);
      }
    } else {
      Debug.log("PayMe is not intited");
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại';
  }

  Future<String> deposit(int amount) async {
    assert(amount != null, amount > 0);
    if (_isInited) {
      try {
        return await _channel.invokeMethod('deposit');
      } catch (e) {
        Debug.log(e);
      }
    } else {
      Debug.log("PayMe is not intited");
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại';
  }

  Future<String> withdraw(int amount) async {
    assert(amount != null, amount > 0);
    if (_isInited) {
      try {
        return await _channel.invokeMethod('withdraw');
      } catch (e) {
        Debug.log(e);
      }
    } else {
      Debug.log("PayMe is not intited");
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại';
  }

  Future<String> getWalletInfo(
      Function(int balance, int cash, int lockCash) onCompleteHandler) async {
    if (_isInited) {
      if (onCompleteHandler != null) {
        try {
          final result = await _channel.invokeMethod('get_wallet_info');
          if (result is Map) {
            onCompleteHandler(
                result['walletBalance']['balance'],
                result['walletBalance']['detail']['cash'],
                result['walletBalance']['detail']['lockCash']);
            return null;
          } else if (result is String) {
            return result;
          }
        } catch (e) {
          Debug.log(e);
        }
      }
    } else {
      Debug.log("PayMe is not intited");
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại';
  }
}
