// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
//ToDO: replace domain and port according to your server configuration

String urlWebSocket="http://localhost:5000/chat";
String urlWebSocketMobile="wss//Domain:port/chat";
 IO.Socket? socket;
