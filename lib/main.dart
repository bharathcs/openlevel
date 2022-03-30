import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Level',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const MyHomePage(title: 'Open Level'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() {
    final _MyHomePageState state = _MyHomePageState();
    final Timer ticker = Timer.periodic(Duration(milliseconds: 10), (timer) {
      state.updateScreen();
    });
    return state;
  }
}

class _GyroState {
  final double angle;
  final double radius;

  _GyroState(this.angle, this.radius);

  factory _GyroState.fromGyroEvent(double x, y, z) {
    final double a = atan2(y, x);
    final double r = (x.abs() + y.abs()) / (x.abs() + y.abs() + z.abs());
    return _GyroState(round(a), round(r));
  }

  @override
  String toString() {
    return "$angle $radius";
  }
}

class _MyHomePageState extends State<MyHomePage> {
  double _xAccel = 0;
  double _yAccel = 0;
  double _zAccel = 0;

  _GyroState _state = _GyroState(0, 0);

  Stream<AccelerometerEvent> _accelStream = accelerometerEvents;
  AccelerometerEvent _event = AccelerometerEvent(0, 0, 0);
  StreamSubscription<AccelerometerEvent>? _accelSubscription;

  _MyHomePageState() {
    _accelSubscription = _accelStream.listen((event) {
      _event = event;
    });
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [Text('$_state, $_xAccel, $_yAccel, $_zAccel ')],
      ),
    );
  }

  void updateScreen() {
    setState(() {
      _xAccel = _event.x;
      _yAccel = _event.y;
      _zAccel = _event.z;

      _state = _GyroState.fromGyroEvent(_xAccel, _yAccel, _zAccel);
    });
  }
}

double round(double input) {
  return (input * 100).roundToDouble() / 100;
}
