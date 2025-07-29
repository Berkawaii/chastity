// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtistSearchResponse _$ArtistSearchResponseFromJson(
  Map<String, dynamic> json,
) => ArtistSearchResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => Artist.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num?)?.toInt(),
);

Map<String, dynamic> _$ArtistSearchResponseToJson(
  ArtistSearchResponse instance,
) => <String, dynamic>{'items': instance.items, 'total': instance.total};

Artist _$ArtistFromJson(Map<String, dynamic> json) => Artist(
  id: json['id'] as String,
  prefLabels: (json['prefLabel'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  birthDate: json['dateOfBirth'] as String?,
  deathDate: json['dateOfDeath'] as String?,
  biographicalInfo: (json['biographicalInformation'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  imageUrl: json['isShownBy'] as String?,
  notes: (json['note'] as Map<String, dynamic>?)?.map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
);

Map<String, dynamic> _$ArtistToJson(Artist instance) => <String, dynamic>{
  'id': instance.id,
  'prefLabel': instance.prefLabels,
  'dateOfBirth': instance.birthDate,
  'dateOfDeath': instance.deathDate,
  'biographicalInformation': instance.biographicalInfo,
  'isShownBy': instance.imageUrl,
  'note': instance.notes,
};
