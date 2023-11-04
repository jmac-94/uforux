import 'package:uforuxpi3/models/app_user.dart';

class ProfileController {
  AppUser? user;
  Map<String, dynamic>? data;

  ProfileController({this.user});

  Future<void> getData() async {
    if (user != null) {
      await user!.loadData();
      data = user!.data;
      // Any additional processing can be done here if needed
    }
  }
}
