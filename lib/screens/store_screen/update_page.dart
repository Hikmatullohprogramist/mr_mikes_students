// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mr_mikes_students/service/students_service.dart';

class UpdateProductScreen extends StatefulWidget {
  final Function(String, num, num, String?) onUpdate;
  final String name;
  final String img;
  final num amount;
  final num price;

  const UpdateProductScreen(
      {required this.onUpdate,
      super.key,
      required this.name,
      required this.img,
      required this.amount,
      required this.price});

  @override
  _UpdateProductScreenState createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  File? _imgUrl;
  String successDownloadImgurl = "";
  String status = "No uploaded";
  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _priceController.dispose();
    _imgUrl = null;
    successDownloadImgurl = "";
    super.dispose();
  }

  @override
  initState() {
    _nameController.text = widget.name;
    _amountController.text = widget.amount.toString();
    _priceController.text = widget.price.toString();
    _imgUrl = null;
    successDownloadImgurl = widget.img;
    super.initState();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onUpdate(
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
      referenceToUploadImage
          .putFile(_imgUrl!)
          .snapshotEvents
          .listen((taskSnapshot) {
        setState(() {
          switch (taskSnapshot.state) {
            case TaskState.running:
              status = "Image upload running ...";
              break;
            case TaskState.paused:
              status = "Image upload paused";
              break;
            case TaskState.success:
              status = "Image upload done";
              break;
            case TaskState.canceled:
              status = "Image upload cancelled";
              break;
            case TaskState.error:
              status = "Image upload error";
              break;
          }
        });
      });

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
      appBar: AppBar(title: Text("Update product")),
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
              _imgUrl != null
                  ? Image.file(
                      _imgUrl!,
                      height: 200,
                    )
                  : Image.network(successDownloadImgurl),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              Text(status),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
