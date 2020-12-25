
enum Environment {
  PRODUCTION,
  SANDBOX,
  TEST,
}

typedef Function OnSuccess({String key, dynamic value});
typedef Function OnError(String error);
