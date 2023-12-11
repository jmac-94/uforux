import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uforuxpi3/core/utils/dprint.dart';

import 'event.dart';

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
  //selecionar por horas
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime =
      TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

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
      appBar: AppBar(
        title: const Text("Calendario",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            )),
        centerTitle: false,
        backgroundColor: Colors.blue[800],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                title: const Text("Event name"),
                content: Column(
                  children: [
                    TextField(
                      controller: _eventController,
                    ),
                    //selector de hora de inicio
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                            context: context, initialTime: _startTime);
                        if (picked != null && picked != _startTime) {
                          setState(() {
                            _startTime = picked;
                          });
                        }
                      },
                      child: Text("Star Time: ${_startTime.format(context)}"),
                    ),
                    //selectector de hora de fin
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );
                        if (picked != null && picked != _endTime) {
                          setState(() {
                            _endTime = picked;
                          });
                        }
                      },
                      child: Text("End Time :${_endTime.format(context)}"),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      //Agregar el evento con hora de inicio y fin
                      if (!events.containsKey(_selectedDay)) {
                        events[_selectedDay!] = [];
                      }
                      events[_selectedDay!]!.add(
                          Event(_eventController.text, _startTime, _endTime));
                      _eventController.clear();
                      _selectedEvents.value = _getEventsForDay(_selectedDay!);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Submit"),
                  ),
                ],
              );
            },
          );
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
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                              onTap: () =>
                                  dPrint("Event: ${value[index].title}"),
                              title: Text(
                                  "${value[index].title} (${value[index].starTime.format(context)} - ${value[index].endtime.format(context)})"),
                            ),
                          );
                        });
                  }),
            )
          ],
        ));
  }
}
