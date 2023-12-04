import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  final String title;
  Event(this.title);
}

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
  final TextEditingController _eventController = TextEditingController();
  //Visualizar si se guardo el evento
  late ValueNotifier<List<Event>> _selectedEvents;

  //funcion para seleccion dia

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
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
                  title: const Text("Event Name"),
                  content: Padding(
                    padding: const EdgeInsets.all(8),
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
                      child: const Text("Submit"),
                    )
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
      body: content(),
    );
  }

  Widget content() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Selected Day =${today.toString().split(" ")[0]}"),
            TableCalendar(
              //Pesonalizacion estetica
              locale: "en_US", //idioma
              rowHeight: 43,
              headerStyle: const HeaderStyle(
                  formatButtonVisible: false, titleCentered: true),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, today),
              focusedDay: today,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              onDaySelected: _onDaySelected,
              eventLoader: _getEventsForDay,
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              // ignore: avoid_print
                              onTap: () => print(""),
                              title: Text(value[index].title),
                            ),
                          );
                        });
                  }),
            )
          ],
        ));
  }
}
