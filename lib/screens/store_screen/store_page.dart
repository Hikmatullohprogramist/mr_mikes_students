// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mr_mikes_students/constantas/const.dart';
import 'package:mr_mikes_students/main.dart';
import 'package:mr_mikes_students/screens/store_screen/add_page.dart';
import 'package:mr_mikes_students/screens/store_screen/update_page.dart';

import '../../model/store_model.dart';
import '../../service/students_service.dart';
import 'info_screen.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  AppService appService = AppService();

  openProductAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddProductScreen(onAdd: (name, amount, price, imgUrl) {
          StoreModel addedItem = StoreModel(
            productName: name,
            amount: amount,
            price: price,
            img: imgUrl,
            createdAt: Timestamp.now(),
          );

          return appService.addStoreItem(addedItem);
        });
      },
    );
  }

  openProductUpdateDialog(StoreModel data, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateProductScreen(
          onUpdate: (name, amount, price, img) {
            StoreModel copyData = data.copyWith(
                productName: name, amount: amount, price: price, img: img);
            appService.updateStoreItem(
              copyData,
              id,
            );
          },
          name: data.productName,
          img: data.img,
          amount: data.amount,
          price: data.price,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isMike
          ? FloatingActionButton(
              onPressed: () {
                openProductAddDialog();
              },
              child: const Icon(Icons.add))
          : null,
      backgroundColor: AppConstants.appColor,
      body: Container(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                    flex: 2,
                    child: Container(
                      color: AppConstants.appColor,
                    )),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 17),
                      const Text(
                        "Mr. Mike's market",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildStoreGrid(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteItem(String index) {
    appService.deleteStoreItem(index);
  }

  Widget _buildStoreGrid() {
    return StreamBuilder(
        key: UniqueKey(),
        stream: appService.getStoreItems(),
        builder: (ctx, snapshot) {
          List<dynamic> products = snapshot.data?.docs ?? [];

          if (products.isNotEmpty) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisExtent: 300),
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                StoreModel item = products[index].data();
                String id = products[index].id;

                return _buildCard(item, id);
              },
            );
          } else {
            return const Center(
              child: Text(
                "No products",
                style: TextStyle(fontSize: 22),
              ),
            );
          }
        });
  }

  _buildCard(StoreModel item, String id) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductInfoScreen(
              name: item.productName,
              amount: item.amount,
              price: item.price,
              imageUrl: item.img,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.productName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 120,
                margin: item.img == "" ? EdgeInsets.all(20) : null,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: item.img != ""
                        ? NetworkImage(item.img) as ImageProvider
                        : AssetImage(
                            "assets/no-image.png",
                          ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  "${item.price} Coin",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  item.amount.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ]),
              isMike
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => openProductUpdateDialog(item, id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteItem(id),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () {},
                      child: Text('Buy'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
