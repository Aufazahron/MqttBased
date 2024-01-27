// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MqttServerClient client = MqttServerClient('test.mosquitto.org', 'iot');
  List<DataPoint> dataPoints = [];
  List<DataPoint> dataPoints1 = [];
  List<DataPoint> dataPoints2 = [];
  List<DataPoint> dataPoints3 = [];

  double value1 = 0.0;
  double value2 = 0.0;
  double value3 = 0.0;
  @override
  void initState() {
    super.initState();

    // Inisialisasi koneksi MQTT dan langganan topik
    client.onConnected = _onConnected;

    // Connect ke broker
    _connect();
  }

  Future<void> _connect() async {
    try {
      await client.connect();
    } catch (e) {
      print('Error connecting to MQTT broker: $e');
    }
  }

  void _onConnected() {
    print('Connected to the broker');

    // Berlangganan ke topik yang diinginkan
    client.subscribe('waw/topic1', MqttQos.atLeastOnce);

    // Menggunakan updates.listen untuk mendengarkan pembaruan klien
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      // Mendapatkan topik dari pesan
      final String topic = c[0].topic;

      print('Received message on topic $topic: $payload');

      // Menambahkan dataPoints dengan waktu sekarang dan nilai dari payload
      setState(() {
        final formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());
        dataPoints.add(DataPoint(formattedTime, double.parse(payload)));
        value1 = double.parse(payload);

        // if (dataPoints.length > 30) {
        //   dataPoints.removeRange(0, dataPoints.length - 30);
        // }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Air Quality Monitoring'),
      ),
      body: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 290.0,
              enableInfiniteScroll: false,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              onPageChanged: (index, _) {
                // Handle page change if needed
              },
            ),
            items: [
              _buildChart(dataPoints, 'Chart 1'),
              _buildChart(dataPoints, 'Chart 2'),
              _buildChart(dataPoints, 'Chart 3'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildValueBox('Value 1', value1),
              _buildValueBox('Value 2', value1),
              _buildValueBox('Value 3', value1),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildValueBox('Value 1', value1),
              _buildValueBox('Value 2', value1),
              _buildValueBox('Value 3', value1),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildChart(List<DataPoint> dataPoints, String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        height: 250,
        child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelRotation: 0,
              autoScrollingDelta: 20,
              desiredIntervals: 10,
              autoScrollingMode: AutoScrollingMode.end,
            ),
            tooltipBehavior: TooltipBehavior(),
            primaryYAxis: NumericAxis(),
            series: <CartesianSeries>[
              LineSeries<DataPoint, String>(
                dataSource: dataPoints,
                xValueMapper: (DataPoint data, _) => data.time,
                yValueMapper: (DataPoint data, _) => data.value,
                // markerSettings: MarkerSettings(isVisible: true),
              ),
            ]),
      ),
    ],
  );
}

Widget _buildValueBox(String label, double value) {
  return Container(
    margin: EdgeInsets.only(top: 20),
    padding: EdgeInsets.all(30),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 16),
        ),
      ],
    ),
  );
}

class DataPoint {
  final String time;
  final double value;

  DataPoint(this.time, this.value);
}
