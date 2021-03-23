import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kpay_flutter/kpay_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _publickey = """
-----BEGIN PUBLIC KEY----- MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAK+RnW1asb6a/9+HTClLkUEJF8mvywdJ H6+/xk5Nt7m1E2TVjhE+zfp6dmuqRySHAtrsgP95tkJH8OZk+9u7C7ECAwEAAQ== -----END PUBLIC KEY----- 
    """;

  final _appPrivateKey = """
-----BEGIN RSA PRIVATE KEY-----
MIIBOgIBAAJBAIXtP/j33hBYsnMq4hCFKtJlnc5+4bIBtHJVbR46S7b5w34C1yqT
jTmaBdrqVJB9budx4Sto9x8KqNxnVoHGkl0CAwEAAQJARawNMcpRHhPmkf9nJ8z/
YAE5PWnIpEA6zZgfcjBFn2Q5asdZv8czC/gh4e3jqa5jMGfwGqlUand+jnX7jsdN
gQIhAP8ee8ppfiodOvSeJOhmL2rww3TQv17qQ931Sfvs95FxAiEAhmOi8rDT4/ct
/ey3NEYpVjFBYPdusEfKA30Dazb5Wa0CIHbDjSNMeuRGGUT5PftGXrqs/ICsEPqx
mgiBAQEbbqCxAiB5sSWv4AGvr3edNUpccqAh5a5PMR+xTwCWEhETeA9pbQIhAKV7
WVdttMMDvepZdSb/YydlYxenU2TtW8kJYmt/GY9x
-----END RSA PRIVATE KEY-----
    """;
  final _appToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MTMsImlhdCI6MTYxNDE0MjQzOH0.h2pve1FoI4am4Or7nJAUUpK7QS_5Cc-8mFTfwBqogZE";
  final payMe = KpayFlutter();

  final _userIdTextController = TextEditingController(text: "0334345979");
  final _phoneTextController = TextEditingController(text: "0334345979");
  final _moneyController = TextEditingController(text: "10000");

  @override
  void initState() {
    super.initState();
  }

  Future<String> _generateToken(String userId, String phone) async {
    final token = await KpayFlutter.generateToken(
        userId, phone, "a88764bf353f48e3024988da59f57f30");
    await showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Token"),
              content: new Text(token),
              actions: <Widget>[
                FlatButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
    return token;
  }

  Future<bool> _initPayMe(String appToken, String publicKey,
      String appPrivateKey, String connectToken) async {
    return await payMe.init(
        appToken: appToken,
        publicKey: publicKey,
        appPrivateKey: appPrivateKey,
        env: Environment.SANDBOX,
        connectToken: connectToken,
        colors: [Color(0xFFE6C371)]);
  }

  Future _deposit(int amount) async {
    return await payMe.deposit(amount);
  }

  Future<bool> _login() async {
    return await payMe.login();
  }

  Future<void> _openWallet() async {
    return await payMe.openWallet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayMe Flutter'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          fillColor: Colors.grey,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 11, right: 15),
                          hintText: "Nhập  user ID"),
                      controller: _userIdTextController,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          fillColor: Colors.grey,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 11, right: 15),
                          hintText: "Nhập  phone"),
                      controller: _phoneTextController,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              FlatButton(
                  color: Colors.blue,
                  onPressed: () async {
                    if (_userIdTextController.text != null &&
                        _phoneTextController.text != null) {
                      final token = await _generateToken(
                          _userIdTextController.text,
                          _phoneTextController.text);
                      print('connect token $token');
                      final initResult = await _initPayMe(
                          _appToken, _publickey, _appPrivateKey, token);
                      print("initResult = $initResult");
                      final isLogined = await _login();
                      print("isLogined = $isLogined");
                    } else {
                      showDialog(
                          context: context,
                          builder: (_) => new AlertDialog(
                                title: new Text("Lỗi"),
                                content:
                                    new Text("Vui lòng nhập user id và phone"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              ));
                    }
                  },
                  child: Text("Login"))
            ],
          ),
          FlatButton(
              color: Colors.blue,
              onPressed: () {
                if (payMe != null) {
                  _openWallet();
                } else {
                  showDialog(
                      context: context,
                      builder: (_) => new AlertDialog(
                            title: new Text("Lỗi"),
                            content:
                                new Text("Vui lòng tạo connect token trước"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ));
                }
              },
              child: Text("Mở ví")),
          FlatButton(
              color: Colors.blue,
              onPressed: () async {
                if (payMe != null) {
                  final error =
                      await payMe.getWalletInfo((balance, cash, lockCash) {
                    showDialog(
                        context: context,
                        builder: (_) => new AlertDialog(
                              title: new Text("Lỗi"),
                              content: new Text(
                                  'balance: $balance\ncash: $cash\nlockCash: $lockCash'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ));
                  });
                } else {}
              },
              child: Text("Thông tin tài khoản")),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      fillColor: Colors.grey,
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "Nhập số tiền"),
                  controller: _moneyController,
                ),
              ),
              FlatButton(
                  color: Colors.blue,
                  onPressed: () async {
                    if (_moneyController.text != null) {
                      _deposit(int.parse(_moneyController.text));
                    } else {
                      showDialog(
                          context: context,
                          builder: (_) => new AlertDialog(
                                title: new Text("Lỗi"),
                                content:
                                    new Text("Vui lòng nhập user id và phone"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              ));
                    }
                  },
                  child: Text("Nạp tiền"))
            ],
          )
        ],
      ),
    );
  }
}
