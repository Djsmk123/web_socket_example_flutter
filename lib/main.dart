import 'package:flutter/material.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
void main(){
  runApp(const MyApp());
}

String websocket="http://localhost:5000/chat";
IO.Socket socket = IO.io(websocket);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true
      ),
     home: HomeScreen(),
     // home: const ChatPage(username: "king", roomId: "djsmk123")
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;
  String? roomId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  void dispose() {
    // TODO: implement dispose
   // socket.disconnect();
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {

   return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Join Room",style: TextStyle(
                fontSize:40,
              ),
              ),
             const SizedBox(height: 50,),
              SizedBox(
                width: 500,
                child: TextFormField(
                  onChanged: (value){
                    setState((){
                      username=value;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    hintText: "Enter Username",
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: const BorderSide(color: Colors.blueAccent,width: 2)
                    ),
                    border:  OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(color: Colors.black,width: 2)
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50,),
              SizedBox(
                width: 500,
                child: TextFormField(
                  onChanged: (value){
                    setState((){
                      roomId=value;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    hintText: "Enter Room Id",
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(color: Colors.blueAccent,width: 2)
                    ),
                    border:  OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(color: Colors.black,width: 2)
                    ),
                  ),
                ),
              ),
              const  SizedBox(height: 50,),

              GestureDetector(
                onTap: (){

                  socket.onConnect((__) {
                    socket.emit('join', {
                      'username':username,
                      'roomId':roomId,
                    },
                    );
                  });
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (builder)=>ChatPage(username: username!, roomId: roomId!)));



                },
                child: Container(
                  width: 500,
                  padding:const EdgeInsets.symmetric(vertical: 20,horizontal: 80),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(32)
                  ),
                  child: const Text("Join Room",style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                  ),),
                ),
              )

            ],
          ),
        ),
      ),
   );
  }
}

class ChatPage extends StatefulWidget {
  final String username;
  final String roomId;
  const ChatPage({Key? key, required this.username, required this.roomId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
   StreamSocket streamSocket=StreamSocket();
  List msg=[];
  String? sentMsg;
  @override
  void initState() {
    // TODO: implement initState
    connectAndListen(widget.username,widget.roomId);
    super.initState();
  }
   void connectAndListen(String username, String roomId){
     if(!socket.disconnected)
     {
       connectStates();
     }
     else{
       socket.onConnect((_) {
         connectStates();
       });
     }


     //When an event recieved from server, data is added to the stream


   }
   void connectStates(){
     socket.on('message', (data){
     streamSocket.addResponse(data);
     } );
     socket.on('status', (data) {
     streamSocket.addResponse(data);
     } );
     socket.onDisconnect((_) => print('disconnect'));
   }
  @override
  void dispose() {
    // TODO: implement dispose
    socket.emit('left',{
      'username':widget.username,
      'room':widget.roomId,
    });
    streamSocket.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${widget.username}",style: const TextStyle(
          color: Colors.white
        ),),
        backgroundColor: Colors.blueAccent,
      ),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
          width: 500,
          height: 500,
          child: Card(
          elevation: 10,
          child: Container(
          padding: EdgeInsets.all(50),
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black,width: 2)
          ),
            child:
            StreamBuilder(
                stream: streamSocket.getResponse,
                builder: (context,snapshot){
                  print(snapshot.toString());
                  if(snapshot.hasData)
                    {
                      msg.add(snapshot.data);
                      return ListView.builder(
                              shrinkWrap: true,
                              itemCount: msg.length,
                              itemBuilder:(context,index){
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(msg[index]['msg'].toString(),style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 20
                                  ),),
                                );
                              });
                    }
                  else if(snapshot.connectionState==ConnectionState.waiting && msg.isEmpty)
                    {
                      return const Text("No message history found");
                    }
                  else
                    {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                }),
          )
          ),
        ),
            SizedBox(height: 50,),
            SizedBox(
              width: 500,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 5,
                    child: TextFormField(
                      onChanged: (value){
                       // setState((){
                          sentMsg=value;
                      //  });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        hintText: "Type Msg",
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: const BorderSide(color: Colors.blueAccent,width: 2)
                        ),
                        border:  OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: const BorderSide(color: Colors.black,width: 2)
                        ),
                      ),
                    ),
                  ),
                  Flexible(

                    child: GestureDetector(onTap: (){
                        socket.emit('text',{
                          'msg':sentMsg,
                          'room':widget.roomId,
                          'username':widget.username
                        });


                      }, child: Icon(Icons.send,size: 40,)),
                  )
                ],
              ),
            ),

            const  SizedBox(height: 50,),

            GestureDetector(
              onTap: (){
                socket.emit('left',{
                  'username':widget.username,
                  'room':widget.roomId,
                });
                Navigator.push(context, MaterialPageRoute(builder: (builder)=>HomeScreen()));

              },
              child: Container(
                width: 500,
                padding:const EdgeInsets.symmetric(vertical: 20,horizontal: 80),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(32)
                ),
                child: const Text("Leave Room",style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                ),),
              ),
            )

          ],
        ),
      )
    );
  }
}




// STEP1:  Stream setup
class StreamSocket{

  final _socketResponse= StreamController<dynamic>();

  void Function(dynamic) get addResponse => _socketResponse.sink.add;

  Stream<dynamic> get getResponse => _socketResponse.stream;

  void dispose(){
    _socketResponse.close();
  }



}






