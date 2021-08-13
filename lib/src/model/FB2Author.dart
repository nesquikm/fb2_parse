class FB2Author {
  /// author's first name
  late final String? firstName;

  /// author's middle name
  late final String? middleName;

  /// author's last name
  late final String? lastName;

  /// author's nickname
  late final String? nickname;

  /// author's email
  late final String? email;

  FB2Author(String author) {
    firstName = RegExp(r"<first-name>([\s\S]+)<\/first-name>").firstMatch(author)?.group(1);
    middleName = RegExp(r"<middle-name>([\s\S]+)<\/middle-name>").firstMatch(author)?.group(1);
    lastName = RegExp(r"<last-name>([\s\S]+)<\/last-name>").firstMatch(author)?.group(1);
    nickname = RegExp(r"<nickname>([\s\S]+)<\/nickname>").firstMatch(author)?.group(1);
    email = RegExp(r"<email>([\s\S]+)<\/email>").firstMatch(author)?.group(1);
  }

  @override
  String toString() {
    return 'FB2Author(firstName: $firstName, middleName: $middleName, lastName: $lastName, nickname: $nickname, email: $email)';
  }
}
