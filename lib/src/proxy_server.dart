import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:lunar_freelook/src/network_parser.dart';

class ProxyServer {
  ServerSocket? server;
  Socket? clientSocket;
  Socket? targetSocket;
  NetworkParser parser = NetworkParser();

  // void start(String address, int port) async {
  //   var targetAddress = address;
  //   List<InternetAddress> internetAddresses =
  //       await InternetAddress.lookup(address, type: InternetAddressType.IPv4);
  //   if (internetAddresses.isNotEmpty) {
  //     targetAddress = internetAddresses[0].address;
  //   }
  //   log("Starting the server!");
  //   // Start the server
  //   var serverFuture = ServerSocket.bind("127.0.0.1", 25566);
  //   // When server is ready
  //   serverFuture.then((ServerSocket server) {
  //     this.server = server;

  //     // Listen for connections from client
  //     server.listen((Socket clientSocket) {
  //       this.clientSocket = clientSocket;
  //       log("Client connected!");
  //       // Connect to target server
  //       var socketFuture = Socket.connect(targetAddress, port);
  //       // Connection is ready.
  //       socketFuture.then((Socket targetSocket) {
  //         this.targetSocket = targetSocket;
  //         clientSocket.listen(
  //           (List<int> data) {
  //             var packetResult =
  //                 parser.onClientPacket(PacketByteBuffer.fromList(data));
  //             if (packetResult.modified) {
  //               targetSocket.add(packetResult.packet!);
  //               return;
  //             }
  //             targetSocket.add(data);
  //           },
  //           onDone: () {
  //             log("Client disconnected!");
  //             clientSocket.destroy();
  //             targetSocket.destroy();
  //           },
  //         );
  //         targetSocket.listen((data) {
  //           var packetResult = parser.onServerPacket(PacketByteBuffer(data));
  //           if (packetResult.modified) {
  //             clientSocket.add(packetResult.packet!);
  //             log("Sent modified packet to client!");
  //             return;
  //           }
  //           clientSocket.add(data);
  //         }, onDone: (() {
  //           log("Server disconnected!");
  //           targetSocket.destroy();
  //           clientSocket.destroy();
  //         }));
  //       });
  //     });
  //   });
  // }

  void start(String address, int port) async {
    var targetAddress = address;
    List<InternetAddress> internetAddresses =
        await InternetAddress.lookup(address, type: InternetAddressType.IPv4);
    if (internetAddresses.isNotEmpty) {
      targetAddress = internetAddresses[0].address;
    }
    log("Starting the server!");
    // Start the server
    server = await ServerSocket.bind("127.0.0.1", 25566);

    // Listen for connections from client
    server?.listen(
        ((socket) => _listenToClientConnections(socket, targetAddress, port)));
  }

  void stop() {
    clientSocket?.destroy();
    targetSocket?.destroy();
    server?.close();
  }

  void _listenToClientConnections(
      Socket clientSocket, String address, int port) async {
    this.clientSocket = clientSocket;
    log("Client connected!");
    // Connect to target server
    targetSocket = await Socket.connect(address, port);

    clientSocket.listen(
      (List<int> data) {
        var packetResult = parser.onClientPacket(Uint8List.fromList(data));
        if (packetResult.modified) {
          targetSocket?.add(packetResult.packet!);
          return;
        }
        targetSocket?.add(data);
      },
      onDone: () {
        log("Client disconnected!");
        clientSocket.destroy();
        targetSocket?.destroy();
      },
    );
    targetSocket?.listen((data) {
      var packetResult = parser.onServerPacket(data);
      if (packetResult.modified) {
        clientSocket.add(packetResult.packet!);
        log("Sent modified packet to client!");
        return;
      }
      clientSocket.add(data);
    }, onDone: (() {
      log("Server disconnected!");
      targetSocket?.destroy();
      clientSocket.destroy();
    }));
  }
}
