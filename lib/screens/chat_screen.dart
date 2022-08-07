// ignore_for_file: use_build_context_synchronously
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../imports.dart';

class ChatPage extends StatefulWidget {
  final String username;
  final String roomId;
  const ChatPage({Key? key, required this.username, required this.roomId})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  StreamSocket streamSocket = StreamSocket();
  bool isServerOnline = true;
  String? sentMsg;
  final TextEditingController controller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    connectAndListen(widget.username, widget.roomId);
  }

  void connectAndListen(String username, String roomId) {
    var uri = kIsWeb ? urlWebSocket : urlWebSocketMobile;
    socket = IO.io(uri);
    socket!.onConnect((_) {
      // it firing 'join' event so that server can listen the request.
      socket!.emit(
        'join',
        {
          'username': username,
          'roomId': roomId,
        },
      );

      //listening 'message' event and adding response to socket Stream
      socket!.on('message', (data) {
        setState(() {
          streamSocket.addResponse(data);
        });
      });
    });
    // listening server status 'offline' or 'online'.
    socket!.onDisconnect((_) {
      setState(() {
        isServerOnline = false;
      });
    });
  }

  @override
  void dispose() {
    streamSocket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Welcome ${widget.username}",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: isServerOnline
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 500,
                        child: Card(
                            elevation: 10,
                            child: Container(
                              padding: const EdgeInsets.all(50),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Colors.black, width: 2)),
                              child: StreamBuilder(
                                  stream: streamSocket.getResponse,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      dynamic doc = snapshot.data;
                                      List msg = [];
                                      msg.addAll(doc['msg']);
                                      return ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: msg.length,
                                          itemBuilder: (context, index) {
                                            var txt =
                                                msg[index]['msg'].toString();
                                            var ts =
                                                msg[index]['ts'].toString();
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                      child: ListTile(
                                                    leading: const Icon(
                                                      Icons.message,
                                                    ),
                                                    title: Text(
                                                      txt,
                                                      style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 14),
                                                    ),
                                                    subtitle: Text(
                                                      ts,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade700,
                                                          fontSize: 12),
                                                    ),
                                                  )),
                                                ],
                                              ),
                                            );
                                          });
                                    } else {
                                      return const Text("No message Found");
                                    }
                                  }),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          width: 500,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                flex: 5,
                                child: TextFormField(
                                  controller: controller,
                                  onChanged: (value) {
                                    sentMsg = value;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    hintText: "Type Msg",
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: const BorderSide(
                                            color: Colors.blueAccent,
                                            width: 2)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: const BorderSide(
                                            color: Colors.black, width: 2)),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: InkWell(
                                    onTap: () {
                                      socket!.emit('text', {
                                        'msg': sentMsg,
                                        'room': widget.roomId,
                                        'username': widget.username
                                      });
                                      setState(() {
                                        controller.clear();
                                      });
                                    },
                                    child: const Icon(
                                      Icons.send,
                                      size: 40,
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        child: GestureDetector(
                          onTap: () async {
                            socket!.emit('left', {
                              'username': widget.username,
                              'room': widget.roomId,
                            });
                            final prefs = await SharedPreferences.getInstance();
                            prefs.clear();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => const LogInScreen()));
                          },
                          child: Container(
                            width: 500,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 80),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(32)),
                            child: const Text(
                              "Leave Room",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : const Text("Oops server is offline"),
        ));
  }
}
