abstract class AuthAbstract {
  final String email = "";
  final String pw = "";
}

class SignUpInfo extends AuthAbstract {
  final String name;

  final bool isMale;

  @override
  final String email;

  @override
  final String pw;

  SignUpInfo({required this.name, required this.isMale, required this.email, required this.pw});

  Map<String, String> toJson(){
    return {
      "name": this.name,
      "gender": this.isMale ? "M" : "F",
      "email": this.email,
      "created": DateTime.now().toIso8601String(),
    };
  }
}

class LoginInfo extends AuthAbstract {
  @override
  final String email;

  @override
  final String pw;

  LoginInfo({required this.email, required this.pw});
}

class AuthInfo {
  final String userUid;
  final String idToken;

  AuthInfo({required this.userUid, required this.idToken});
}


