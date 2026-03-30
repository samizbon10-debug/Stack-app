import 'package:cloud_firestore/cloud_firestore.dart';

/// Image Model for treatment photos
class TreatmentImage {
  final String imageId;
  final String url;
  final String? localPath;
  final String label; // before, during, after
  final DateTime uploadedAt;
  final String? driveFileId;

  const TreatmentImage({
    required this.imageId,
    required this.url,
    this.localPath,
    required this.label,
    required this.uploadedAt,
    this.driveFileId,
  });

  factory TreatmentImage.fromJson(Map<String, dynamic> json) {
    return TreatmentImage(
      imageId: json['imageId'] ?? '',
      url: json['url'] ?? '',
      localPath: json['localPath'],
      label: json['label'] ?? 'before',
      uploadedAt: json['uploadedAt'] is Timestamp
          ? (json['uploadedAt'] as Timestamp).toDate()
          : DateTime.parse(json['uploadedAt']),
      driveFileId: json['driveFileId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageId': imageId,
      'url': url,
      'localPath': localPath,
      'label': label,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'driveFileId': driveFileId,
    };
  }

  TreatmentImage copyWith({
    String? imageId,
    String? url,
    String? localPath,
    String? label,
    DateTime? uploadedAt,
    String? driveFileId,
  }) {
    return TreatmentImage(
      imageId: imageId ?? this.imageId,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      label: label ?? this.label,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      driveFileId: driveFileId ?? this.driveFileId,
    );
  }
}

/// Treatment Model
class TreatmentModel {
  final String treatmentId;
  final String patientId;
  final String userId;
  final String category; // orthodontics, fillings, scaling_polishing
  final String? toothNumber;
  final List<String>? toothNumbers;
  final DateTime date;
  final String diagnosis;
  final String treatmentNotes;
  final List<String> materials;
  final String progressNotes;
  final String status; // planned, in_progress, completed
  final double? cost;
  final List<TreatmentImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool syncedToDrive;
  final String? driveFolderId;

  const TreatmentModel({
    required this.treatmentId,
    required this.patientId,
    required this.userId,
    required this.category,
    this.toothNumber,
    this.toothNumbers,
    required this.date,
    required this.diagnosis,
    required this.treatmentNotes,
    required this.materials,
    required this.progressNotes,
    required this.status,
    this.cost,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    this.syncedToDrive = false,
    this.driveFolderId,
  });

  factory TreatmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TreatmentModel(
      treatmentId: doc.id,
      patientId: data['patientId'] ?? '',
      userId: data['userId'] ?? '',
      category: data['category'] ?? 'fillings',
      toothNumber: data['toothNumber'],
      toothNumbers: data['toothNumbers'] != null
          ? List<String>.from(data['toothNumbers'])
          : null,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      diagnosis: data['diagnosis'] ?? '',
      treatmentNotes: data['treatmentNotes'] ?? '',
      materials: List<String>.from(data['materials'] ?? []),
      progressNotes: data['progressNotes'] ?? '',
      status: data['status'] ?? 'planned',
      cost: data['cost']?.toDouble(),
      images: (data['images'] as List<dynamic>?)
              ?.map((e) => TreatmentImage.fromJson(e))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      syncedToDrive: data['syncedToDrive'] ?? false,
      driveFolderId: data['driveFolderId'],
    );
  }

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      treatmentId: json['treatmentId'] ?? '',
      patientId: json['patientId'] ?? '',
      userId: json['userId'] ?? '',
      category: json['category'] ?? 'fillings',
      toothNumber: json['toothNumber'],
      toothNumbers: json['toothNumbers'] != null
          ? List<String>.from(json['toothNumbers'])
          : null,
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date']),
      diagnosis: json['diagnosis'] ?? '',
      treatmentNotes: json['treatmentNotes'] ?? '',
      materials: List<String>.from(json['materials'] ?? []),
      progressNotes: json['progressNotes'] ?? '',
      status: json['status'] ?? 'planned',
      cost: json['cost']?.toDouble(),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => TreatmentImage.fromJson(e))
              .toList() ??
          [],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt']),
      syncedToDrive: json['syncedToDrive'] ?? false,
      driveFolderId: json['driveFolderId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'treatmentId': treatmentId,
      'patientId': patientId,
      'userId': userId,
      'category': category,
      'toothNumber': toothNumber,
      'toothNumbers': toothNumbers,
      'date': Timestamp.fromDate(date),
      'diagnosis': diagnosis,
      'treatmentNotes': treatmentNotes,
      'materials': materials,
      'progressNotes': progressNotes,
      'status': status,
      'cost': cost,
      'images': images.map((e) => e.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'syncedToDrive': syncedToDrive,
      'driveFolderId': driveFolderId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'treatmentId': treatmentId,
      'patientId': patientId,
      'userId': userId,
      'category': category,
      'toothNumber': toothNumber,
      'toothNumbers': toothNumbers,
      'date': date.toIso8601String(),
      'diagnosis': diagnosis,
      'treatmentNotes': treatmentNotes,
      'materials': materials,
      'progressNotes': progressNotes,
      'status': status,
      'cost': cost,
      'images': images.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncedToDrive': syncedToDrive,
      'driveFolderId': driveFolderId,
    };
  }

  TreatmentModel copyWith({
    String? treatmentId,
    String? patientId,
    String? userId,
    String? category,
    String? toothNumber,
    List<String>? toothNumbers,
    DateTime? date,
    String? diagnosis,
    String? treatmentNotes,
    List<String>? materials,
    String? progressNotes,
    String? status,
    double? cost,
    List<TreatmentImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? syncedToDrive,
    String? driveFolderId,
  }) {
    return TreatmentModel(
      treatmentId: treatmentId ?? this.treatmentId,
      patientId: patientId ?? this.patientId,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      toothNumber: toothNumber ?? this.toothNumber,
      toothNumbers: toothNumbers ?? this.toothNumbers,
      date: date ?? this.date,
      diagnosis: diagnosis ?? this.diagnosis,
      treatmentNotes: treatmentNotes ?? this.treatmentNotes,
      materials: materials ?? this.materials,
      progressNotes: progressNotes ?? this.progressNotes,
      status: status ?? this.status,
      cost: cost ?? this.cost,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedToDrive: syncedToDrive ?? this.syncedToDrive,
      driveFolderId: driveFolderId ?? this.driveFolderId,
    );
  }

  // Get images by label
  List<TreatmentImage> get beforeImages =>
      images.where((img) => img.label == 'before').toList();
  List<TreatmentImage> get duringImages =>
      images.where((img) => img.label == 'during').toList();
  List<TreatmentImage> get afterImages =>
      images.where((img) => img.label == 'after').toList();

  @override
  String toString() {
    return 'TreatmentModel(treatmentId: $treatmentId, category: $category, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TreatmentModel && other.treatmentId == treatmentId;
  }

  @override
  int get hashCode => treatmentId.hashCode;
}
