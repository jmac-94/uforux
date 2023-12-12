import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/event.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final DateTime today = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Crear eventos
  Map<DateTime, List<Event>> events = {};
  // Controlador de texto de eventos
  final TextEditingController _eventController = TextEditingController();
  // Visualizar si se guardo el evento
  late ValueNotifier<List<Event>> _selectedEvents;

  // Selecionar por horas
  TimeOfDay _startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 23, minute: 59);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

  // Funcion para seleccion dia
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Devuelve los eventos guardados en en el dia day
    return events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
      ),
      body: content(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _startTime = TimeOfDay.now();
          _endTime = _startTime.replacing(hour: _startTime.hour + 1);

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Crear nuevo evento'),
                content: Column(
                  children: [
                    // Caja de texto input
                    TextField(
                      controller: _eventController,
                      decoration: const InputDecoration(
                        hintText: 'Nombre del evento',
                      ),
                    ),

                    // Selector de hora de inicio
                    ElevatedButton(
                      child: Text('Inicio: ${_startTime.format(context)}'),
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );

                        if (picked != null && picked != _startTime) {
                          setState(() {
                            _startTime = picked;
                          });
                        }
                      },
                    ),

                    // Selector de hora de fin
                    ElevatedButton(
                      child: Text('Fin: ${_endTime.format(context)}'),
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
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      // Agregar el evento con hora de inicio y fin
                      if (!events.containsKey(_selectedDay)) {
                        events[_selectedDay] = [];
                      }

                      events[_selectedDay]!.add(
                        Event(
                          title: _eventController.text,
                          startTime: _startTime,
                          endTime: _endTime,
                        ),
                      );

                      _eventController.clear();

                      _selectedEvents.value = _getEventsForDay(_selectedDay);

                      Navigator.of(context).pop();
                    },
                    child: const Text('Crear'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget content() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Boton para ir al dia de hoy
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                setState(() {
                  _focusedDay = DateTime.now();
                });
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.today),
                  SizedBox(width: 2.0),
                  Text('Hoy'),
                ],
              ),
            ),
          ),
          // Widget de calendario
          TableCalendar(
            locale: 'es_MX', //idioma
            rowHeight: 43,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(3000, 12, 30),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 8.0),
          // Mostrar los eventos
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            '${value[index].title} (${value[index].startTime.format(context)} - ${value[index].endTime.format(context)})',
                          ),
                        ),
                      );
                    });
              },
            ),
          )
        ],
      ),
    );
  }
}
