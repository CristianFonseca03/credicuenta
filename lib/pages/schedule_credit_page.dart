import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:credicuenta/models/schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleCreditsPage extends StatefulWidget {
  final int maxCredits;
  const ScheduleCreditsPage(this.maxCredits, {super.key});

  @override
  State<ScheduleCreditsPage> createState() => _ScheduleCreditsPageState();
}

class _ScheduleCreditsPageState extends State<ScheduleCreditsPage> {
  int get maxCredits => widget.maxCredits;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);
  TextEditingController creditsController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Programar consumo'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 25,
          ),
          const Text(
            'Cantidad de créditos a consumir:',
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: creditsController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
            onPressed: () => _selectDate(context),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.indigo,
              ),
            ),
            child: Text(
              'Fecha: ${DateFormat('d/M/yy').format(selectedDate)}',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
            onPressed: () => _selectTime(context),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.indigoAccent,
              ),
            ),
            child: Text(
              'Hora: ${DateFormat('h:mm a').format(selectedDate)}',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
            onPressed: () async {
              if (creditsController.text.isEmpty ||
                  creditsController.text == '0') {
                const snackBar = SnackBar(
                  content: Text(
                      'Ingresa una cantidad de créditos minima para consumir'),
                  backgroundColor: Colors.red,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else if (int.parse(creditsController.text) > maxCredits) {
                const snackBar = SnackBar(
                  content: Text(
                      'Ingresa una cantidad de créditos menor a los disponibles'),
                  backgroundColor: Colors.red,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else if (selectedDate.isBefore(DateTime.now())) {
                const snackBar = SnackBar(
                  content: Text('Ingresa una fecha valida'),
                  backgroundColor: Colors.red,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                final SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                final ScheduleModel scheduleModel = ScheduleModel.fromJson(
                  jsonDecode(
                    preferences.getString('scheduleModelString')!,
                  ),
                );
                scheduleModel.creditsCount -= int.parse(creditsController.text);
                scheduleModel.transactions.add(
                  TransactionModel(
                    DateTime.now(),
                    TransactionType.programed,
                    int.parse(creditsController.text),
                    selectedDate,
                  ),
                );
                preferences.setString(
                    'scheduleModelString', jsonEncode(scheduleModel.toJson()));
                creditsController.clear();
                final alarmSettings = AlarmSettings(
                  id: 69,
                  dateTime: selectedDate,
                  assetAudioPath: 'assets/sounds/alarm.wav',
                  loopAudio: true,
                  vibrate: true,
                  fadeDuration: 3.0,
                  notificationTitle: 'Consumo Programado',
                  notificationBody: 'Se han consumido créditos de tu cuenta.',
                  enableNotificationOnKill: true,
                );
                await Alarm.set(alarmSettings: alarmSettings);
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
              'Agregar',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }
}
