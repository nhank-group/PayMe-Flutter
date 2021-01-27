import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:payme_flutter/payme_flutter.dart';

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
  final _publickey =
      """
    -----BEGIN PUBLIC KEY-----
    MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKWcehEELB4GdQ4cTLLQroLqnD3AhdKi
    wIhTJpAi1XnbfOSrW/Ebw6h1485GOAvuG/OwB+ScsfPJBoNJeNFU6J0CAwEAAQ==
    -----END PUBLIC KEY-----
    """;

  final _appPrivateKey = """
    -----BEGIN RSA PRIVATE KEY-----
    MIIBOwIBAAJBAOkNeYrZOhKTS6OcPEmbdRGDRgMHIpSpepulZJGwfg1IuRM+ZFBm
    F6NgzicQDNXLtaO5DNjVw1o29BFoK0I6+sMCAwEAAQJAVCsGq2vaulyyI6vIZjkb
    5bBId8164r/2xQHNuYRJchgSJahHGk46ukgBdUKX9IEM6dAQcEUgQH+45ARSSDor
    mQIhAPt81zvT4oK1txaWEg7LRymY2YzB6PihjLPsQUo1DLf3AiEA7Tv005jvNbNC
    pRyXcfFIy70IHzVgUiwPORXQDqJhWJUCIQDeDiZR6k4n0eGe7NV3AKCOJyt4cMOP
    vb1qJOKlbmATkwIhALKSJfi8rpraY3kLa4fuGmCZ2qo7MFTKK29J1wGdAu99AiAQ
    dx6DtFyY8hoo0nuEC/BXQYPUjqpqgNOx33R4ANzm9w==
    -----END RSA PRIVATE KEY-----
    """;
  final _appToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6Njg2OH0.JyIdhQEX_Lx9CXRH4iHM8DqamLrMQJk5rhbslNW4GzY";
  final payMe = PaymeFlutter();

  final _userIdTextController = TextEditingController(text: "123");
  final _phoneTextController = TextEditingController(text:"0334345979");

  @override
  void initState() {
    super.initState();
  }

  Future<String> _generateToken(String userId, String phone) async {
    final token = await PaymeFlutter.generateToken(userId, phone);
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

  Future<bool> _initPayMe(String appToken, String publicKey, String appPrivateKey,
      String connectToken) async {
    return await payMe.init(
        appToken: appToken,
        publicKey: publicKey,
        appPrivateKey: appPrivateKey,
        env: Environment.SANDBOX,
        connectToken: connectToken,
        colors: [Color(0xFF75255B), Color(0xFF9d455f)]);
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
                  child: Text("Tạo token"))
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
              child: Text("Thông tin tài khoảng"))
        ],
      ),
    );
  }
}
