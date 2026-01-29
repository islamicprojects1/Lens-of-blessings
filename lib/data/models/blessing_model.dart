import '../../domain/entities/blessing.dart';

/// BlessingModel - Data model with JSON serialization
class BlessingModel extends Blessing {
  BlessingModel({
    required super.id,
    required super.imageId,
    required super.blessings,
    required super.createdAt,
    super.userNote,
    required super.language,
  });

  /// Create from entity
  factory BlessingModel.fromEntity(Blessing entity) {
    return BlessingModel(
      id: entity.id,
      imageId: entity.imageId,
      blessings: entity.blessings,
      createdAt: entity.createdAt,
      userNote: entity.userNote,
      language: entity.language,
    );
  }

  /// Create from Firestore document
  factory BlessingModel.fromJson(Map<String, dynamic> json) {
    return BlessingModel(
      id: json['id'] as String,
      imageId: json['imageId'] as String,
      blessings: List<String>.from(json['blessings'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      userNote: json['userNote'] as String?,
      language: json['language'] as String,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageId': imageId,
      'blessings': blessings,
      'createdAt': createdAt.toIso8601String(),
      'userNote': userNote,
      'language': language,
    };
  }

  @override
  BlessingModel copyWith({
    String? id,
    String? imageId,
    List<String>? blessings,
    DateTime? createdAt,
    String? userNote,
    String? language,
  }) {
    return BlessingModel(
      id: id ?? this.id,
      imageId: imageId ?? this.imageId,
      blessings: blessings ?? this.blessings,
      createdAt: createdAt ?? this.createdAt,
      userNote: userNote ?? this.userNote,
      language: language ?? this.language,
    );
  }
}
