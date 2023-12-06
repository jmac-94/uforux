import 'package:flutter/material.dart';

import 'package:uforuxpi3/app/widgets/common/forum_comments_widget.dart';

class ForumView extends StatefulWidget {
  final String loggedUserId;
  final String title;

  const ForumView({
    super.key,
    required this.loggedUserId,
    required this.title,
  });

  @override
  State<ForumView> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<ForumView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading: const BackButton(color: Colors.black),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz_outlined, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Aquí se explica un poco de lo que va el curso y qué se puede encontrar en el mismo.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Joined'),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const TabBar(
              indicatorColor: Colors.red,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'All Discussions'),
                Tab(text: 'Wikipedia'),
                Tab(text: 'Teachers'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ForumCommentsWidget(
                    loggedUserId: widget.loggedUserId,
                    title: widget.title,
                  ),
                  const Center(child: Text('Wikipedia Content')),
                  const Center(child: Text('Members Content')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
