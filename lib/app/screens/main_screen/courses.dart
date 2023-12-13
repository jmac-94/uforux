import 'dart:typed_data';

import 'package:awesome_icons/awesome_icons.dart';
import 'package:flutter/material.dart';

import 'package:forux/app/models/app_user.dart';
import 'package:forux/app/widgets/courses/card_book.dart';
import 'package:forux/app/widgets/courses/eventW.dart';
import 'package:forux/app/widgets/courses/wikipedia.dart';
import 'package:url_launcher/url_launcher.dart';

class Courses extends StatefulWidget {
  final AppUser user;

  const Courses({
    super.key,
    required this.user,
  });

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  final Uint8List kTransparentImage = Uint8List.fromList([
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
  ]);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          top: false,
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: AppBar(
                  title: const Text('Cursos'),
                  titleTextStyle: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  centerTitle: false,
                  actions: [
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                  ],
                  backgroundColor: Colors.blue[800],
                  shadowColor: Colors.transparent,
                ),
              ),
              body: Column(
                children: [
                  const SizedBox(height: 15.0),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.45,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        const SizedBox(width: 10.0),
                        CardBook(
                          loggedUserId: widget.user.id,
                          color: Colors.red,
                          image: 'assets/images/calculoDeUnaVariable.jpg',
                          title: 'Cálculo de una variable',
                        ),
                        const SizedBox(width: 10.0),
                        CardBook(
                          loggedUserId: widget.user.id,
                          color: Colors.blue,
                          image: 'assets/images/laboratorioDeComunicacion1.jpg',
                          title: 'Laboratorio de comunicación 1',
                        ),
                        const SizedBox(width: 10.0),
                        CardBook(
                          loggedUserId: widget.user.id,
                          color: Colors.green,
                          image:
                              'assets/images/proyectosInterdisciplinarios1.jpg',
                          title: 'Proyectos interdisciplinarios 1',
                        ),
                        const SizedBox(width: 10.0),
                        CardBook(
                          loggedUserId: widget.user.id,
                          color: Colors.green,
                          image: 'assets/images/algebraLineal.jpg',
                          title: 'Álgebra lineal',
                        ),
                      ],
                    ),
                  ),
                  // const Align(
                  //   alignment: Alignment.centerLeft,
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(
                  //       horizontal: 14.0,
                  //       vertical: 5.0,
                  //     ),
                  //     child: Text(
                  //       'Tendencias',
                  //       style: TextStyle(
                  //           fontSize: 20.0,
                  //           fontWeight: FontWeight.w700,
                  //           color: Colors.black),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 50,
                  //   child: ListView(
                  //     scrollDirection: Axis.horizontal,
                  //     children: [
                  //       const SizedBox(width: 10.0),
                  //       Container(
                  //         width: MediaQuery.of(context).size.width * 0.4,
                  //         height: 50,
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(10.0),
                  //           color: Colors.black,
                  //         ),
                  //         child: const Center(
                  //           child: Text(
                  //             '#Ayuda en ADA',
                  //             style: TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 18.0,
                  //               fontWeight: FontWeight.w500,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(width: 10.0),
                  //       Container(
                  //         width: MediaQuery.of(context).size.width * 0.4,
                  //         height: 50,
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(10.0),
                  //           color: Colors.black,
                  //         ),
                  //         child: const Center(
                  //           child: Text(
                  //             '#Mejoras en espacios Abiertos',
                  //             style: TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 15.0,
                  //               fontWeight: FontWeight.w500,
                  //             ),
                  //             textAlign: TextAlign.center,
                  //             maxLines: 2,
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(width: 10.0),
                  //       Container(
                  //         width: MediaQuery.of(context).size.width * 0.4,
                  //         height: 50,
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(10.0),
                  //           color: Colors.black,
                  //         ),
                  //         child: const Center(
                  //           child: Text(
                  //             '#Finales ADA',
                  //             style: TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 15.0,
                  //               fontWeight: FontWeight.w500,
                  //             ),
                  //             textAlign: TextAlign.center,
                  //             maxLines: 2,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const TabBar(
                    indicatorColor: Colors.blueAccent,
                    labelColor: Colors.blueAccent,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Eventos'),
                      Tab(text: 'Malla Curricular'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView(
                          children: const [
                            SizedBox(height: 16.0),
                            EventWidget(
                              time: "Hoy, 9:15 - 10:30 AM",
                              title: "Entrenamiento de diseño de Hopin",
                              evento: "Reunion virtual",
                              url:
                                  'https://plus.unsplash.com/premium_photo-1672354234377-38ef695dd2ed?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8ZXZlbnR8ZW58MHx8MHx8fDA%3DZ',
                              icon: FontAwesomeIcons.video,
                            ),
                            SizedBox(height: 16.0),
                            EventWidget(
                              time: "Hoy, 10:30 - 11:30 AM",
                              title: "Charla Utec Ventures programa Incuva",
                              evento: "Coordinacion por whatsapp",
                              url:
                                  'https://images.unsplash.com/photo-1561489396-888724a1543d?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGV2ZW50fGVufDB8fDB8fHww',
                              icon: FontAwesomeIcons.whatsapp,
                            ),
                            SizedBox(height: 16.0),
                            EventWidget(
                              time: "Hoy, 11:30 - 12:30 AM",
                              title: "Presentacion de proyectos de ADA",
                              evento: "Reunion virtual",
                              url:
                                  'https://images.unsplash.com/photo-1501504905252-473c47e087f8?q=80&w=3474&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                              icon: FontAwesomeIcons.skype,
                            ),
                          ],
                        ),
                        const Expanded(
                          child: CourseSchedule(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
