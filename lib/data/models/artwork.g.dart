// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artwork.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtworkSearchResponse _$ArtworkSearchResponseFromJson(
  Map<String, dynamic> json,
) => ArtworkSearchResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => Artwork.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalResults: (json['totalResults'] as num?)?.toInt(),
);

Map<String, dynamic> _$ArtworkSearchResponseToJson(
  ArtworkSearchResponse instance,
) => <String, dynamic>{
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'totalResults': instance.totalResults,
};

Artwork _$ArtworkFromJson(Map<String, dynamic> json) => Artwork(
  id: json['id'] as String,
  titles: _convertDynamicToStringList(json['title']),
  creators: _convertDynamicToStringList(json['creator']),
  years: _convertDynamicToStringList(json['year']),
  previewUrl: _convertToSingleString(json['edmPreview']),
  providers: _convertDynamicToStringList(json['dataProvider']),
  countries: _convertDynamicToStringList(json['country']),
  type: _convertToSingleString(json['type']),
  descriptions: _convertDynamicToStringList(json['dcDescription']),
  link: _convertToSingleString(json['link']),
);

Map<String, dynamic> _$ArtworkToJson(Artwork instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.titles,
  'creator': instance.creators,
  'year': instance.years,
  'edmPreview': instance.previewUrl,
  'dataProvider': instance.providers,
  'country': instance.countries,
  'type': instance.type,
  'dcDescription': instance.descriptions,
  'link': instance.link,
};
