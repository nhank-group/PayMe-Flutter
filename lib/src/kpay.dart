import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'debug.dart';
import 'extension.dart';
import 'model.dart';

class KpayFlutter {
  String _appToken;
  String _publicKey;
  String _appPrivateKey;
  String _connectToken;
  Environment _env;
  List<Color> _colors = [Colors.black];

  static const MethodChannel _channel = const MethodChannel('kpay_flutter');
  bool _isInited = false;

  KpayFlutter() {
    Debug.enabled = true;
  }

  Future<bool> init(
      {@required appToken,
      @required publicKey,
      @required appPrivateKey,
      @required connectToken,
      @required env,
      colors}) async {
    assert(appToken != null && appToken.isNotEmpty);
    assert(publicKey != null && publicKey.isNotEmpty);
    assert(appPrivateKey != null && appPrivateKey.isNotEmpty);
    assert(env != null);
    assert(connectToken != null && connectToken.isNotEmpty);

    _appToken = appToken;
    _publicKey = publicKey;
    _appPrivateKey = appPrivateKey;
    _connectToken = connectToken;
    _env = env;
    _colors = colors;

    final Map<String, dynamic> data = {
      "app_token": _appToken,
      "public_key": _publicKey,
      "app_private_key": _appPrivateKey,
      "connect_token": _connectToken,
      "env": _env == Environment.PRODUCTION
          ? "production"
          : (_env == Environment.SANDBOX ? "sandbox" : "dev"),
      "colors": _colors != null
          ? _colors.map((color) => color.toHexTriplet()).toList()
          : null
    };

    final bool isInited = await _channel.invokeMethod('init', data);

    if (isInited) {
      _isInited = isInited;
    }

    return isInited;
  }

  static Future<String> generateToken(String userId, String phone, String secretKey) async {
    return await _channel.invokeMethod('generate_token',
        {"user_id": userId, "phone": phone, "key": secretKey});
  }

  Future<bool> get isConnected async {
    final bool isConnected = await _channel.invokeMethod('is_connected');
    return isConnected;
  }

  Future<bool> login() async {
    if (_isInited) {
      try {
        return await _channel.invokeMethod('login');
      } catch (e) {
        Debug.log(e);
      }
    } else {
      Debug.log("PayMe is not intited");
    }
  }

  Future<void> openWallet() async {
    if (_isInited) {
      try {
        return await _channel.invokeMethod('open_wallet');
      } catch (e) {
        Debug.log(e);
      }
    } else {
      Debug.log("PayMe is not intited");
    }
  }

  Future<String> deposit(int amount) async {
    assert(amount != null, amount > 0);
    if (_isInited) {
      try {
        return await _channel.invokeMethod('deposit', {"amount": amount});
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
        return await _channel.invokeMethod('withdraw',{"amount": amount});
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
