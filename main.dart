import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MqttServerClient client = MqttServerClient('test.mosquitto.org', 'iot');
  StreamController<String> messageStreamController = StreamController<String>();

  @override
  void initState() {
    super.initState();

    // Ganti dengan detail broker MQTT yang sesuai
    // client = MqttServerClient('mqtt.eclipse.org', '');

    // Event handler saat koneksi berhasil
    client.onConnected = _onConnected;

    // Event handler saat mendapatkan pesan

    // Connect ke broker
    _connect();
  }

  // Method untuk menghubungkan ke broker
  Future<void> _connect() async {
    try {
      await client.connect();
    } catch (e) {
      print('Error connecting to MQTT broker: $e');
    }
  }

  // Event handler saat koneksi berhasil
  void _onConnected() {
    print('Connected to the broker');

    // Berlangganan ke topik pertama
    client.subscribe('waw/topic1', MqttQos.atLeastOnce);

    // Berlangganan ke topik kedua
    client.subscribe('waw/topic2', MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final String topic = c[0].topic;
      print(topic + ':' + pt);

      messageStreamController.add('$topic: $pt');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('MQTT Client Example'),
        ),
        body: Center(
          child: StreamBuilder<String>(
            stream: messageStreamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.requireData);
              } else {
                return Text('Waiting for MQTT data...');
              }
            },
          ),
        ),
      ),
    );
  }
}
