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

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    final token = await PaymeFlutter.generateToken("123", "0334345979");
    print(token);
    final isInited = await payMe.init(
        appId: _appId,
        publicKey: _publickey,
        appPrivateKey: _appPrivateKey,
        env: Environment.SANDBOX,
        connectToken: token,
        colors: [Color(0xFF75255B), Color(0xFF9d455f)]);
    payMe.openWallet();
    // final isConnected = await payMe.isConnected;
    // print(isConnected);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(),
      ),
    );
  }
}
