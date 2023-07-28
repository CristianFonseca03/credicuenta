import 'dart:convert';

import 'package:credicuenta/models/schedule_model.dart';
import 'package:credicuenta/pages/add_subject_page.dart';
import 'package:credicuenta/pages/create_schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool isLoading = true;
  ScheduleModel _scheduleModel =
      ScheduleModel('', DateTime.now(), DateTime.now(), 0, 0, hours: []);
  HourModel selectedHour = HourModel(0, 0, '', Colors.white, '', '');

  Future<void> getSchedule() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? scheduleModelString =
        preferences.getString('scheduleModelString');
    if (scheduleModelString == null) {
      setState(() {
        isLoading = false;
      });
      return;
    } else {
      setState(() {
        _scheduleModel =
            ScheduleModel.fromJson(jsonDecode(scheduleModelString));
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSchedule();
  }

  final _rowTextStyle1 = const TextStyle(
    fontSize: 10,
  );

  Widget _elementV1(String text, {TextStyle? style}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: InkWell(
        onTap: () {},
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
      ),
    );
  }

  Widget _elementV2(HourModel hour) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedHour = hour;
          });
        },
        child: Center(
          child: Container(
            width: 600,
            height: 30,
            decoration: BoxDecoration(
              color: hour.color,
            ),
          ),
        ),
      ),
    );
  }

  TableRow _row(
    String hour,
    int hourNumber,
    List<HourModel> hours,
  ) {
    final List<int> numbers = List<int>.generate(6, (i) => i);
    final selectedHours =
        hours.where((element) => element.hour == hourNumber).toList();
    return TableRow(
      children: [
        _elementV1(hour, style: _rowTextStyle1),
        ...numbers
            .map((e) => _elementV2(
                  selectedHours
                          .where((element) => element.day == e)
                          .toList()
                          .isEmpty
                      ? HourModel(0, 0, '', Colors.white, '', '')
                      : selectedHours
                          .where((element) => element.day == e)
                          .toList()
                          .first,
                ))
            .toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (isLoading) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_scheduleModel.name.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'No se ha registrado\nhorario para este semestre',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateSchedulePage(),
                  ),
                );
                if (result) {
                  setState(() {
                    isLoading = true;
                  });
                  await getSchedule();
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.green,
                ),
              ),
              child: const Text(
                '+',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      );
    } else {
      body = SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _scheduleModel.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 25,
                ),
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('¿Estás seguro?'),
                          content: const Text(
                              '¿Estás seguro que deseas eliminar este horario?'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                setState(() {
                                  isLoading = true;
                                  _scheduleModel = ScheduleModel(
                                    '',
                                    DateTime.now(),
                                    DateTime.now(),
                                    0,
                                    0,
                                    hours: [],
                                  );
                                });
                                final SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                await preferences.remove('scheduleModelString');
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: const Text('Si'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('No'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.red,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      Text(
                        '',
                        style: _rowTextStyle1,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Lunes',
                        style: _rowTextStyle1,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Martes',
                        style: _rowTextStyle1,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Miércoles',
                        style: _rowTextStyle1,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Jueves',
                        style: _rowTextStyle1,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Viernes',
                        style: _rowTextStyle1,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Sábado',
                        style: _rowTextStyle1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  _row('8-10', 0, _scheduleModel.hours),
                  _row('10-12', 1, _scheduleModel.hours),
                  _row('12-14', 2, _scheduleModel.hours),
                  _row('14-16', 3, _scheduleModel.hours),
                  _row('16-18', 4, _scheduleModel.hours),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            if (selectedHour.name.isNotEmpty)
              Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    selectedHour.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Grupo: ${selectedHour.group}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      Text(
                        'Salón: ${selectedHour.classroom}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddSubjectPage(),
                      ),
                    );
                    if (result) {
                      setState(() {
                        isLoading = true;
                      });
                      await getSchedule();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.green,
                    ),
                  ),
                  child: const Text(
                    'Agregar Materia',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Horario'),
      ),
      body: body,
    );
  }
}
