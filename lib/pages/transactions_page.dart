import 'dart:convert';

import 'package:credicuenta/models/schedule_model.dart';
import 'package:credicuenta/pages/create_schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  bool isLoading = true;
  ScheduleModel _scheduleModel =
      ScheduleModel('', DateTime.now(), DateTime.now(), 0, 0, hours: []);

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
      List<TransactionModel> transactions = _scheduleModel.transactions;
      transactions.sort((a, b) => b.programedDate.compareTo(a.programedDate));
      body = Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 25,
            ),
            _scheduleModel.transactions.isEmpty
                ? const Center(
                    child: Text(
                      'No se han registrado transacciones',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Card(
                          child: ListTile(
                            leading:
                                transaction.type == TransactionType.programed
                                    ? const Icon(
                                        Icons.schedule,
                                        color: Colors.grey,
                                      )
                                    : transaction.type == TransactionType.add
                                        ? const Icon(
                                            Icons.add,
                                            color: Colors.green,
                                          )
                                        : const Icon(
                                            Icons.remove,
                                            color: Colors.red,
                                          ),
                            title: Text(
                              transaction.type == TransactionType.programed
                                  ? 'Programado'
                                  : transaction.type == TransactionType.add
                                      ? 'Añadido'
                                      : 'Retirado',
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Text(
                              transaction.type == TransactionType.programed
                                  ? DateFormat('dd/MM/yy h:mm a')
                                      .format(transaction.programedDate)
                                  : DateFormat('dd/MM/yy h:mm a')
                                      .format(transaction.date),
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            trailing: Text(
                              '${transaction.type == TransactionType.programed ? '' : transaction.type == TransactionType.add ? '+' : '-'}${transaction.credits}',
                              style: TextStyle(
                                fontSize: 20,
                                color: transaction.type ==
                                        TransactionType.programed
                                    ? Colors.grey
                                    : transaction.type == TransactionType.add
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Transacciones'),
      ),
      body: body,
    );
  }
}
