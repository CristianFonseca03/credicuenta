import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:credicuenta/pages/credits_page.dart';
import 'package:credicuenta/pages/schedule_page.dart';
import 'package:credicuenta/pages/transactions_page.dart';

void main() async {
  runApp(const MyApp());
  await Alarm.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(
            0xfff1c606,
          ),
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('es'),
      ],
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: controller,
                children: const [
                  SchedulePage(),
                  CreditsPage(),
                  TransactionsPage(),
                ],
              ),
            ),
            Container(
              color: const Color(
                0xfff1c606,
              ),
              child: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                controller: controller,
                tabs: const [
                  Tab(text: 'Horario'),
                  Tab(text: 'Créditos'),
                  Tab(text: 'Transacciones'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
