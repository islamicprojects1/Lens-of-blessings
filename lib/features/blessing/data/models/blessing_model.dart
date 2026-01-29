import 'package:lens_of_blessings/features/blessing/domain/entities/blessing.dart';

/// BlessingModel - Data model with JSON serialization
class BlessingModel extends Blessing {
  BlessingModel({
    required super.id,
    required super.imageId,
    required super.blessings,
    required super.createdAt,
    super.userNote,
    super.userId,
    super.imageUrl,
    required super.language,
    super.aiModel,
  });

  /// Create from entity
  factory BlessingModel.fromEntity(Blessing entity) {
    return BlessingModel(
      id: entity.id,
      imageId: entity.imageId,
      blessings: entity.blessings,
      createdAt: entity.createdAt,
      userNote: entity.userNote,
      userId: entity.userId,
      imageUrl: entity.imageUrl,
      language: entity.language,
      aiModel: entity.aiModel,
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
      userId: json['userId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      language: json['language'] as String,
      aiModel: json['aiModel'] as String?,
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
      'userId': userId,
      'imageUrl': imageUrl,
      'language': language,
      'aiModel': aiModel,
    };
  }

  @override
  BlessingModel copyWith({
    String? id,
    String? imageId,
    List<String>? blessings,
    DateTime? createdAt,
    String? userNote,
    String? userId,
    String? imageUrl,
    String? language,
    String? aiModel,
  }) {
    return BlessingModel(
      id: id ?? this.id,
      imageId: imageId ?? this.imageId,
      blessings: blessings ?? this.blessings,
      createdAt: createdAt ?? this.createdAt,
      userNote: userNote ?? this.userNote,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      language: language ?? this.language,
      aiModel: aiModel ?? this.aiModel,
    );
  }
}
