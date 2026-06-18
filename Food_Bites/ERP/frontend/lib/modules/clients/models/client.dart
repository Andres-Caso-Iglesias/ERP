class Client {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String status;

  Client({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
    };
  }
}