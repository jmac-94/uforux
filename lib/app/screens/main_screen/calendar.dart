import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/event.dart';

class HomeCalendar extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeCalendar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this); // Cambia la longitud a 3
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color.fromARGB(
            153,
            16,
            0,
            0,
          ),
          unselectedLabelColor: Color.fromARGB(153, 16, 0, 0),
          tabs: [
            Tab(text: "Horario de curso"),
            Tab(text: "Calendario"),
            Tab(text: "Simulador de Notas"), // Nueva pestaña
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CourseScheduleWidget(),
          Calendar(),
          GradeSimulatorWidget(), // Nuevo widget para el simulador de notas
        ],
      ),
    );
  }
}

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
  String _selectedEventType = EventType.course;

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
                    DropdownButton<String>(
                      value: _selectedEventType,
                      onChanged: (String? newValude) {
                        setState(() {
                          _selectedEventType = newValude!;
                        });
                      },
                      items: <String>[
                        EventType.course,
                        EventType.degree,
                        EventType.university,
                        EventType.other
                      ].map<DropdownMenuItem<String>>((String valude) {
                        return DropdownMenuItem<String>(
                          value: valude,
                          child: Text(valude),
                        );
                      }).toList(),
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

class CourseScheduleWidget extends StatefulWidget {
  @override
  _CourseScheduleWidgetState createState() => _CourseScheduleWidgetState();
}

class _CourseScheduleWidgetState extends State<CourseScheduleWidget> {
  Map<String, List<Map<String, String>>> weeklySchedule = {
    'Lunes': [],
    'Martes': [],
    'Miércoles': [],
    'Jueves': [],
    'Viernes': [],
    'Sábado': [],
  };

  void _addCourse(String day, Map<String, String> course) {
    setState(() {
      weeklySchedule[day]?.add(course);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dayWidgets = weeklySchedule.keys.map((day) {
      return ExpansionTile(
        title: Text(day),
        children: weeklySchedule[day]!
            .map((course) => ListTile(
                  title: Text(course['name']!),
                  subtitle: Text(course['time']!),
                  leading: Icon(Icons.book),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        weeklySchedule[day]?.remove(course);
                      });
                    },
                  ),
                ))
            .toList(),
      );
    }).toList();

    return Scaffold(
      body: ListView(
        children: dayWidgets,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCourseDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _startHourController = TextEditingController();
    final _startMinuteController = TextEditingController();
    final _endHourController = TextEditingController();
    final _endMinuteController = TextEditingController();
    String selectedDay = 'Lunes';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar nuevo curso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre del Curso'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startHourController,
                      decoration:
                          InputDecoration(labelText: 'Hora Inicio (HH)'),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _startMinuteController,
                      decoration:
                          InputDecoration(labelText: 'Minuto Inicio (MM)'),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _endHourController,
                      decoration: InputDecoration(labelText: 'Hora Fin (HH)'),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _endMinuteController,
                      decoration: InputDecoration(labelText: 'Minuto Fin (MM)'),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                    ),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: selectedDay,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDay = newValue!;
                  });
                },
                items: weeklySchedule.keys
                    .map<DropdownMenuItem<String>>((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Agregar'),
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _startHourController.text.isNotEmpty &&
                    _startMinuteController.text.isNotEmpty &&
                    _endHourController.text.isNotEmpty &&
                    _endMinuteController.text.isNotEmpty) {
                  String formattedStartTime =
                      '${_startHourController.text.padLeft(2, '0')}:${_startMinuteController.text.padLeft(2, '0')}';
                  String formattedEndTime =
                      '${_endHourController.text.padLeft(2, '0')}:${_endMinuteController.text.padLeft(2, '0')}';
                  _addCourse(
                    selectedDay,
                    {
                      'name': _nameController.text,
                      'time': '$formattedStartTime - $formattedEndTime'
                    },
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class GradeSimulatorWidget extends StatefulWidget {
  @override
  _GradeSimulatorWidgetState createState() => _GradeSimulatorWidgetState();
}

class _GradeSimulatorWidgetState extends State<GradeSimulatorWidget> {
  List<Course> courses = [];
  final TextEditingController _courseNameController = TextEditingController();

  void _addCourse() {
    if (courses.length < 7 && _courseNameController.text.isNotEmpty) {
      setState(() {
        courses.add(Course(name: _courseNameController.text, grades: []));
        _courseNameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _courseNameController,
          decoration: InputDecoration(labelText: 'Nombre del Curso'),
          onSubmitted: (_) => _addCourse(),
        ),
        ElevatedButton(
          onPressed: _addCourse,
          child: Text('Agregar Curso'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return CourseItemWidget(
                course: courses[index],
                onGradesUpdated: () => setState(() {}),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Course {
  String name;
  List<Grade> grades;
  Course({required this.name, required this.grades});
}

class CourseItemWidget extends StatefulWidget {
  final Course course;
  final VoidCallback onGradesUpdated;

  CourseItemWidget({required this.course, required this.onGradesUpdated});

  @override
  _CourseItemWidgetState createState() => _CourseItemWidgetState();
}

class _CourseItemWidgetState extends State<CourseItemWidget> {
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _evaluationNameController =
      TextEditingController();

  void _addGrade() {
    double grade = double.tryParse(_gradeController.text) ?? 0.0;
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    String evaluationName = _evaluationNameController.text;
    if (grade > 0 && weight > 0 && evaluationName.isNotEmpty) {
      setState(() {
        widget.course.grades.add(Grade(grade, weight, evaluationName));
        _gradeController.clear();
        _weightController.clear();
        _evaluationNameController.clear();
        widget.onGradesUpdated();
      });
    }
  }

  double calculateAverage() {
    double totalWeight = 0.0;
    double weightedSum = 0.0;
    for (var grade in widget.course.grades) {
      weightedSum += grade.grade * grade.weight;
      totalWeight += grade.weight;
    }
    return totalWeight != 0 ? weightedSum / totalWeight : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(widget.course.name,
              style: TextStyle(fontWeight: FontWeight.bold)),
          for (var grade in widget.course.grades)
            Text(
                '${grade.evaluationName}: ${grade.grade}, Peso: ${grade.weight}'),
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: _evaluationNameController,
                decoration:
                    InputDecoration(labelText: "Nombre de la evaluation"),
              )),
              Expanded(
                child: TextField(
                  controller: _gradeController,
                  decoration: InputDecoration(labelText: 'Nota'),
                  keyboardType: TextInputType.number,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  decoration: InputDecoration(labelText: 'Peso'),
                  keyboardType: TextInputType.number,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _addGrade,
              ),
            ],
          ),
          Text('Promedio: ${calculateAverage().toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}

class Grade {
  double grade;
  double weight;
  String evaluationName;
  Grade(this.grade, this.weight, this.evaluationName);
}
