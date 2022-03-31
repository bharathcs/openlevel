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

class _LevelState {
  final double angle;
  final double radius;

  _LevelState(this.angle, this.radius);

  factory _LevelState.fromGyroEvent(double x, y, z) {
    final double a = atan2(y, x);
    final double r = (x.abs() + y.abs()) / (x.abs() + y.abs() + z.abs());
    return _LevelState(round(a), round(r));
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

  _LevelState _state = _LevelState(0, 0);

  final Stream<AccelerometerEvent> _accelStream = accelerometerEvents;
  AccelerometerEvent _event = AccelerometerEvent(0, 0, 9.8);
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
    final double width = min(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

    final double w = width / 2;
    final double h = sin(_state.angle) * _state.radius * w;
    final double v = cos(_state.angle) * _state.radius * w;

    return Scaffold(
      body: Center(
          child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
              width: width,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              )),
          Container(
            padding: EdgeInsets.only(
                top: max(0, -h),
                left: max(0, v),
                bottom: max(0, h),
                right: max(0, -v)),
            child: Container(
                width: w,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                )),
          ),
          Text(_state.toString()),
        ],
      )),
    );
  }

  void updateScreen() {
    setState(() {
      _xAccel = _event.x;
      _yAccel = _event.y;
      _zAccel = _event.z;

      _state = _LevelState.fromGyroEvent(_xAccel, _yAccel, _zAccel);
    });
  }
}

double round(double input) {
  return (input * 100).roundToDouble() / 100;
}
