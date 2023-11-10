import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import 'package:uforuxpi3/models/app_user.dart';

class Calendar extends StatefulWidget {
  final AppUser? user;

  const Calendar({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  String userId = '';
  final _ratingController = TextEditingController();
  double _userRating = 4.5;
  String? dropdown;

  final GFBottomSheetController _controller = GFBottomSheetController();

  @override
  void initState() {
    super.initState();
    _ratingController.text = '4.5';
    userId = widget.user!.id;
  }

  @override
  Widget build(BuildContext context) {
    double rating = 3;

    return Scaffold(
      bottomSheet: GFBottomSheet(
        animationDuration: 300,
        controller: _controller,
        maxContentHeight: 150,
        stickyHeaderHeight: 100,
        stickyHeader: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 0)]),
          child: const GFListTile(
            avatar: GFAvatar(
              backgroundImage: AssetImage('assets image here'),
            ),
            titleText: 'GetWidget',
            subTitleText: 'Open source UI library',
          ),
        ),
        contentBody: Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: ListView(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            children: const [
              Center(
                  child: Text(
                'Getwidget reduces your overall app development time to minimum 30% because of its pre-build clean UI widget that you can use in flutter app development. We have spent more than 1000+ hours to build this library to make flutter developer’s life easy.',
                style: TextStyle(
                    fontSize: 15, wordSpacing: 0.3, letterSpacing: 0.2),
              ))
            ],
          ),
        ),
        stickyFooter: Container(
          color: GFColors.SUCCESS,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Get in touch',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                'info@getwidget.dev',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ],
          ),
        ),
        stickyFooterHeight: 50,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GFColors.SUCCESS,
        child: _controller.isBottomSheetOpened
            ? const Icon(Icons.keyboard_arrow_down)
            : const Icon(Icons.keyboard_arrow_up),
        onPressed: () {
          _controller.isBottomSheetOpened
              ? _controller.hideBottomSheet()
              : _controller.showBottomSheet();
        },
      ),
      appBar: AppBar(
        title: const Text(
          'Calendario',
        ),
      ),
      backgroundColor: Colors.redAccent,
      body: SafeArea(
        child: Column(
          children: [
            GFRating(
              value: rating,
              filledIcon: const Icon(Icons.flip_camera_ios),
              defaultIcon: const Icon(Icons.flip_camera_ios_outlined),
              onChanged: (value) => setState(() {
                rating = value;
              }),
            ),
            GFRating(
              value: _userRating,
              showTextForm: true,
              controller: _ratingController,
              suffixIcon: GFButton(
                type: GFButtonType.transparent,
                onPressed: () {
                  setState(() {
                    _userRating = double.parse(_ratingController.text);
                  });
                },
                child: const Text('Rate'),
              ),
              onChanged: (double rating) {},
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width / 2,
              margin: const EdgeInsets.all(10),
              child: DropdownButtonHideUnderline(
                child: GFDropdown(
                  borderRadius: BorderRadius.circular(5),
                  border: const BorderSide(color: Colors.black12, width: 1),
                  dropdownButtonColor: Colors.white,
                  value: dropdown,
                  onChanged: (newValue) {
                    setState(() {
                      dropdown = newValue;
                    });
                  },
                  items: [
                    'FC Barcelona',
                    'Real Madrid',
                    'Villareal',
                    'Manchester City'
                  ]
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
