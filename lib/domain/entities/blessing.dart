/// Blessing entity - represents a single blessing entry
class Blessing {
  final String id;
  final String imageId;
  final List<String> blessings; // Always exactly 3
  final DateTime createdAt;
  final String? userNote;
  final String language;

  Blessing({
    required this.id,
    required this.imageId,
    required this.blessings,
    required this.createdAt,
    this.userNote,
    required this.language,
  });

  Blessing copyWith({
    String? id,
    String? imageId,
    List<String>? blessings,
    DateTime? createdAt,
    String? userNote,
    String? language,
  }) {
    return Blessing(
      id: id ?? this.id,
      imageId: imageId ?? this.imageId,
      blessings: blessings ?? this.blessings,
      createdAt: createdAt ?? this.createdAt,
      userNote: userNote ?? this.userNote,
      language: language ?? this.language,
    );
  }
}
