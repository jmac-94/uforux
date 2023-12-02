import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/widgets/booksW/book.dart';

class Books extends StatefulWidget {
  final AppUser user;

  const Books({
    super.key,
    required this.user,
  });

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              centerTitle: false,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              title: const Text(
                'Cursos',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
                textAlign: TextAlign.left,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
            body: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      SizedBox(width: 10.0),
                      CardBook(
                        color: Colors.red,
                        image:
                            'https://images.unsplash.com/photo-1581092583537-20d51b4b4f1b?q=80&w=3687&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        title: 'Cálculo de una variable',
                      ),
                      SizedBox(width: 10.0),
                      CardBook(
                        color: Colors.blue,
                        image:
                            'https://images.unsplash.com/photo-1486825586573-7131f7991bdd?q=80&w=3238&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        title: 'Laboratorio de comunicación 1',
                      ),
                      SizedBox(width: 10.0),
                      CardBook(
                        color: Colors.green,
                        image:
                            'https://images.unsplash.com/photo-1551033406-611cf9a28f67?q=80&w=3687&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        title: 'Proyectos interdisciplinarios 1',
                      ),
                      SizedBox(width: 10.0),
                      CardBook(
                        color: Colors.green,
                        image:
                            'https://images.unsplash.com/photo-1581092163144-b7ae3c00adbc?q=80&w=3687&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        title: 'Álgebra lineal',
                      ),
                    ],
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 5.0,
                    ),
                    child: Text(
                      'Tendencias',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      const SizedBox(width: 10.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.black,
                        ),
                        child: const Center(
                          child: Text(
                            '#Ayuda en ADA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.black,
                        ),
                        child: const Center(
                          child: Text(
                            '#Mejoras en espacios Abiertos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.black,
                        ),
                        child: const Center(
                          child: Text(
                            '#Finales ADA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      'Eventos',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 10.0,
                        ),
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.red,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                                'https://random.imagecdn.app/500/${faker.randomGenerator.integer(1000)}'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
