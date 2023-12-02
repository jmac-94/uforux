import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:uforuxpi3/models/app_user.dart';

import 'event.dart';
/*
class Calendar extends StatefulWidget {
  final AppUser? user;

  const Calendar({super.key, required this.user});

  @override
  State<Calendar> createState() => _CalendarState();
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
*/

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime today = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  DateTime? _selectedDay;
  //Crear eventos
  Map<DateTime, List<Event>> events = {};
  //Controlador de texto de eventos
  TextEditingController _eventController = TextEditingController();
  //Visualizar si se guardo el evento
  late ValueNotifier<List<Event>> _selectedEvents;

  //funcion para seleccion dia

  @override
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay))
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  List<Event> _getEventsForDay(DateTime day) {
    //devuelve el evento guardado
    return events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: const Text('Calendario'),
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
                  Colors.blue.shade900, // Color de inicio del degradado
                  Colors.blue.shade700, // Color de fin del degradado
                ],
              ),
            ),
          ),
          shadowColor: Colors.transparent,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Show el dialogo para el usuario ponga el evento
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  scrollable: true,
                  title: Text("Event Name"),
                  content: Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _eventController,
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        //Guardar el nombre del ebento en el mapa
                        events.addAll({
                          _selectedDay!: [Event(_eventController.text)]
                        });

                        Navigator.of(context).pop();
                        _selectedEvents.value = _getEventsForDay(_selectedDay!);
                      },
                      child: Text("Submit"),
                    )
                  ],
                );
              });
        },
        child: Icon(Icons.add),
      ),
      body: content(),
    );
  }

  Widget content() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Selected Day =" + today.toString().split(" ")[0]),
            Container(
              child: TableCalendar(
                //Pesonalizacion estetica
                locale: "en_US", //idioma
                rowHeight: 43,
                headerStyle: HeaderStyle(
                    formatButtonVisible: false, titleCentered: true),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) => isSameDay(day, today),
                focusedDay: today,
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                onDaySelected: _onDaySelected,
                eventLoader: _getEventsForDay,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () => print(""),
                              title: Text("${value[index].title}"),
                            ),
                          );
                        });
                  }),
            )
          ],
        ));
  }
}
