class UserModel {
  late String? uid;
  final String name;
  final String email;
  final String cpf;
  final String phoneNumber;
  final String password;
  final String birthDate;
  late DateTime? createdAt;

  UserModel({
    this.uid,
    required this.name,
    required this.email,
    required this.cpf,
    required this.password,
    required this.phoneNumber,
    required this.birthDate,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'cpf': cpf,
    'phoneNumber': phoneNumber,
    'birthDate': birthDate,
    'createdAt': createdAt,
  };
}
