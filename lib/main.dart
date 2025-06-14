import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Commnunicate to platform'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const batteryChannel = MethodChannel('samples.flutter.dev/battery');
  static const additionChannel = MethodChannel('samples.flutter.dev/addition');
  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final result = await batteryChannel.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery level at $result %.';
    } on PlatformException catch (e) {
      batteryLevel = 'Failed to get battery level: \'${e.message}\'.';
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> callNativeAdd() async {
    try {
      final result = await additionChannel.invokeMethod<bool>('add');
      print('Result from native add: $result');
    } on PlatformException catch (e) {
      print('Failed to call native add: \'${e.message}\'.');
    }
  }

  @override
  void initState() {
    additionChannel.setMethodCallHandler((call) async {
        if (call.method == 'add') {
            if (call.arguments != null && call.arguments is List && call.arguments.length == 2) {
                print('Received add method call with arguments: ${call.arguments}');
              return call.arguments[0] + call.arguments[1];
            } else {
              throw ArgumentError('Invalid arguments for add method');
            }
        }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _getBatteryLevel,
              child: const Text('Get Battery Level'),
            ),
            Text('battery level: $_batteryLevel'),

            SizedBox(height: 20,),

            ElevatedButton(
              onPressed: callNativeAdd,
              child: const Text('Call Native Add Method'),
            ),
          ],
        ),
      ),
    );
  }
}
