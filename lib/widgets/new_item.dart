import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  String _enteredName = "";
  int _enteredQuantity = 1;
  Category _selectedCategory = categories[Categories.vegetables]!;
  bool _isSending = false;
  void submitForm() async{
    if (_formKey.currentState!.validate()){
  setState(() {_formKey.currentState!.save();});
      final item = GroceryItem(
              id: DateTime.now().microsecond.toString(),
              name: _enteredName,
              quantity: _enteredQuantity,
              category: _selectedCategory,
      );
      _isSending = true;
      final url = Uri.https('test-app-d84e6-default-rtdb.asia-southeast1.firebasedatabase.app','shopping-list.json');
     final response = await http.post(url,headers: {
        'Content-Type':  'application/json',
      },
      body: json.encode({
              'name': _enteredName,
              'quantity': _enteredQuantity,
              'category': _selectedCategory.name,
      })
      );

      final Map<String,dynamic> resData = json.decode(response.body);

      // final isAdded = ref
      //     .read(groceryItemsProvider.notifier)
      //     .addGroceryItem(
      //       item
      //     );
      // if (isAdded) {
      //   ScaffoldMessenger.of(context).clearSnackBars();
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(SnackBar(content: Text("Item added to the list")));
      // }

      if(!context.mounted){
        return;
      }
      Navigator.of(context).pop(GroceryItem(id: resData['name'], name: _enteredName, quantity: _enteredQuantity, category: _selectedCategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add a new item')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(label: Text("Name")),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Name must be between 1 to 50 characters";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(label: Text("Quantity")),
                      initialValue: "1",
                      keyboardType: .number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.parse(value) < 1) {
                          return "Quantity must be greater than 0";
                        }

                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredQuantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      initialValue: _selectedCategory,
                      items: [
                        for (var category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  color: category.value.color,
                                ),
                                SizedBox(width: 8),
                                Text(category.value.name),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending? null : () {
                      _formKey.currentState!.reset();
                    },
                    child: Text("Reset"),
                  ),
                  SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: _isSending ? null: submitForm,
                    child: _isSending? const SizedBox(width: 16, child: CircularProgressIndicator(),) : Text("Add Item"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
