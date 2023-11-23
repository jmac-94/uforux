import 'package:flutter/material.dart';

import 'package:uforuxpi3/models/app_user.dart';
import 'package:uforuxpi3/services/auth.dart';
import 'package:uforuxpi3/services/database.dart';

class Profile extends StatefulWidget {
  final AppUser user;

  const Profile({super.key, required this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _auth = AuthService();
  late AppUser loggedUser;

  String getCarrera() {
    if (loggedUser.assesor == true) {
      return 'Estudiante y asesor';
    } else if (loggedUser.assesor == false) {
      return 'Estudiante';
    }
    return '';
  }

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
          return Stack(
            children: [
              Image.network(
                'https://t4.ftcdn.net/jpg/02/69/55/51/360_F_269555125_Mb9weWCa02FTezkzK36jjDHsSNOZxvN9.jpg',
                fit: BoxFit.cover,
                width: 400,
                height: 200,
              ),
              SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[400],
                                  child: const Icon(
                                      Icons.stacked_bar_chart_outlined),
                                ),
                              ),
                              const SizedBox(
                                width: 50,
                              ),
                              ClipOval(
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[400],
                                  child: Image.network(
                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDVJZSsFRquEhWK_qlau6Lr6jN4hLhkzSmyg&usqp=CAU',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 50,
                              ),
                              ClipOval(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[400],
                                  child:
                                      const Icon(Icons.edit_calendar_rounded),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Center(
                        child: Text(
                          loggedUser.username ?? '',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'About me:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  loggedUser.degree ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  loggedUser.entrySemester ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  getCarrera(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          'Seguidores',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text.rich(
                                          TextSpan(
                                            text: '23',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            // Aquí puedes agregar más TextSpans si necesitas más partes con estilo diferente
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
                                        Text(
                                          'Siguiendo',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text.rich(
                                          TextSpan(
                                            text: '10',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            // Y de nuevo, más TextSpans si necesitas más personalizaciones
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color:
                                            Colors.grey[300]!), // Border color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 8),
                                    child: Text(
                                      'Editar perfil',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Text(
                          'Foros',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: List.generate(
                            10,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
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
              ),
            ],
          );
        }
      },
    );
  }
}
