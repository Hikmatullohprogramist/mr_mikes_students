// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mr_mikes_students/service/students_service.dart';

class AddProductScreen extends StatefulWidget {
  final Function(String, num, num, String?) onAdd;

  const AddProductScreen({required this.onAdd, Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  File? _imgUrl;
  String successDownloadImgurl = "";

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(
        _nameController.text,
        num.parse(_amountController.text),
        num.parse(_priceController.text),
        successDownloadImgurl,
      );

      Navigator.of(context).pop();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference refrenceRoot = FirebaseStorage.instance.ref();
    Reference refrenceDirImages = refrenceRoot.child(STORE_IMAGES_COLLECTION);
    Reference referenceToUploadImage = refrenceDirImages.child(uniqueFileName);

    try {
      await referenceToUploadImage.putFile(_imgUrl!);
      successDownloadImgurl = await referenceToUploadImage.getDownloadURL();

      print(successDownloadImgurl);
    } catch (e) {
      print(e);
    }

    if (pickedFile != null) {
      setState(() {
        _imgUrl = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add product to market'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Product amount'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product amount';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Product price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              if (_imgUrl != null)
                Image.file(
                  _imgUrl!,
                  height: 200,
                ),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
