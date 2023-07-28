import 'dart:convert';

import 'package:credicuenta/models/schedule_model.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  List<DateTime> _dates = [];

  @override
  Widget build(BuildContext context) {
    final difference =
        _dates.length == 2 ? _dates[1].difference(_dates[0]).inDays : 0;
    final weeks = (difference / 7).round();
    TextEditingController nameController = TextEditingController();
    TextEditingController creditValueController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Crear Horario'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              const Text(
                'Fechas:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              CalendarDatePicker2(
                config: CalendarDatePicker2Config(
                    calendarType: CalendarDatePicker2Type.range),
                value: _dates,
                onValueChanged: (dates) {
                  setState(() {
                    _dates = [];
                    for (var date in dates) {
                      _dates.add(DateTime.parse(date.toString()));
                    }
                  });
                },
              ),
              if (_dates.length == 2)
                Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    Text('Desde: ${DateFormat('d/M/yy').format(_dates[0])} '
                        '- Hasta: ${DateFormat('d/M/yy').format(_dates[1])}'),
                    Text('Cantidad de semanas: $weeks'),
                  ],
                )
              else
                const Column(
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    Text('Seleccione un rango de fechas'),
                  ],
                ),
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
                controller: nameController,
                focusNode: null,
              ),
              const SizedBox(
                height: 25,
              ),
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Valor del crédito',
                ),
                controller: creditValueController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                focusNode: null,
              ),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) {
                    const snackBar = SnackBar(
                      content: Text('Ingresa un nombre para el horario.'),
                      backgroundColor: Colors.red,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else if (creditValueController.text.isEmpty) {
                    const snackBar = SnackBar(
                      content: Text('Ingresa un valor para el crédito.'),
                      backgroundColor: Colors.red,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else if (_dates.length != 2) {
                    const snackBar = SnackBar(
                      content: Text('Selecciona un rango de fechas.'),
                      backgroundColor: Colors.red,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    final model = ScheduleModel(
                      nameController.text,
                      _dates[0],
                      _dates[1],
                      int.parse(creditValueController.text),
                      0,
                      hours: [],
                    );
                    final SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    preferences.setString(
                        'scheduleModelString', jsonEncode(model.toJson()));
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context, true);
                  }
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
