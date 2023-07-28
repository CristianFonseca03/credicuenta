import 'dart:convert';

import 'package:credicuenta/models/schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddSubjectPage extends StatefulWidget {
  const AddSubjectPage({super.key});

  @override
  State<AddSubjectPage> createState() => _AddSubjectPageState();
}

class _AddSubjectPageState extends State<AddSubjectPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController groupController = TextEditingController();
  TextEditingController classroomController = TextEditingController();
  int day = 99;
  int hour = 99;
  Color color = Colors.red;

  _badge(
    String text,
    int number, {
    bool isSelected = false,
    bool hourType = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (hourType) {
              if (hour == number) {
                hour = 99;
              } else {
                hour = number;
              }
            } else {
              if (day == number) {
                day = 99;
              } else {
                day = number;
              }
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.amber,
    Colors.brown,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.indigo,
    Colors.lime,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Agregar materia'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 25,
              ),
              const Text('Color:'),
              const SizedBox(
                height: 15,
              ),
              Wrap(
                children: [
                  ...colors
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  color = e;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: e,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: color == e
                                        ? color == Colors.green
                                            ? Colors.red
                                            : Colors.green
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: const Text(
                                  '',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
                controller: nameController,
              ),
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Grupo',
                ),
                controller: groupController,
              ),
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Aula',
                ),
                controller: classroomController,
              ),
              const SizedBox(
                height: 25,
              ),
              const Text('Dia:'),
              const SizedBox(
                height: 15,
              ),
              Wrap(
                children: [
                  _badge(
                    'Lunes',
                    0,
                    isSelected: day == 0,
                  ),
                  _badge(
                    'Martes',
                    1,
                    isSelected: day == 1,
                  ),
                  _badge(
                    'Miércoles',
                    2,
                    isSelected: day == 2,
                  ),
                  _badge(
                    'Jueves',
                    3,
                    isSelected: day == 3,
                  ),
                  _badge(
                    'Viernes',
                    4,
                    isSelected: day == 4,
                  ),
                  _badge(
                    'Sábado',
                    5,
                    isSelected: day == 5,
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const Text('Hora:'),
              const SizedBox(
                height: 15,
              ),
              Wrap(
                children: [
                  _badge("8-10", 0, hourType: true, isSelected: hour == 0),
                  _badge("10-12", 1, hourType: true, isSelected: hour == 1),
                  _badge("12-14", 2, hourType: true, isSelected: hour == 2),
                  _badge("14-16", 3, hourType: true, isSelected: hour == 3),
                  _badge("16-18", 4, hourType: true, isSelected: hour == 4),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        groupController.text.isEmpty ||
                        classroomController.text.isEmpty ||
                        day == 99 ||
                        hour == 99) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Faltan campos por llenar'),
                        ),
                      );
                      return;
                    }
                    final SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    final String? scheduleModelString =
                        preferences.getString('scheduleModelString');
                    if (scheduleModelString == null) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            'ERR-001',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                      return;
                    }
                    ScheduleModel scheduleModel =
                        ScheduleModel.fromJson(jsonDecode(scheduleModelString));
                    final hourModel = HourModel(
                      hour,
                      day,
                      nameController.text,
                      color,
                      groupController.text,
                      classroomController.text,
                    );
                    scheduleModel.hours.add(hourModel);
                    preferences.setString(
                        'scheduleModelString', jsonEncode(scheduleModel));
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context, true);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.green,
                    ),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
