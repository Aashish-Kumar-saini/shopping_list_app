import 'package:flutter_riverpod/legacy.dart';
import 'package:shopping_list_app/models/grocery_item.dart';



class GroceryItemsNotifer extends StateNotifier<List<GroceryItem>>{
  GroceryItemsNotifer():super([]);
bool addGroceryItem(GroceryItem item){
  if(!state.contains(item)){
  var newList = [...state, item];
  state = newList;
  return true;
  }
  return false;
}
bool removeGroceryItem(GroceryItem item){
  if(state.contains(item)){
    var newList =  state.where((element) => element.id != item.id,).toList();
    state = newList;

    return true;
  }
  return false;
}

}


final groceryItemsProvider = StateNotifierProvider<GroceryItemsNotifer,List<GroceryItem>>((ref){
  return GroceryItemsNotifer();
});