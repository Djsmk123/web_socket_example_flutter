import 'imports.dart';
//Stream setup
class StreamSocket{
  // stream controller

  final _socketResponse= StreamController<dynamic>();

  // this getter function will add new response to stream

  void Function(dynamic) get addResponse => _socketResponse.sink.add;

  // this getter function will fetch response from stream

  Stream<dynamic> get getResponse => _socketResponse.stream;

  // before disposing stateful widget we will call this for disposing stream.

  void dispose(){
    _socketResponse.close();
  }

}