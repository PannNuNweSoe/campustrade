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
      appBar: AppBar(title: const Text("Post Item")),
      body: _PostForm(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          if (i == 0) context.go('/home');
          if (i == 1) context.go('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  String? _imageUrl;
  String _condition = 'New';
  bool _loading = false;

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
    final priceText = _price.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter item name')));
      return;
    }
    if (priceText.isEmpty || double.tryParse(priceText.replaceAll(',', '')) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid price')));
      return;
    }
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('items').add({
        'title': title,
        'description': _desc.text.trim(),
          'price': _price.text.trim(),
          'condition': _condition,
        'imageUrl': _imageUrl,
        'ownerUid': user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posted')));
      // Clear
      _title.clear();
      _desc.clear();
      _price.clear();
      setState(() {
        _imageUrl = null;
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Create a new listing', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Item name')),
          const SizedBox(height: 8),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          const SizedBox(height: 8),
          // Condition selector: New or Used
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
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price')),
          const SizedBox(height: 12),
          if (_imageUrl != null && _imageUrl!.isNotEmpty) Image.network(_imageUrl!, height: 140),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton(onPressed: _loading ? null : _pickAndUpload, child: const Text('Choose Image')),
            const SizedBox(width: 12),
            if (_loading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          ]),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _post, child: const Text('Post'))),
        ],
      ),
    );
  }
}
