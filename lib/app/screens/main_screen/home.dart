import 'package:flutter/material.dart';
import 'package:uforuxpi3/app/models/app_user.dart';
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
        title: const Text('Foro'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white60,
          unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(text: 'Para ti'),
            Tab(text: 'Foro General'),
          ],
        ),
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade700,
              ],
            ),
          ),
        ),
        shadowColor: Colors.transparent,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ForumCommentsWidget(
            loggedUserId: widget.user.id,
            title: 'general',
          ),
          ForumCommentsWidget(
            loggedUserId: widget.user.id,
            title: 'general', // Asume que tienes una lógica para manejar esto
          ),
        ],
      ),
    );
  }
}
