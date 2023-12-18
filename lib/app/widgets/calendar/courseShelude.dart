
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CourseScheduleWidget extends StatefulWidget {
  @override
  _CourseScheduleWidgetState createState() => _CourseScheduleWidgetState();
}

class _CourseScheduleWidgetState extends State<CourseScheduleWidget> {
  final storage = const FlutterSecureStorage();
  Map<String, List<Map<String, String>>> weeklySchedule = {
    'Lunes': [],
    'Martes': [],
    'Miércoles': [],
    'Jueves': [],
    'Viernes': [],
    'Sábado': [],
  };

  @override
  void initState() {
    super.initState();
    _loadWeeklySchedule();
  }

  _addCourse(String day, Map<String, String> course) {
    setState(() {
      weeklySchedule[day]?.add(course);
    });
    _saveWeeklySchedule(); // Guardar después de añadir un curso
  }

  void _saveWeeklySchedule() async {
    String weeklyScheduleJson = jsonEncode(weeklySchedule);
    await storage.write(key: 'weeklySchedule', value: weeklyScheduleJson);
  }

  void _loadWeeklySchedule() async {
    String? weeklyScheduleJson = await storage.read(key: 'weeklySchedule');
    if (weeklyScheduleJson != null) {
      Map<String, dynamic> decodedJson =
          jsonDecode(weeklyScheduleJson) as Map<String, dynamic>;
      Map<String, List<Map<String, String>>> loadedWeeklySchedule = {};

      decodedJson.forEach((day, courses) {
        loadedWeeklySchedule[day] = List<Map<String, String>>.from(
          (courses as List).map(
            (course) => Map<String, String>.from(course as Map),
          ),
        );
      });

      setState(() {
        weeklySchedule = loadedWeeklySchedule;
      });
    }
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
          title: const Text(
            'Agregar nuevo curso',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Nombre del Curso'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: startHourController,
                      decoration:
                          const InputDecoration(hintText: 'Hora Inicial'),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      controller: startMinuteController,
                      decoration:
                          const InputDecoration(hintText: 'Minuto Inicial'),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: endHourController,
                      decoration: const InputDecoration(hintText: 'Hora Final'),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      controller: endMinuteController,
                      decoration:
                          const InputDecoration(hintText: 'Minuto Final'),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                dropdownColor: Colors.white,
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.blue,
                ),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                borderRadius: BorderRadius.circular(
                  10,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.transparent,
                ),
                shadowColor: MaterialStateProperty.all(
                  Colors.transparent,
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.transparent,
                ),
                shadowColor: MaterialStateProperty.all(
                  Colors.transparent,
                ),
              ),
              child: const Text(
                'Agregar',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
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