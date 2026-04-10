import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/item_image.dart';
import '../../core/wishlist_store.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        title: const Text('My Wishlist'),
      ),
      body: ValueListenableBuilder<List<WishlistItem>>(
        valueListenable: WishlistStore.wishlistItems,
        builder: (context, wishlist, _) {
          if (wishlist.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No items in wishlist yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any item to save it here',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: wishlist.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = wishlist[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.go('/item/${item.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ItemImage(
                            imageUrl: item.imageUrl,
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(10),
                            placeholderColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                            iconSize: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.price,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.category,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
