import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostItemScreen extends StatelessWidget {
  const PostItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        title: const Text("Post Item"),
      ),
      body: _PostForm(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          if (i == 0) context.go('/home');
          if (i == 2) context.go('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _PostForm extends StatefulWidget {
  @override
  State<_PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<_PostForm> {
  static const List<String> _categories = [
    'Food',
    'Electronics',
    'Clothes',
    'Shoes',
    'Books',
    'Beauty',
    'Other',
  ];
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  String? _imageUrl;
  String _category = 'Other';
  String _condition = 'New';
  bool _loading = false;

  InputDecoration _fieldDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      prefixIcon: Icon(
        prefixIcon,
        color: colorScheme.primary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.22),
          width: 1.0,
        ),
      ),
    );
  }

  String? _normalizePriceInput(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return null;

    var normalized = clean.replaceAll(',', '').trim();
    normalized = normalized
        .replaceAll('฿', '')
        .replaceAll('บาท', '')
      .replaceAll(RegExp(r'\bthb\b', caseSensitive: false), '')
        .trim();

    if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(normalized)) {
      return null;
    }

    final parsed = num.tryParse(normalized);
    if (parsed == null) return null;
    final amount = parsed % 1 == 0 ? parsed.toInt().toString() : parsed.toString();
    return '$amount THB';
  }

  Future<void> _pickAndUpload() async {
    if (_loading) return;
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile == null) return;
      
      final bytes = await pickedFile.readAsBytes();
      print('DEBUG: File picked, size: ${bytes.length} bytes');
      
      // Check file size (max 2MB for base64)
      if (bytes.length > 2 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image size must be less than 2MB')),
          );
        }
        return;
      }
      
      if (!mounted) return;
      setState(() => _loading = true);
      
      try {
        // Convert to base64
        final base64String = base64Encode(bytes);
        print('DEBUG: Image converted to base64, length: ${base64String.length}');
        
        setState(() => _imageUrl = 'data:image/png;base64,$base64String');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image selected successfully')),
        );
      } catch (e) {
        print('DEBUG: Error: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process image: $e')),
        );
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      print('DEBUG: File picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _post() async {
    final title = _title.text.trim();
    final description = _desc.text.trim();
    final priceText = _price.text.trim();
    final normalizedPrice = _normalizePriceInput(priceText);
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter item name')));
      return;
    }
    if (normalizedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid price (e.g. 300 THB)')));
      return;
    }
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final ownerEmail = user?.email ?? '';
      final ownerName =
          (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
          ? user.displayName!.trim()
          : (ownerEmail.contains('@')
                ? ownerEmail.split('@').first
                : 'Campus Seller');

      await FirebaseFirestore.instance.collection('items').add({
        'title': title,
        'description': description,
        'price': normalizedPrice,
        'category': _category,
        'condition': _condition,
        'imageUrl': _imageUrl,
        'ownerUid': user?.uid,
        'ownerName': ownerName,
        'ownerEmail': ownerEmail,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posted')));
      // Clear
      _title.clear();
      _desc.clear();
      _price.clear();
      setState(() {
        _imageUrl = null;
        _category = 'Other';
        _condition = 'New';
      });
      if (!mounted) return;
      GoRouter.of(context).go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final extraBottomSpace = media.padding.bottom + media.viewPadding.bottom + 96;

    return SafeArea(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 16, 16, extraBottomSpace),
        children: [
          Text('Create a new listing', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: _fieldDecoration(
              labelText: 'Item name',
              hintText: 'e.g. Wireless Headphones',
              prefixIcon: Icons.inventory_2_outlined,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: _fieldDecoration(
              labelText: 'Category',
              hintText: 'Select category',
              prefixIcon: Icons.category_outlined,
            ),
            items: _categories
                .map((category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _category = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            decoration: _fieldDecoration(
              labelText: 'Description',
              hintText: 'Describe item condition and usage',
              prefixIcon: Icons.description_outlined,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Text(
            'Condition',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Radio<String>(value: 'New', groupValue: _condition, onChanged: (v) => setState(() => _condition = v!)),
                  title: const Text('New'),
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Radio<String>(value: 'Used', groupValue: _condition, onChanged: (v) => setState(() => _condition = v!)),
                  title: const Text('Used'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _price,
            keyboardType: TextInputType.text,
            decoration: _fieldDecoration(
              labelText: 'Price (THB)',
              hintText: 'e.g. 850 THB',
              prefixIcon: Icons.account_balance_wallet_outlined,
            ),
          ),
          const SizedBox(height: 12),
          if (_imageUrl != null && _imageUrl!.isNotEmpty) Image.network(_imageUrl!, height: 140),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton(onPressed: _loading ? null : _pickAndUpload, child: const Text('Choose Image')),
            const SizedBox(width: 12),
            if (_loading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          ]),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Items are exchanged in person on campus. No online payment.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _post, child: const Text('Post Item'))),
        ],
      ),
    );
  }
}
