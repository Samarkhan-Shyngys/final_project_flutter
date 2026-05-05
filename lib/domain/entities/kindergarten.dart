class Kindergarten {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String adminId;
  final DateTime createdAt;

  const Kindergarten({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.adminId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'address': address,
    'phone': phone,
    'adminId': adminId,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Kindergarten.fromMap(Map<String, dynamic> m) => Kindergarten(
    id: m['id'] as String,
    name: m['name'] as String,
    address: m['address'] as String,
    phone: m['phone'] as String,
    adminId: m['adminId'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
  );
}
