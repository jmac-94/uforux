import 'package:flutter/material.dart';
import 'package:uforuxpi3/app/models/app_user.dart';
import 'package:uforuxpi3/app/widgets/common/for_you_widget.dart';
import 'package:uforuxpi3/app/widgets/common/forum_comments_widget.dart';

class Home extends StatefulWidget {
  final AppUser user;

  const Home({
    super.key,
    required this.user,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(5), // Establece la altura del TabBar
          child: Align(
            alignment:
                Alignment.topCenter, // Alinea el TabBar en la parte superior
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: const [
                Tab(text: 'Para ti'),
                Tab(text: 'Foro General'),
              ],
            ),
          ),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        centerTitle: false,
        backgroundColor: Colors.blue[800],
        shadowColor: Colors.transparent,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ForYouWidget(
            loggedUserId: widget.user.id,
          ),
          ForumCommentsWidget(
            loggedUserId: widget.user.id,
            title: 'general',
          ),
        ],
      ),
    );
  }
}
