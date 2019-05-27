import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(), // dark theme applied
      home: MyHomePage(title: "Sensor Box"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final Set<String> _running_sensors = Set<String>();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  List<double> _userAccelerometerValues; // save
  // s accel values without gravity
  List<double> _gyroscopeValues;          // saves rotation values, in radians

  // stores list of subcriptions to sensor event streams (async data sources)
  List<StreamSubscription<dynamic>> _streamSubscriptions =
  <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // here we will update our values, before updating the UI
    // note that conditional member access operator is used (?.)
    // gyro values
    final List<String> gyroscope =
    _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    // accel values
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CheckboxListTile(
              title: Text("Accelerometer"),
              value:  _running_sensors.contains("Accel"),
              onChanged: (bool new_value) {
                setState(()
                {
                  new_value ? _running_sensors.add("Accel") : _running_sensors.remove("Accel");
                });

              },

            ),
            Text(
              '$userAccelerometer',
            ),
            CheckboxListTile(
              title: Text("Gyroscope"),
              value:  _running_sensors.contains("Gyro"),
              onChanged: (bool new_value) {
                setState(()
                {
                  new_value ? _running_sensors.add("Gyro") : _running_sensors.remove("Gyro");
                });

              },
            ),
            Text(
              '$gyroscope',
            ),

          ],
        ),
      ),

    );
  }

  // unregistering our sensor stream subscriptions
  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  // registering our sensor stream subscriptions
  // called when stateful widget is inserted in widget tree.
  @override
  void initState() {
    super.initState(); // must be included

    // start subscription once, update values for each event time
    _streamSubscriptions.add(
        gyroscopeEvents.listen((GyroscopeEvent event){
            setState(() {
               _gyroscopeValues = <double>[event.x, event.y, event.z];
            });
        })
    );

    _streamSubscriptions.add(
        userAccelerometerEvents.listen(
            (UserAccelerometerEvent event) {
              setState(() {
                _userAccelerometerValues = <double>[event.x, event.y, event.z];
              });
        })
    );
  }
}
