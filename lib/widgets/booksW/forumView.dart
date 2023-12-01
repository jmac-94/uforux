import 'package:flutter/material.dart';
import 'package:faker/faker.dart';

void main() {
  runApp(const MaterialApp(
    home: DetailScreen(
      title: 'View',
    ),
  ));
}

class DetailScreen extends StatelessWidget {
  final String title;

  const DetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Número de tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading:
              const BackButton(color: Colors.black), // Botón para volver atrás

          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz_outlined, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Aca se explica un poco de lo que va el curso y que se puede encontrar en el mismo.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Joined'),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.grey),
                  ),
                ],
              ),
            ),
            const TabBar(
              indicatorColor: Colors.red,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'All Discussions'),
                Tab(text: 'Wikipedia'),
                Tab(text: 'Members'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Center(
                    child: Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: List.generate(
                          10,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 2,
                            ),
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                            ),
                            child: Image.network(
                              'https://random.imagecdn.app/500/${faker.randomGenerator.integer(1000)}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text('Wikipedia Content'),
                  ),
                  const Center(
                    child: Text('Members Content'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
