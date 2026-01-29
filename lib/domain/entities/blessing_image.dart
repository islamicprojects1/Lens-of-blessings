/// BlessingImage entity - represents an image associated with blessings
class BlessingImage {
  final String id;
  final String localPath;
  final String? cloudinaryUrl;
  final DateTime createdAt;
  final bool isSynced;

  BlessingImage({
    required this.id,
    required this.localPath,
    this.cloudinaryUrl,
    required this.createdAt,
    this.isSynced = false,
  });

  BlessingImage copyWith({
    String? id,
    String? localPath,
    String? cloudinaryUrl,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return BlessingImage(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      cloudinaryUrl: cloudinaryUrl ?? this.cloudinaryUrl,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
