  // ignore_for_file: use_build_context_synchronously
  import '../imports.dart';
  class LogInScreen extends StatefulWidget {

    const LogInScreen({Key? key}) : super(key: key);

    @override
    State<LogInScreen> createState() => _LogInScreenState();
  }

  class _LogInScreenState extends State<LogInScreen> {
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
      // socket.disconnect()
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
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('roomId', roomId!);
                    prefs.setString('username', username!);
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
                    child: const Text("Start Chat",style: TextStyle(
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