class UserModel {
  final String userID;
  final String password;
  final String? name;
  final String? phoneNumber;
  final String? email;
  final String? company;
  final String? department;
  final String? position;
  final String? responsibilities;
  final String? role;

  UserModel({
    required this.userID,
    required this.password,
    this.name,
    this.phoneNumber,
    this.email,
    this.company,
    this.department,
    this.position,
    this.responsibilities,
    this.role,
  });

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'password': password,
    'name': name,
    'phoneNumber': phoneNumber,
    'email': email,
    'company': company,
    'department': department,
    'position': position,
    'responsibilities' : responsibilities,
    'role': role,
  };
}
