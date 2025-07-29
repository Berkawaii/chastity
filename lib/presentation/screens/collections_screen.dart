import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/collection.dart';
import '../providers/local_provider.dart';
import '../widgets/loading_indicator.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CollectionProvider>(context, listen: false).loadCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final collectionProvider = Provider.of<CollectionProvider>(context);
    final collections = collectionProvider.collections;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Collections',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
              tooltip: 'Create new collection',
              onPressed: () => _showCreateCollectionDialog(context),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await collectionProvider.loadCollections();
        },
        child: collectionProvider.isLoading
            ? const Center(child: LoadingIndicator())
            : collectionProvider.error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading collections: ${collectionProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : collections.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'You haven\'t created any collections yet.\n\nClick the + button in the top right to create your own art collections.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  return _buildCollectionCard(context, collections[index]);
                },
              ),
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, Collection collection) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/collection', arguments: collection.id);
        },
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image if available
            if (collection.coverImageUrl != null)
              Image.network(
                collection.coverImageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 160,
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    child: Center(
                      child: Icon(
                        Icons.collections_outlined,
                        size: 48,
                        color: theme.colorScheme.primary.withOpacity(0.4),
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                height: 160,
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                child: Center(
                  child: Icon(
                    Icons.collections_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  ),
                ),
              ),

            // Collection info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          collection.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onBackground,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${collection.artworkIds.length} artworks',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    collection.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () => _showEditCollectionDialog(context, collection),
                        tooltip: 'Edit',
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => _showDeleteCollectionDialog(context, collection),
                        tooltip: 'Delete',
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.errorContainer.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCollectionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Koleksiyon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Koleksiyon Adı'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Açıklama'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();

              if (title.isNotEmpty) {
                Provider.of<CollectionProvider>(
                  context,
                  listen: false,
                ).createCollection(title, description);
                Navigator.pop(context);
              }
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  void _showEditCollectionDialog(BuildContext context, Collection collection) {
    final titleController = TextEditingController(text: collection.title);
    final descriptionController = TextEditingController(text: collection.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Koleksiyonu Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Koleksiyon Adı'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Açıklama'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();

              if (title.isNotEmpty) {
                final updatedCollection = collection.copyWith(
                  title: title,
                  description: description,
                );

                Provider.of<CollectionProvider>(
                  context,
                  listen: false,
                ).updateCollection(updatedCollection);
                Navigator.pop(context);
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCollectionDialog(BuildContext context, Collection collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Koleksiyonu Sil'),
        content: Text(
          '"${collection.title}" adlı koleksiyonu silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              Provider.of<CollectionProvider>(
                context,
                listen: false,
              ).deleteCollection(collection.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
