import 'package:portfolio_post/class/user_class.dart' show UserAbstract;

class Profile extends UserAbstract {
  @override
  final String userUid;

  @override
  final String userName;

  final String email;
  final List<String> following;

  final bool receiveNotifications;

  Profile({required this.userName, required this.userUid, required this.email, required this.following, required this.receiveNotifications});

  factory Profile.fromJson(Map<String, dynamic> json){
    List<String> _following = [];
    if (json["following"] != null) _following = List<String>.from(json["following"]);
    return Profile(
      userUid: json["userUid"].toString(),
      userName: json["name"].toString(),
      email: json["email"].toString(),
      following: _following,
      receiveNotifications: json["receiveNotifications"] ?? false,
    );
  }

  factory Profile.changeSetting(Profile p) => Profile(
    receiveNotifications: !p.receiveNotifications,
    email: p.email,
    userName: p.userName,
    userUid: p.userUid,
    following: p.following,
  );
}