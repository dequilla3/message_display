import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstore/localstore.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wsmessage/app_text_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ''),
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
  final db = Localstore.instance;
  final serverIpController = TextEditingController();

  String? serverIp;

  WebSocketChannel? channel;

  saveIp() async {
    await db.collection('ips').doc("ips").set({
      'baseIp': serverIpController.text,
    });
    serverIp = serverIpController.text;
    connectWs();
  }

  Future<void> initServer() async {
    //initialize channel first
    connectWs(); 
    //check localstore for available IP's
    final items = await db.collection('ips').get();
    if (items != null) {
      var baseIp = items['/ips/ips']['baseIp'];
      if (baseIp != null) {
        //Set ip's if not null
        serverIpController.text = baseIp;
        serverIp = baseIp;
        //Run later
        await Future.delayed(const Duration(milliseconds: 1000))
            .then((value) => connectWs());
      }
    }
  }

  void connectWs() {
    setState(() {
      if (channel != null) {
        channel!.sink.close();
      }
      channel = WebSocketChannel.connect(
        Uri.parse(serverIp ?? 'ws://127.0.0.0'),
        // Uri.parse('ws://192.168.43.110:5175'),
      );
    });
  }

  String _getWsMessage(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return snapshot.data is String
          ? snapshot.data
          : String.fromCharCodes(snapshot.data);
    }
    return "";
  }

  @override
  void initState() {
    super.initState();

    initServer();
  }

  @override
  void dispose() {
    channel!.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            StreamBuilder(
              stream: channel!.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // Connection is closed
                  return const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Connection closed!',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 8),
                      FaIcon(FontAwesomeIcons.circleXmark)
                    ],
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Connection is closed
                  return const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Connecting . . .',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 8),
                      FaIcon(FontAwesomeIcons.connectdevelop)
                    ],
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    _getWsMessage(snapshot),
                    style: const TextStyle(fontSize: 32),
                  ),
                );
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    connectWs();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const FaIcon(FontAwesomeIcons.rotateLeft),
                ),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: false,
                      builder: (BuildContext context) {
                        return Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(22),
                                topRight: Radius.circular(22),
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const SizedBox(height: 22),
                                const Text(
                                  "Setup Server",
                                  style: TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 22),
                                AppTextField(
                                  hint: "Base URL Server IP",
                                  controller: serverIpController,
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 40,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      try {
                                        saveIp();
                                        Navigator.pop(context);
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const FaIcon(FontAwesomeIcons.server),
                ),
              ],
            ),
            const SizedBox(height: 14)
          ],
        ),
      ),
    );
  }
}
