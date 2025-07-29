import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

@JsonSerializable()
class ArtistSearchResponse {
  @JsonKey(name: 'items')
  final List<Artist>? items;

  @JsonKey(name: 'total')
  final int? total;

  ArtistSearchResponse({this.items, this.total});

  factory ArtistSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$ArtistSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistSearchResponseToJson(this);
}

@JsonSerializable()
class Artist {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'prefLabel')
  final Map<String, String>? prefLabels;

  @JsonKey(name: 'dateOfBirth')
  final String? birthDate;

  @JsonKey(name: 'dateOfDeath')
  final String? deathDate;

  @JsonKey(name: 'biographicalInformation')
  final List<Map<String, dynamic>>? biographicalInfo;

  @JsonKey(name: 'isShownBy')
  final String? imageUrl;

  @JsonKey(name: 'note')
  final Map<String, List<String>>? notes;

  Artist({
    required this.id,
    this.prefLabels,
    this.birthDate,
    this.deathDate,
    this.biographicalInfo,
    this.imageUrl,
    this.notes,
  });

  String get name {
    if (prefLabels?.isNotEmpty == true) {
      // Try to get English label first, or use the first available
      return prefLabels!['en'] ?? prefLabels!.values.first;
    }
    return 'Unknown';
  }

  String get biography {
    if (biographicalInfo?.isNotEmpty == true) {
      for (var info in biographicalInfo!) {
        if (info.containsKey('prefLabel') && info['prefLabel'] is Map) {
          var prefLabel = info['prefLabel'] as Map;
          if (prefLabel.containsKey('en')) {
            return prefLabel['en'];
          } else if (prefLabel.values.isNotEmpty) {
            return prefLabel.values.first;
          }
        }
      }
    }
    return 'No biographical information available.';
  }

  String get lifespan {
    if (birthDate != null && deathDate != null) {
      return '$birthDate - $deathDate';
    } else if (birthDate != null) {
      return 'Born: $birthDate';
    } else if (deathDate != null) {
      return 'Died: $deathDate';
    }
    return 'Unknown lifespan';
  }

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}
