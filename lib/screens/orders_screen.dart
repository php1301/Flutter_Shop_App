import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Su dung khi nhieu state logic phuc tap cause re render
  // Tranh viec re render do cac state khac trong cung 1 widget lam anh huong,
  // Cac state khac co the cause re-render => Nhan future moi va rebuild lai chi vi 1 thay doi nho
  // Solution: Bind vo initState
  Future _ordersFuture;
  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    super.initState();
    _ordersFuture = _obtainOrdersFuture();
  }

  @override
  Widget build(BuildContext context) {
    // Su dung FutureBuilder ket hop Consumer de trang rebuilding vi infinite loop
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // check loading;
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.error != null) {
              // Handle error
              return Center(
                child: Text('Errors Occurred'),
              );
            } else {
              return Consumer<Orders>(
                  builder: (context, orderData, child) => ListView.builder(
                        // static child
                        itemCount: orderData.orders.length,
                        itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                      ));
            }
          }
        },
      ),
    );
  }
}
