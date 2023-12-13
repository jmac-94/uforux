import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.blue[800],
          shadowColor: Colors.transparent,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            tabs: const [
              Tab(
                  text: "Horario",
                  icon: Icon(
                    Icons.calendar_today,
                    size: 20,
                  )),
              Tab(
                text: "Sim. de Notas",
                icon: Icon(
                  Icons.calculate,
                  size: 20,
                ),
              ),
              Tab(
                text: "Calendario",
                icon: Icon(
                  Icons.event,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Calendar(),
          CourseScheduleWidget(),
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

  Database? _database;

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
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calendar.db');

    _database = await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE events(id INTEGER PRIMARY KEY, title TEXT, date TEXT, startTime TEXT, endTime TEXT)',
      );
    });

    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final List<Map<String, dynamic>> maps = await _database!.query('events');

    setState(() {
      events = {};
      for (var map in maps) {
        final date = DateTime.parse(map['date']);
        final event = Event.fromJson(map);
        events.putIfAbsent(date, () => []).add(event);
      }
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    });
  }

  Future<void> _saveEvent(Event event) async {
    await _database!.insert(
      'events',
      event.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _selectedEvents.value = _getEventsForDay(_selectedDay);
    _loadEvents();
  }

  void _addEvent() {
    if (_eventController.text.isEmpty) {
      return;
    }

    final event = Event(
      title: _eventController.text,
      startTime: _startTime,
      endTime: _endTime,
      date: _selectedDay,
    );

    _saveEvent(event);
    _eventController.clear();
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
        backgroundColor: Colors.white,
        onPressed: () {
          _startTime = TimeOfDay.now();
          _endTime = TimeOfDay.now();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Crear nuevo evento'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _eventController,
                      decoration: const InputDecoration(
                        hintText: 'Nombre del evento',
                      ),
                    ),
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
                    // Si tienes otros widgets como un DropdownButton para seleccionar el tipo de evento, inclúyelos aquí
                    DropdownButton<String>(
                      value: _selectedEventType,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEventType = newValue!;
                        });
                      },
                      items: <String>[
                        EventType.course,
                        EventType.degree,
                        EventType.university,
                        EventType.other
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      final newEvent = Event(
                        title: _eventController.text,
                        startTime: _startTime,
                        endTime: _endTime,
                        date: _selectedDay,
                      );

                      await _saveEvent(newEvent); // Guardar en la base de datos
                      _selectedEvents.value = _getEventsForDay(_selectedDay);

                      _eventController.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Crear'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
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
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ExpansionTile(
            title: Row(
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${weeklySchedule[day]?.length ?? 0} cursos',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            children: weeklySchedule[day]!
                .map((course) => ListTile(
                      title: Text(course['name']!),
                      subtitle: Text(course['time']!),
                      leading: const Icon(Icons.book),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            weeklySchedule[day]?.remove(course);
                          });
                        },
                      ),
                    ))
                .toList(),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      body: ListView(
        children: dayWidgets,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCourseDialog(context),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final startHourController = TextEditingController();
    final startMinuteController = TextEditingController();
    final endHourController = TextEditingController();
    final endMinuteController = TextEditingController();
    String selectedDay = 'Lunes';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar nuevo curso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del Curso'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: startHourController,
                      decoration:
                          const InputDecoration(labelText: 'Hora Inicio (HH)'),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: startMinuteController,
                      decoration: const InputDecoration(
                          labelText: 'Minuto Inicio (MM)'),
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
                      controller: endHourController,
                      decoration:
                          const InputDecoration(labelText: 'Hora Fin (HH)'),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: endMinuteController,
                      decoration:
                          const InputDecoration(labelText: 'Minuto Fin (MM)'),
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
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Agregar'),
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    startHourController.text.isNotEmpty &&
                    startMinuteController.text.isNotEmpty &&
                    endHourController.text.isNotEmpty &&
                    endMinuteController.text.isNotEmpty) {
                  String formattedStartTime =
                      '${startHourController.text.padLeft(2, '0')}:${startMinuteController.text.padLeft(2, '0')}';
                  String formattedEndTime =
                      '${endHourController.text.padLeft(2, '0')}:${endMinuteController.text.padLeft(2, '0')}';
                  _addCourse(
                    selectedDay,
                    {
                      'name': nameController.text,
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Curso',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              onSubmitted: (_) => _addCourse(),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.grey[200],
                    ),
                    child: CourseGradeItemWidget(
                      course: courses[index],
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Course {
  String name;
  List<Grade> grades;
  Course({required this.name, required this.grades});
}

class Grade {
  double grade;
  double weight;
  String evaluationName;
  Grade(this.grade, this.weight, this.evaluationName);
}

class CourseGradeItemWidget extends StatefulWidget {
  final Course course;

  CourseGradeItemWidget({required this.course});

  @override
  _CourseGradeItemWidgetState createState() => _CourseGradeItemWidgetState();
}

class _CourseGradeItemWidgetState extends State<CourseGradeItemWidget> {
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
    return ExpansionTile(
      collapsedTextColor: Colors.black,
      title: Text(
        widget.course.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      backgroundColor: Colors.grey[200],
      children: [
        for (var grade in widget.course.grades)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      grade.evaluationName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0, bottom: 10.0),
                    child: Column(
                      children: [
                        Text(
                          'Nota: ${grade.grade}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Peso: ${grade.weight}%',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Promedio:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              ' ${calculateAverage().toStringAsFixed(2)}',
              style: TextStyle(
                color:
                    double.parse(calculateAverage().toStringAsFixed(2)) < 10.5
                        ? Colors.red
                        : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _evaluationNameController,
                decoration: const InputDecoration(
                  labelText: "Nombre de la Evaluación",
                  labelStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextField(
                controller: _gradeController,
                decoration: const InputDecoration(
                  labelText: 'Nota',
                  labelStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso (%)',
                  labelStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addGrade,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue[500]),
                ),
                child: const Text('Agregar Evaluación'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
