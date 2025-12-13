class Candidature {
  final int id;
  final int candidatId;
  final int offreId;
  final String nom;
  final String prenom;
  final String? dateNaissance;
  final String? telephone;
  final String? cinImagePath;
  final String? bacImagePath;
  final Map<String, dynamic>? cinData;
  final Map<String, dynamic>? bacData;
  final String status;
  final String? commentaire;
  final DateTime createdAt;
  final DateTime updatedAt;

  Candidature({
    required this.id,
    required this.candidatId,
    required this.offreId,
    required this.nom,
    required this.prenom,
    this.dateNaissance,
    this.telephone,
    this.cinImagePath,
    this.bacImagePath,
    this.cinData,
    this.bacData,
    required this.status,
    this.commentaire,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Candidature.fromJson(Map<String, dynamic> json) {
    return Candidature(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      candidatId: json['candidat_id'] is String ? int.parse(json['candidat_id']) : json['candidat_id'],
      offreId: json['offre_id'] is String ? int.parse(json['offre_id']) : json['offre_id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      dateNaissance: json['date_naissance'],
      telephone: json['telephone'],
      cinImagePath: json['cin_image_path'],
      bacImagePath: json['bac_image_path'],
      cinData: json['cin_data'],
      bacData: json['bac_data'],
      status: json['status'] ?? 'submitted',
      commentaire: json['commentaire'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidat_id': candidatId,
      'offre_id': offreId,
      'nom': nom,
      'prenom': prenom,
      'date_naissance': dateNaissance,
      'telephone': telephone,
      'cin_image_path': cinImagePath,
      'bac_image_path': bacImagePath,
      'cin_data': cinData,
      'bac_data': bacData,
      'status': status,
      'commentaire': commentaire,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isSubmitted => status == 'submitted';
  bool get isInReview => status == 'in_review';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}
