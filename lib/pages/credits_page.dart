import 'dart:convert';

import 'package:credicuenta/models/schedule_model.dart';
import 'package:credicuenta/pages/create_schedule_page.dart';
import 'package:credicuenta/pages/schedule_credit_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  bool isLoading = true;
  ScheduleModel _scheduleModel =
      ScheduleModel('', DateTime.now(), DateTime.now(), 0, 0, hours: []);
  TextEditingController creditsController = TextEditingController();

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

  Future<void> removeCreditsDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 25,
              ),
              const Text(
                'Cantidad de créditos a utilizar:',
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
                onPressed: () async {
                  if (creditsController.text.isEmpty ||
                      creditsController.text == '0') {
                    Navigator.pop(context);
                    const snackBar = SnackBar(
                      content: Text(
                          'Ingresa una cantidad de créditos minima para utilizar'),
                      backgroundColor: Colors.red,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else if (_scheduleModel.creditsCount <
                      int.parse(creditsController.text)) {
                    Navigator.pop(context);
                    const snackBar = SnackBar(
                      content: Text('Créditos insuficientes'),
                      backgroundColor: Colors.red,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    final SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    _scheduleModel.creditsCount -=
                        int.parse(creditsController.text);
                    _scheduleModel.transactions.add(
                      TransactionModel(
                        DateTime.now(),
                        TransactionType.remove,
                        int.parse(creditsController.text),
                        DateTime.now(),
                      ),
                    );
                    preferences.setString('scheduleModelString',
                        jsonEncode(_scheduleModel.toJson()));
                    setState(() {
                      _scheduleModel = _scheduleModel;
                    });
                    creditsController.clear();
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.red,
                  ),
                ),
                child: const Text(
                  'Descontar',
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
      },
    );
  }

  Future<void> addCreditsDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 25,
              ),
              const Text(
                'Cantidad de créditos a agregar:',
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
                onPressed: () async {
                  if (creditsController.text.isEmpty ||
                      creditsController.text == '0') {
                    Navigator.pop(context);
                    const snackBar = SnackBar(
                      content: Text(
                          'Ingresa una cantidad de créditos minima para agregar'),
                      backgroundColor: Colors.red,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    final SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    _scheduleModel.creditsCount +=
                        int.parse(creditsController.text);
                    _scheduleModel.transactions.add(
                      TransactionModel(
                        DateTime.now(),
                        TransactionType.add,
                        int.parse(creditsController.text),
                        DateTime.now(),
                      ),
                    );
                    preferences.setString('scheduleModelString',
                        jsonEncode(_scheduleModel.toJson()));
                    setState(() {
                      _scheduleModel = _scheduleModel;
                    });
                    creditsController.clear();
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final oCcy = NumberFormat("#,##0.00", "en_US");
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
              'No se han registrado\ninformación del crédito para este semestre',
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
      body = Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _scheduleModel.name,
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Créditos disponibles:',
            ),
            Text(
              _scheduleModel.creditsCount.toString(),
              style: const TextStyle(
                fontSize: 45,
              ),
            ),
            Text(
              'Valor del crédito: \$${oCcy.format(_scheduleModel.creditValue)}',
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              'Saldo actual: \$${oCcy.format(_scheduleModel.creditsCount * _scheduleModel.creditValue)}',
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    addCreditsDialog();
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
                  width: 15,
                ),
                ElevatedButton(
                  onPressed: () {
                    removeCreditsDialog();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.red,
                    ),
                  ),
                  child: const Text(
                    'Consumir',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ScheduleCreditsPage(_scheduleModel.creditsCount),
                  ),
                );
                if (result) {
                  setState(() {
                    isLoading = true;
                  });
                  await getSchedule();
                  const snackBar = SnackBar(
                    content: Text('Consumo programado con éxito'),
                    backgroundColor: Colors.green,
                  );
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.grey,
                ),
              ),
              child: const Text(
                'Programar consumo',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Créditos'),
      ),
      body: body,
    );
  }
}
