class User {
  String email;
  bool sendMarketing;

  User(this.email, this.sendMarketing);

  Map<String, dynamic> toJson() => {
        'email': email,
        'sendMarketing': sendMarketing
      };
}
