import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/dummy_items.dart';

class HomeScreen extends StatelessWidget {
const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(title: Text("Your Groceries")),
      body: ListView.builder( itemCount: groceryItems.length  , itemBuilder: (ctx, index)=> ListTile(leading: Container(height: 20,width: 20, color:groceryItems[index].category.color ,),title: Text(groceryItems[index].name),trailing: Text(groceryItems[index].quantity.toString()),), ),
    );
  }
}