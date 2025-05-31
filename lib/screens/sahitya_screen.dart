import 'package:flutter/material.dart';

class SahityaScreen extends StatelessWidget {
  SahityaScreen({super.key});

  final List<Map<String, String>> books = [
    {'title': 'Jain Tattva Nirnaya Praveshika', 'BY': 'Acharya Shri Ram Lal Ji', 'price': '₹135'},
    {'title': 'Samikshan Dhyan Ek Monovigyan', 'BY': 'Acharya Shri Nanesh', 'price': '₹185'},
    {'title': 'Saatveen Jheel', 'BY': 'Acharya Shri Ram Lal Ji', 'price': '₹315'},
    {'title': 'Ek Hi Kafi Hai', 'BY': 'Acharya Shri Ram Lal Ji', 'price': '₹215'},
    {'title': 'Samta Katha Mala (set of 12)', 'BY': 'Acharya Shri Nanesh', 'price': '₹740'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sahitya Collection'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        color: Colors.grey.shade100,
        padding: EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: books.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cards per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85, // thoda lamba card for overflow fix
          ),
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // important fix
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: Colors.teal,
                      size: 64, // big icon on top
                    ),
                    Text(
                      book['title'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      book['BY'] ?? '',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      book['price'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
