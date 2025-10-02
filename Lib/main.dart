import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<Map<String, dynamic>> restaurants = [
    {
      'name': 'Sunny Pizza',
      'menu': [
        {'name': 'Margherita', 'price': 5.99},
        {'name': 'Veggie Delight', 'price': 6.99},
      ],
    },
    {
      'name': 'Spice Corner',
      'menu': [
        {'name': 'Paneer Butter', 'price': 7.49},
        {'name': 'Chicken Biryani', 'price': 8.99},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: RestaurantListScreen(restaurants: restaurants),
    );
  }
}

class RestaurantListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> restaurants;
  RestaurantListScreen({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Restaurants')),
      body: ListView.builder(
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return ListTile(
            title: Text(restaurant['name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MenuScreen(
                    menu: restaurant['menu'],
                    restaurantName: restaurant['name'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MenuScreen extends StatefulWidget {
  final List<dynamic> menu;
  final String restaurantName;
  MenuScreen({required this.menu, required this.restaurantName});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Map<String, int> cart = {};

  double get total => cart.entries.fold(0, (sum, e) {
    final item = widget.menu.firstWhere((m) => m['name'] == e.key);
    return sum + (item['price'] * e.value);
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.restaurantName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.menu.length,
              itemBuilder: (context, index) {
                final item = widget.menu[index];
                final qty = cart[item['name']] ?? 0;
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('\$${item['price']}'),
                  trailing: qty == 0
                      ? ElevatedButton(
                          onPressed: () {
                            setState(() {
                              cart[item['name']] = 1;
                            });
                          },
                          child: Text('Add'),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (qty > 1)
                                    cart[item['name']] = qty - 1;
                                  else
                                    cart.remove(item['name']);
                                });
                              },
                            ),
                            Text(qty.toString()),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  cart[item['name']] = qty + 1;
                                });
                              },
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Text('Total: \$${total.toStringAsFixed(2)}'),
                Spacer(),
                ElevatedButton(
                  onPressed: cart.isEmpty
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Order Placed'),
                              content: Text(
                                'Your order total is \$${total.toStringAsFixed(2)}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      cart.clear();
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                  child: Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
