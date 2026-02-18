import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';
import 'dart:html' as html; // web-only file picker
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  bool _loading = false;

  Future<void> _pickAndUpload() async {
    // Web file picker
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();
    uploadInput.onChange.listen((_) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;
      final file = files.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      final result = reader.result;
      if (result == null) return;
      final bytes = (result as ByteBuffer).asUint8List();
      setState(() => _loading = true);
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('items')
            .child('${DateTime.now().millisecondsSinceEpoch}_${file.name}');
        await ref.putData(bytes);
        final url = await ref.getDownloadURL();
        setState(() => _imageUrl = url);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      } finally {
        setState(() => _loading = false);
      }
    });
  }

  Future<void> _post() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final doc = await FirebaseFirestore.instance.collection('items').add({
        'title': title,
        'description': _desc.text.trim(),
        'price': _price.text.trim(),
        'imageUrl': _imageUrl,
        'ownerUid': user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posted')));
      // Clear
      _title.clear();
      _desc.clear();
      _price.clear();
      setState(() => _imageUrl = null);
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
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price')),
          const SizedBox(height: 12),
          if (_imageUrl != null && _imageUrl!.isNotEmpty) Image.network(_imageUrl!, height: 140),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton(onPressed: _pickAndUpload, child: const Text('Choose Image')),
            const SizedBox(width: 12),
            if (_loading) const CircularProgressIndicator()
          ]),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _post, child: const Text('Post'))),
        ],
      ),
    );
  }
}
