class User {
  int id;
  String username;
  String lastname;
  String email;
  String password;
  String createdAt;

  User({
    required this.id,
    required this.username,
    required this.lastname,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'username': username,
  //     'lastname': lastname,
  //     'email': email,
  //     'password': password,
  //     'created_at': createdAt,
  //   };
  // }

  // factory User.fromMap(Map<String, dynamic> data) {
  //   return User(
  //     id: data['id'],
  //     username: data['username'],
  //     lastname: data['lastname'],
  //     email: data['email'],
  //     password: data['password'],
  //     createdAt: data['created_at'],
  //   );
  // }
}
