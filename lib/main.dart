// ignore_for_file: library_prefixes

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'imports.dart';
void main(){
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading=true;
  bool isLoggedIn=false;
  String? username;
  String? roomId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }
  Future init() async {
    final prefs = await SharedPreferences.getInstance();
    setState((){
      username=prefs.getString('username');
      roomId=prefs.getString('roomId');
      isLoading=false;
    });

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true
      ),
     home:isLoading?const Scaffold(body: Center(child: CircularProgressIndicator(),)):(username!=null && roomId!=null?ChatPage(username: username!, roomId: roomId!):const LogInScreen()));

  }
}














