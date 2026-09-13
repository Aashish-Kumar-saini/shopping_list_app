import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_app/data/dummy_items.dart';
import 'package:shopping_list_app/providers/grocery_items_proivder.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends ConsumerStatefulWidget {
  const GroceryList({super.key});

  @override
  ConsumerState<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends ConsumerState<GroceryList> {
  void addItem() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const NewItem()));
  }

  @override
  Widget build(BuildContext context) {
    final groceryItems = ref.watch(groceryItemsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groceries"),
        actions: [IconButton(onPressed: addItem, icon: Icon(Icons.add))],
      ),
      body: groceryItems.isEmpty
          ? Center(child: Text("No item in list . Add new item "))
          : ListView.builder(
              itemCount: groceryItems.length,
              itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(groceryItems[index].id),
                onDismissed: (direction) {
                  final isDeleted = ref
                      .read(groceryItemsProvider.notifier)
                      .removeGroceryItem(groceryItems[index]);
                  if (isDeleted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Item removed from List")),
                    );
                  }
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
            ),
    );
  }
}
