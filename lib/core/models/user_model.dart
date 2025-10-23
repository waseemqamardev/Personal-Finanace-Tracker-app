class UserModel {
  int? id;
  String name;
  String email;
  String password;
  String? token;
  String? avatar;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.token,
    this.avatar,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'token': token,
    'avatar': avatar,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'],
    name: map['name'],
    email: map['email'],
    password: map['password'],
    token: map['token'],
    avatar: map['avatar'],
  );
}
