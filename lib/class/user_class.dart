class UserAbstract {
  final String userUid = "";
  final String userName = "";
}

class User extends UserAbstract {
  @override
  final String userUid;

  @override
  final String userName;

  final String idToken;

  User({required this.userUid, required this.userName, required this.idToken});

  Map<String, dynamic> toJson() => {
    "userUid": this.userUid,
    "idToken": this.idToken,
  };

  Map<String, dynamic> toJsonWithName() => {
    "userUid": this.userUid,
    "idToken": this.idToken,
    "userName": this.userName,
  };
}

class Author extends UserAbstract {
  @override
  final String userUid;

  @override
  final String userName;

  Author({required this.userName, required this.userUid});

  factory Author.fromJson(Map<String, dynamic> info) => Author(
    userUid: info["userUid"].toString(),
    userName: info["userName"].toString(),
  );

  Map<String, String> toJson() => {
    "userUid": this.userUid,
    "userName": this.userName,
  };

  factory Author.fromUser(User user) => Author(
      userName: user.userName,
      userUid: user.userUid
  );
}
