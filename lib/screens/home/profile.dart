import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/services/auth.dart';
import 'package:uforuxpi3/services/database.dart';

class Profile extends StatefulWidget {
  final AppUser user;

  const Profile({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileState createState() => _ProfileState();
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
                    height: 40,
                  ),
                  MyProfile(),
                  const SizedBox(
                    height: 5,
                  ),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Hi ${loggedUser.username}!',
                        textStyle: const TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                        speed: const Duration(milliseconds: 200),
                      ),
                    ],
                    totalRepeatCount: 4,
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
                      ProfileBoxes(
                        path: "assets/images/CS.jpg",
                        carrera: loggedUser.degree ?? '',
                      ),
                      const ProfileBoxes(
                        path: "assets/images/cm5.jpeg",
                        carrera: "Gastronomia",
                      ),
                      const ProfileBoxes(
                        path: "assets/images/cm6.jpeg",
                        carrera: "Turismo",
                      ),
                      const ProfileBoxes(
                        path: "assets/images/cm8.jpeg",
                        carrera: "Economia",
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

  // ignore: non_constant_identifier_names
  Center MyProfile() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person,
          size: 65,
        ),
      ),
    );
  }
}

class ProfileBoxes extends StatelessWidget {
  final String path;
  final String carrera;
  const ProfileBoxes({super.key, required this.path, required this.carrera});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 85,
          height: 85,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(
                path,
              ),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Text(
          carrera,
          maxLines: 4,
          style: const TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
