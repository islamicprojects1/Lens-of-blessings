import '../../domain/entities/blessing_image.dart';

/// BlessingImageModel - Data model with JSON serialization
class BlessingImageModel extends BlessingImage {
  BlessingImageModel({
    required super.id,
    required super.localPath,
    super.cloudinaryUrl,
    required super.createdAt,
    super.isSynced,
  });

  /// Create from entity
  factory BlessingImageModel.fromEntity(BlessingImage entity) {
    return BlessingImageModel(
      id: entity.id,
      localPath: entity.localPath,
      cloudinaryUrl: entity.cloudinaryUrl,
      createdAt: entity.createdAt,
      isSynced: entity.isSynced,
    );
  }

  /// Create from JSON
  factory BlessingImageModel.fromJson(Map<String, dynamic> json) {
    return BlessingImageModel(
      id: json['id'] as String,
      localPath: json['localPath'] as String,
      cloudinaryUrl: json['cloudinaryUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localPath': localPath,
      'cloudinaryUrl': cloudinaryUrl,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  @override
  BlessingImageModel copyWith({
    String? id,
    String? localPath,
    String? cloudinaryUrl,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return BlessingImageModel(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      cloudinaryUrl: cloudinaryUrl ?? this.cloudinaryUrl,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
