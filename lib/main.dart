import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() => runApp(MyApp());

TextEditingController IPController = TextEditingController();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BPI-Car',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final AlertDialog dialog = AlertDialog(
      title: Text('About Me'),
      content: Text('Made by Qubot.1445788683@qq.com'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('BPI-Car'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                TextField(
                  controller: IPController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      icon: Icon(Icons.computer),
                      labelText: '10.5.5.1'),
                  autofocus: false,
                ),
                // ignore: deprecated_member_use
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MySecondPage(),
                      ),
                    );
                  },
                  child: const Text('开始'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<void>(context: context, builder: (context) => dialog);
        },
        tooltip: 'About',
        child: const Icon(Icons.help_outline),
      ), //
    );
  }
}

class MySecondPage extends HookWidget {
  final channel =
      IOWebSocketChannel.connect('ws://' + IPController.text + ':9001');
  @override
  Widget build(BuildContext context) {
    final isRunning = useState(true);
    return Scaffold(
      appBar: AppBar(
        title: Text('BPI-Car'),
      ),
      body: Center(
          child: Column(
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: Mjpeg(
                          isLive: isRunning.value,
                          error: (context, error, stack) {
                            print(error);
                            print(stack);
                            return Text(error.toString(),
                                style: TextStyle(color: Colors.red));
                          },
                          stream: 'http://' +
                              IPController.text +
                              ':8080/?action=stream', //'http://192.168.1.37:8081',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[],
            ),
          ),
          Card(
            margin: EdgeInsets.all(10),
            child: Column(children: <Widget>[
              AspectRatio(
                aspectRatio: 1.0 / 1.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            channel.sink.add('F');
                          },
                          child: Text('前进'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            channel.sink.add('L');
                          },
                          child: Text('左拐'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            channel.sink.add('S');
                          },
                          child: Text('停止'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            channel.sink.add('R');
                          },
                          child: Text('右拐'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            channel.sink.add('B');
                          },
                          child: Text('后退'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  isRunning.value = !isRunning.value;
                },
                child: Text('暂停拍摄'),
              ),
            ],
          ),
        ],
      )),
    );
  }
}
