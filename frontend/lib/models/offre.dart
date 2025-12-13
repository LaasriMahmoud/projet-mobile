class Offre {
  final int id;
  final String titre;
  final String description;
  final String? typeFormation;
  final String? duree;
  final String? conditions;
  final String status;
  final int adminId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Offre({
    required this.id,
    required this.titre,
    required this.description,
    this.typeFormation,
    this.duree,
    this.conditions,
    required this.status,
    required this.adminId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Offre.fromJson(Map<String, dynamic> json) {
    return Offre(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      typeFormation: json['type_formation'],
      duree: json['duree'],
      conditions: json['conditions'],
      status: json['status'] ?? 'pending',
      adminId: json['admin_id'] is String ? int.parse(json['admin_id']) : (json['admin_id'] ?? 0),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'type_formation': typeFormation,
      'duree': duree,
      'conditions': conditions,
      'status': status,
      'admin_id': adminId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isValidated => status == 'validated';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
}
