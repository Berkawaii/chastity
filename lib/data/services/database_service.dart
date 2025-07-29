import 'dart:convert';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/collection.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'europeana_museum.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        artwork_data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE collections (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        artwork_ids TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        cover_image_url TEXT
      )
    ''');
  }

  // Favorites methods
  Future<bool> addFavorite(String artworkId, Map<String, dynamic> artworkData) async {
    try {
      final db = await database;
      await db.insert('favorites', {
        'id': artworkId,
        'artwork_data': jsonEncode(artworkData),
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } catch (e) {
      log('Error adding favorite: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(String artworkId) async {
    try {
      final db = await database;
      await db.delete('favorites', where: 'id = ?', whereArgs: [artworkId]);
      return true;
    } catch (e) {
      log('Error removing favorite: $e');
      return false;
    }
  }

  Future<bool> isFavorite(String artworkId) async {
    try {
      final db = await database;
      final result = await db.query('favorites', where: 'id = ?', whereArgs: [artworkId]);
      return result.isNotEmpty;
    } catch (e) {
      log('Error checking favorite: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final db = await database;
      final results = await db.query('favorites', orderBy: 'created_at DESC');
      return results.map((row) {
        final artworkData = jsonDecode(row['artwork_data'] as String);
        return {'id': row['id'], 'data': artworkData, 'createdAt': row['created_at']};
      }).toList();
    } catch (e) {
      log('Error getting favorites: $e');
      return [];
    }
  }

  // Collections methods
  Future<bool> saveCollection(Collection collection) async {
    try {
      final db = await database;
      await db.insert('collections', {
        'id': collection.id,
        'title': collection.title,
        'description': collection.description,
        'artwork_ids': jsonEncode(collection.artworkIds),
        'created_at': collection.createdAt.toIso8601String(),
        'updated_at': collection.updatedAt.toIso8601String(),
        'cover_image_url': collection.coverImageUrl,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } catch (e) {
      log('Error saving collection: $e');
      return false;
    }
  }

  Future<bool> deleteCollection(String collectionId) async {
    try {
      final db = await database;
      await db.delete('collections', where: 'id = ?', whereArgs: [collectionId]);
      return true;
    } catch (e) {
      log('Error deleting collection: $e');
      return false;
    }
  }

  Future<List<Collection>> getCollections() async {
    try {
      final db = await database;
      final results = await db.query('collections', orderBy: 'updated_at DESC');
      return results.map((row) {
        return Collection(
          id: row['id'] as String,
          title: row['title'] as String,
          description: row['description'] as String,
          artworkIds: List<String>.from(jsonDecode(row['artwork_ids'] as String)),
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: DateTime.parse(row['updated_at'] as String),
          coverImageUrl: row['cover_image_url'] as String?,
        );
      }).toList();
    } catch (e) {
      log('Error getting collections: $e');
      return [];
    }
  }

  Future<Collection?> getCollection(String collectionId) async {
    try {
      final db = await database;
      final results = await db.query('collections', where: 'id = ?', whereArgs: [collectionId]);

      if (results.isEmpty) {
        return null;
      }

      final row = results.first;
      return Collection(
        id: row['id'] as String,
        title: row['title'] as String,
        description: row['description'] as String,
        artworkIds: List<String>.from(jsonDecode(row['artwork_ids'] as String)),
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
        coverImageUrl: row['cover_image_url'] as String?,
      );
    } catch (e) {
      log('Error getting collection: $e');
      return null;
    }
  }
}
