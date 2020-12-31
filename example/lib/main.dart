import 'dart:math';

import 'package:flutter/material.dart';

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
      """--- BEGIN SSH2 PUBLIC KEY ----Comment: "rsa-key-20201008"AAAAB3NzaC1yc2EAAAABJQAAAEEAi8guoakL0/cLH3tJPWdmPUTIhsCVjctg/rLi7A8vVFJGdKAxpBLxUVPXxYt3Fu86PlsT4Arll8qLcg0wEUS4PQ==---- END SSH2 PUBLIC KEY ----""";

  final _appPrivateKey = """-----BEGIN RSA PRIVATE KEY-----
MIICWgIBAAKBgF22s6t6BLihEkRroHduR9J0PO1slI4XNrpWhnNM9AestacLah2S
UAMavR6bChz4iqZZpehylXqgvPiRrdx6ggZ5eV4RJJ9ZlOSbw5Jasot8aAqEEmRM
wBsvMcwTPGShytGJ8Ftyg2CaKY8d1cBAQLIjEFYbo9cySCRzuklhxpCVAgMBAAEC
gYA+Ledws3lGd7kDJNZH6ChHf1CdyBmZXdW2NYroHfsczH+K4ov6KwZjyO4KzJwd
NNvqHDl0zfJYdyZrV12gmLiEfahQlF4trzjT4LuEhDTysZI2dMYupMAdurOv5ZGS
AYyxvWDYEgzMxcehmOAoWWZACkFHdDcdnUBmjQj06P290QJBAJ3sYH6YnC7xLOGw
mgoiEmQgHjQaUXxMnOvbT7hco+ZNQCc8CHtt6YSDHdOAV49cAPuXslU2F5j0tTw7
f1IkamsCQQCX6eCyjqNEaSgp40av4bMav40iO7uedtKTNRQAoER+XX+eFFkSIusk
UZl8Pzf7kzpY2HM7Z4tXfrHmFvNmxbD/AkAygwKyO1npYda7MWNzzkYXpHZEsA5U
NaUTg4hSLb920EquwfLsl9FTQyTtG2XmQsVFs9Wkj7Koh8zYQSeOPHuVAkAEEWxF
+9HddB9yN7bd4OJl9fk2kHjuvmnXLVWyypfq9mADgLH97Vd0qoa8sAi0wPWQCYPU
dGpj1m23Jqgv+V1LAkBib6xmeOrgjg0FqN6y05YAB/ug48956seOz3gRYtKEjFYu
PxEwdo4oskUeS4T8zhRJx1QL0Wq4EMTjLw1GlHif
-----END RSA PRIVATE KEY-----""";
  final _appId =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MiwiaWF0IjoxNjAyMTQ2MDkwfQ._c1tjxnxcGURZNcNd2sUp_faiuP28cGeSKclzQ_Jyes";
  final payMe = PaymeFlutter();

  final _userIdTextController = TextEditingController();
  final _phoneTextController = TextEditingController();

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

  Future<bool> _initPayMe(String appId, String publicKey,
      String appPrivateKey, String connectToken) async {
    return await payMe.init(
        appId: _appId,
        publicKey: _publickey,
        appPrivateKey: _appPrivateKey,
        env: Environment.SANDBOX,
        connectToken: connectToken,
        colors: [Color(0xFF75255B), Color(0xFF9d455f)]);
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
                      await _initPayMe(
                          _appId, _publickey, _appPrivateKey, token);
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
              child: Text("Mở ví"))
        ],
      ),
    );
  }
}
