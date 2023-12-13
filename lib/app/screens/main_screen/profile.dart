import 'dart:io';

import 'package:awesome_icons/awesome_icons.dart';
import 'package:flutter/material.dart';

import 'package:forux/app/models/app_user.dart';
import 'package:forux/app/controllers/authentication_controller.dart';
import 'package:forux/app/controllers/app_user_controller.dart';
import 'package:forux/app/widgets/profile/my_forum_widget.dart';
import 'package:forux/core/utils/dprint.dart';
import 'package:forux/core/utils/extensions.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  final AppUser user;
  final String loggedUserId;

  const Profile({
    super.key,
    required this.user,
    required this.loggedUserId,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthenticationController _auth = AuthenticationController();
  late AppUserController appUserController;
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
    try {
      loggedUser = (await AppUserController(uid: id).getUserData())!;
      appUserController = AppUserController(uid: widget.user.id);
      appUserController.appUser = loggedUser;
    } catch (e) {
      dPrint(e);
    }
  }

  //TODO Seria buenazo agregar una imagen que el usuario pueda subir de modo de presentarte en su perfil
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
            length: 3,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: widget.loggedUserId == widget.user.id
                              ? Row(
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
                                )
                              : Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.arrow_back),
                                      iconSize: 30,
                                    ),
                                  ],
                                ),
                        ),
                        // Profile photo
                        Stack(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: FutureBuilder<Image>(
                                        future:
                                            appUserController.getProfilePhoto(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<Image> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            return snapshot.data!;
                                          }
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              child: ClipOval(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[400],
                                  child: FutureBuilder<Image>(
                                    future: appUserController.getProfilePhoto(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<Image> snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        return snapshot.data!;
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            if (widget.loggedUserId == widget.user.id)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    final picker = ImagePicker();
                                    final XFile? pickedFile =
                                        await picker.pickImage(
                                      source: ImageSource.gallery,
                                    );

                                    if (pickedFile != null) {
                                      File imageFile = File(pickedFile.path);
                                      await appUserController
                                          .updateProfilePhoto(imageFile);
                                    } else {
                                      dPrint(
                                          'No se seleccionó ninguna imagen.');
                                    }
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ), // Empty container when condition is not met
                          ],
                        )
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
                      loggedUser.degree.toString().capitalize(),
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (widget.loggedUserId == widget.user.id)
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
                      indicatorColor: Colors.blueAccent,
                      labelColor: Colors.blueAccent,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: 'Mi foro'),
                        Tab(text: 'Sobre mí'),
                        Tab(text: 'Logros')
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          MyForumWidget(loggedUser: loggedUser),
                          ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 16.0,
                                ),
                                child: Text(
                                  loggedUser.username.toString().capitalize(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  getUserType(),
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.instagram),
                                  SizedBox(width: 25),
                                  Icon(FontAwesomeIcons.linkedin),
                                  SizedBox(width: 25),
                                  Icon(FontAwesomeIcons.github),
                                ],
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
                                  Text(
                                    'Ciclo de ingreso',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20.0,
                                  horizontal: 30.0,
                                ),
                                child: Center(
                                  child: Text(
                                    loggedUser.aboutMe.toString(),
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ListView(
                            children: const [
                              Card(
                                elevation: 0.1,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Icon(FontAwesomeIcons.check,
                                            color: Colors.green),
                                      ), // Asume que existe un ícono de copa
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Contenido de calidad',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Obten 10 pdf verificados',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 0.1,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Icon(FontAwesomeIcons.star,
                                            color: Colors.yellow),
                                      ), // Asume que existe un ícono de copa
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text('Maestro en la ayuda',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                'Consigue 100 puntos de reputación',
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 0.1,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Icon(FontAwesomeIcons.book,
                                            color: Colors.red),
                                      ), // Asume que existe un ícono de copa
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Entusiasta del conocimiento',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Sigues 10 foros diferentes',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
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
