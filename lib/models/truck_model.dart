class Truck {
  int id;
  String title;
  int userId;
  String status;
  String createdAt;

  Truck({
    required this.id,
    required this.title,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'title': title,
  //     'user_id': userId,
  //     'status': status,
  //     'created_at': createdAt,
  //   };
  // }

  // factory Truck.fromMap(Map<String, dynamic> data) {
  //   return Truck(
  //     id: data['id'],
  //     title: data['title'],
  //     userId: data['user_id'],
  //     status: data['status'],
  //     createdAt: data['created_at'],
  //   );
  // }
}