import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../proxy_server.dart';

final runningProvider = StateProvider<bool>((ref) {
  return false;
});

final ProxyServer server = ProxyServer();

class ProxyScreen extends ConsumerWidget {
  ProxyScreen({Key? key, required this.title}) : super(key: key);

  final String title;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = ref.watch(runningProvider);
    var input = "";
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Server addres',
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(
              width: 400,
              child: TextField(
                controller: controller,
                onChanged: (String text) => input = text,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(100, 50)),
                    backgroundColor: MaterialStateProperty.all(
                        isRunning ? Colors.green : Colors.red)),
                onPressed: () {
                  if (isRunning) {
                    server.stop();
                    ref.read(runningProvider.notifier).state = false;
                    return;
                  }
                  if (input == "") {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            content: Text("Please enter server addres first!"),
                          );
                        });
                    return;
                  }
                  String addres;
                  int port = 25565;
                  if (input.contains(":")) {
                    final splitted = input.split(":");
                    addres = splitted[0];
                    port = int.parse(splitted[1]);
                  } else {
                    addres = input;
                  }
                  server.start(addres, port);
                  ref.read(runningProvider.notifier).state = true;
                },
                child: Text(isRunning ? "Stop" : "Start"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
