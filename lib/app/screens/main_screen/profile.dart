import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:uforuxpi3/app/models/app_user.dart';
import 'package:uforuxpi3/app/controllers/authentication_controller.dart';
import 'package:uforuxpi3/app/controllers/app_user_controller.dart';
import 'package:uforuxpi3/core/utils/extensions.dart';

class Profile extends StatefulWidget {
  final AppUser user;

  const Profile({super.key, required this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthenticationController _auth = AuthenticationController();
  late AppUser loggedUser;

  String getUserType() {
    if (loggedUser.assesor == true) {
      return 'Estudiante y asesor';
    } else if (loggedUser.assesor == false) {
      return 'Estudiante';
    }
    return '';
  }

  Future<void> loadData(String id) async {
    Map<String, dynamic> userData =
        await AppUserController(uid: id).getUserData();
    loggedUser = AppUser.fromJson(userData);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadData(widget.user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return DefaultTabController(
            length: 2,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: Row(
                            children: [
                              const Spacer(),
                              IconButton(
                                onPressed: () async {
                                  await _auth.signOut();
                                },
                                icon: const Icon(Icons.logout),
                                iconSize: 30,
                              ),
                            ],
                          ),
                        ),
                        ClipOval(
                          child: Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[400],
                            child: Image.network(
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDVJZSsFRquEhWK_qlau6Lr6jN4hLhkzSmyg&usqp=CAU',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                      ),
                      child: Text(
                        loggedUser.username.toString().capitalize(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      //${loggedUser.entrySemester ?? ''} -
                      loggedUser.degree.toString().capitalize(),
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                const SizedBox(height: 4),
                                Text.rich(
                                  TextSpan(
                                    text: getUserType(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Rango',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                const SizedBox(height: 4),
                                RatingBar.builder(
                                  initialRating: loggedUser.score ?? 0,
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star_rate_rounded,
                                    color: Colors.amber,
                                  ),
                                  itemSize: 35,
                                  ignoreGestures: true,
                                  onRatingUpdate: (rating) {},
                                ),
                                const Text(
                                  'Score',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                const SizedBox(height: 4),
                                Text.rich(
                                  TextSpan(
                                    text: loggedUser.entrySemester,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Ciclo de ingreso',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 130,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200],
                          ),
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Editar perfil',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 130,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blueAccent[400],
                          ),
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Seguir',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    const TabBar(
                      indicatorColor: Colors.red,
                      labelColor: Colors.red,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: 'Mi Foro'),
                        Tab(text: 'Sobre mi'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Center(
                            child: Center(
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
                            child: Text('Contenido sobre mi'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
