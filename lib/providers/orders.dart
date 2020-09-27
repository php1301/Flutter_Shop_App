import 'dart:convert';

import 'package:Shop_App/providers/cart.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;
  Orders(this.authToken, this.userId, this._orders);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://flutter-shop-app-763cf.firebaseio.com/orders/$userId.json?auth=$authToken';
    // const url = 'https://flutter-shop-app-763cf.firebaseio.com/orders.json';
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) return;
    final List<OrderItem> loadedOrders = [];
    extractedData.forEach((orderId, value) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: value['amount'],
          products: (value['products']
                  as List<dynamic>) // convert to list de co map method
              .map((e) => CartItem(
                    id: e['id'],
                    title: e['title'],
                    price: e['price'],
                    quantity: e['quantity'],
                  ))
              .toList(),
          dateTime: DateTime.parse(value['dateTime']),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://flutter-shop-app-763cf.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp =
        DateTime.now(); // avoid time cua order local va server khac nhau
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'products': cartProducts
              .map((e) => {
                    // Firebase chi nhan map
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList(),
          'dateTime': timestamp.toIso8601String(),
        }),
      );
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['id'],
          amount: total,
          products: cartProducts,
          dateTime: timestamp,
        ),
      );
    } catch (e) {
      throw e;
    }
  }
}
