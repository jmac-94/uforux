import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/services/auth.dart';
import 'package:uforuxpi3/services/database.dart';
import 'package:uforuxpi3/widgets/profile_box.dart';
import 'package:uforuxpi3/widgets/profile_picture.dart';

class Profile extends StatefulWidget {
  final AppUser user;

  const Profile({super.key, required this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _auth = AuthService();

  late AppUser loggedUser;

  Future<void> loadData(String id) async {
    Map<String, dynamic> userData =
        await DatabaseService(uid: id).getUserData();
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
          return Scaffold(
            appBar: AppBar(
              title: const Text('Perfil'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await _auth.signOut();
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const ProfilePicture(),
                  const SizedBox(
                    height: 5,
                  ),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Hi ${loggedUser.username}!',
                        textStyle: const TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                        speed: const Duration(milliseconds: 200),
                      ),
                    ],
                    totalRepeatCount: 2,
                    pause: const Duration(milliseconds: 1000),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    width: 340,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ProfileBox(
                        path: "assets/images/CS.jpg",
                        carrera: loggedUser.degree ?? '',
                      ),
                      ProfileBox(
                        path: "assets/images/cm5.jpeg",
                        carrera: "${loggedUser.score ?? ''}",
                      ),
                      ProfileBox(
                        path: "assets/images/cm6.jpeg",
                        carrera: loggedUser.entrySemester ?? '',
                      ),
                      ProfileBox(
                        path: "assets/images/cm8.jpeg",
                        carrera: getCarrera(),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    height: 20,
                    child: const Text(
                      "My forum",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      // physics: const BouncingScrollPhysics(),
                      children: List.generate(
                        10,
                        (index) => Container(
                          //color: Colors.primaries[index],
                          margin: const EdgeInsets.all(5.0),
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xffD3CCE3),
                                Color(0xffE9E4F0),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Foro numero $index°',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  String getCarrera() {
    if (loggedUser.assesor == true) {
      return 'Estudiante y asesor';
    } else if (loggedUser.assesor == false) {
      return 'Estudiante';
    }
    return '';
  }
}
