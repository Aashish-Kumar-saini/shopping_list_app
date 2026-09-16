import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/data/dummy_items.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  bool _isloading = true;
  List<GroceryItem> groceryItems = [];
  String? _error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItmes();
  }

  void _loadItmes() async {
    final url = Uri.https(
      'test-app-d84e6-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list.json',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Something went wrong!. Please try again latter";
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isloading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (var items in listData.entries) {
        final category = categories.entries
            .firstWhere((cat) => cat.value.name == items.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: items.key,
            name: items.value['name'],
            quantity: items.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        groceryItems = loadedItems;
        _isloading = false;
      });
    } catch (error) {
      setState(() {
        _error = "Something went wrong!. Please try again latter";
      });
    }
  }

  void addItem() async {
    final newItem = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }
    setState(() {
      groceryItems.add(newItem);
    });
  }

  void removeItem(GroceryItem item) async {
    var index = groceryItems.indexWhere((e) => e.id == item.id);
    final url = Uri.https(
      'test-app-d84e6-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list/${item.id}.json',
    );
    try {
      var response = await http.delete(url);
      setState(() {
        groceryItems.remove(item);
      });
      if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Opps!,something went wrong!.")));
        setState(() {
          groceryItems.insert(index, item);
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Opps!,something went wrong!.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // final groceryItems = ref.watch(groceryItemsProvider);
    print("isLoading value is $_isloading");
    Widget content = ListView.builder(
      itemCount: groceryItems.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(groceryItems[index].id),
        onDismissed: (direction) {
          removeItem(groceryItems[index]);
          // final isDeleted = ref
          //     .read(groceryItemsProvider.notifier)
          //     .removeGroceryItem(groceryItems[index]);
          // if (isDeleted) {
          //   ScaffoldMessenger.of(context).clearSnackBars();
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text("Item removed from List")),
          //   );
          // }
        },
        background: Container(color: Colors.red),
        child: ListTile(
          leading: Container(
            height: 20,
            width: 20,
            color: groceryItems[index].category.color,
          ),
          title: Text(groceryItems[index].name),
          trailing: Text(groceryItems[index].quantity.toString()),
        ),
      ),
    );

    if (groceryItems.isEmpty) {
      content = Center(child: Text("No item in list . Add new item "));
    }
    if (_isloading) {
      content = Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groceries"),
        actions: [IconButton(onPressed: addItem, icon: Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
