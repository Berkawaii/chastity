import 'package:uuid/uuid.dart';

class Collection {
  final String id;
  final String title;
  final String description;
  final List<String> artworkIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverImageUrl;

  Collection({
    String? id,
    required this.title,
    required this.description,
    List<String>? artworkIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.coverImageUrl,
  }) : id = id ?? const Uuid().v4(),
       artworkIds = artworkIds ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Collection copyWith({
    String? title,
    String? description,
    List<String>? artworkIds,
    String? coverImageUrl,
  }) {
    return Collection(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      artworkIds: artworkIds ?? this.artworkIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }

  // Add artwork to collection
  Collection addArtwork(String artworkId) {
    if (artworkIds.contains(artworkId)) {
      return this;
    }

    return copyWith(artworkIds: [...artworkIds, artworkId]);
  }

  // Remove artwork from collection
  Collection removeArtwork(String artworkId) {
    if (!artworkIds.contains(artworkId)) {
      return this;
    }

    return copyWith(artworkIds: artworkIds.where((id) => id != artworkId).toList());
  }

  // Convert to Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'artworkIds': artworkIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'coverImageUrl': coverImageUrl,
    };
  }

  // Create from Map (for storage)
  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      artworkIds: List<String>.from(json['artworkIds']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      coverImageUrl: json['coverImageUrl'],
    );
  }
}
