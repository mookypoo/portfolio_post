class Preview {
  final String postUid;
  final String title;
  final String text;
  final String userName;
  final String? category;

  Preview({required this.postUid, required this.title, required this.text, required this.userName, required this.category});

  factory Preview.fromJson(Map<String, dynamic> json) => Preview(
    category: json["category"].toString(),
    title: json["title"].toString(),
    text: json["text"].toString(),
    postUid: json["postUid"].toString(),
    userName: json["userName"].toString(),
  );

  factory Preview.edited({required String? category, required Preview preview, required String title, required String text}) => Preview(
    text: text.substring(0, text.length > 100 ? 100 : text.length),
    title: title,
    postUid: preview.postUid,
    userName: preview.userName,
    category: category,
  );
}