import 'dart:developer' as dev;
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

part 'artwork.g.dart';

@JsonSerializable(explicitToJson: true)
class ArtworkSearchResponse {
  @JsonKey(name: 'items')
  final List<Artwork>? items;

  @JsonKey(name: 'totalResults')
  final int? totalResults;

  ArtworkSearchResponse({this.items, this.totalResults});

  factory ArtworkSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$ArtworkSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ArtworkSearchResponseToJson(this);
}

@JsonSerializable()
class Artwork {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title', fromJson: _convertDynamicToStringList)
  final List<String>? titles;

  @JsonKey(name: 'creator', fromJson: _convertDynamicToStringList)
  final List<String>? creators;

  @JsonKey(name: 'year', fromJson: _convertDynamicToStringList)
  final List<String>? years;

  @JsonKey(name: 'edmPreview', fromJson: _convertToSingleString)
  final String? previewUrl;

  @JsonKey(name: 'dataProvider', fromJson: _convertDynamicToStringList)
  final List<String>? providers;

  @JsonKey(name: 'country', fromJson: _convertDynamicToStringList)
  final List<String>? countries;

  @JsonKey(name: 'type', fromJson: _convertToSingleString)
  final String? type;

  @JsonKey(name: 'dcDescription', fromJson: _convertDynamicToStringList)
  final List<String>? descriptions;

  @JsonKey(name: 'link', fromJson: _convertToSingleString)
  final String? link;

  Artwork({
    required this.id,
    this.titles,
    this.creators,
    this.years,
    this.previewUrl,
    this.providers,
    this.countries,
    this.type,
    this.descriptions,
    this.link,
  });

  String get mainTitle => titles?.isNotEmpty == true ? titles!.first : 'Untitled';
  String get mainCreator {
    // Enhanced creator extraction with logging
    if (creators == null) {
      dev.log('creators field is null');
      return 'Unknown Artist';
    }
    if (creators!.isEmpty) {
      dev.log('creators list is empty');
      return 'Unknown Artist';
    }
    dev.log('Using creator: ${creators!.first}');
    return creators!.first;
  }

  String get mainYear => years?.isNotEmpty == true ? years!.first : 'Unknown Date';
  String get mainDescription =>
      descriptions?.isNotEmpty == true ? descriptions!.first : 'No description available';

  factory Artwork.fromJson(Map<String, dynamic> json) => _$ArtworkFromJson(json);

  Map<String, dynamic> toJson() => _$ArtworkToJson(this);
}

// Helper method to convert dynamic JSON values to List<String>
// This handles cases where API returns either a String, a List<dynamic>, or a nested structure
List<String>? _convertDynamicToStringList(dynamic value) {
  if (value == null) {
    return null;
  }

  // log the type and value for debugging
  dev.log('_convertDynamicToStringList: value type is ${value.runtimeType}');
  dev.log(
    '_convertDynamicToStringList: value content is ${value.toString().substring(0, min(100, value.toString().length))}...',
  );

  // If it's already a string, clean it up and wrap it in a list
  if (value is String) {
    String cleanValue = value;
    // If string contains format like "painting (oil): ["Self Portrait"]", extract just the title
    if (cleanValue.contains('["') && cleanValue.contains('"]')) {
      final match = RegExp(r'.*\["(.*)"\].*').firstMatch(cleanValue);
      if (match != null && match.groupCount >= 1) {
        cleanValue = match.group(1) ?? cleanValue;
      }
    }
    return [cleanValue];
  }

  // If it's a list, convert each element to a string
  if (value is List) {
    try {
      return value
          .map((item) {
            if (item == null) return '';

            // Handle nested structures with 'def' fields
            if (item is Map && item.containsKey('def')) {
              var def = item['def'];
              if (def is String) return def;
              if (def is List) return def.join(', ');
              return item.toString();
            }

            String result = item.toString();

            // Clean up formatting issues in the string representation
            if (result.contains('["') && result.contains('"]')) {
              final match = RegExp(r'.*\["(.*)"\].*').firstMatch(result);
              if (match != null && match.groupCount >= 1) {
                result = match.group(1) ?? result;
              }
            }

            return result;
          })
          .toList()
          .cast<String>();
    } catch (e) {
      dev.log('Error converting list to string list: $e');
      // Fallback if there's an issue with the cast
      return value.map((item) => item?.toString() ?? '').toList();
    }
  }

  // If it's a map with 'def' field (some Europeana responses use this format)
  if (value is Map && value.containsKey('def')) {
    var def = value['def'];
    if (def is String) return [def];
    if (def is List) return def.map((e) => e.toString()).toList().cast<String>();
  }

  // Fallback: convert to string and return as single element list
  return [value.toString()];
}

// Helper method to convert various formats to a single string
String? _convertToSingleString(dynamic value) {
  if (value == null) {
    return null;
  }

  // log the type for debugging
  dev.log('_convertToSingleString: value type is ${value.runtimeType}');

  // If it's already a string, return it
  if (value is String) {
    return value;
  }

  // If it's a list, return the first element as string
  if (value is List && value.isNotEmpty) {
    try {
      return value.first?.toString() ?? '';
    } catch (e) {
      dev.log('Error converting first list item to string: $e');
      return '';
    }
  }

  // If it's a map with 'def' field
  if (value is Map && value.containsKey('def')) {
    var def = value['def'];
    if (def is String) return def;
    if (def is List && def.isNotEmpty) return def.first.toString();
  }

  // Fallback: convert to string
  return value.toString();
}
