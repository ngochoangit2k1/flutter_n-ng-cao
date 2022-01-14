import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page', body: "",),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.body}) : super(key: key);

  final String title;
  final String body;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
class PushNotification {
  PushNotification({
    this.title,
    this.body,
    this.dataTitle,
    this.dataBody,
  });

  String? title;
  String? body;
  String? dataTitle;
  String? dataBody;
}



class _MyHomePageState extends State<MyHomePage> {
  late int _totalNotifications;
  PushNotification? _notificationInfo;
  List<PushNotification> _listNotification  = [];

  void registerNotification() async {
    WidgetsFlutterBinding.ensureInitialized();// tiện ích rung khi có thông báo
    await Firebase.initializeApp();

    FirebaseMessaging.instance.getToken().then((token){
      print('FCM TOKEN');
      print(token);
      print('end.');
    });

    FirebaseMessaging.instance.getInitialMessage().then((message)=> null);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if(message.notification != null){
        print("message recieved");
        print(message.notification!.title);
        print(message.notification!.body);
      };


      PushNotification newNotification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );
      setState(() {
        _listNotification = List.from(_listNotification)
          ..add(newNotification);
      });




    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("message recieved");
      print(message.notification!.title);
      print(message.notification!.body);
      PushNotification newNotification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      setState(() {
        _listNotification = List.from(_listNotification)
          ..add(newNotification);
      });

    });



      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(message.notification!.title.toString()),
              content: Text(message.notification!.body!),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            );
          });
    });
  }

  void removeItem(var index){
    List<PushNotification> _newList = _listNotification;
    var n = _newList.removeAt(index);

    setState(() {
      _listNotification = _newList;
    });
  }

  void removeItemAll(){
    print("Clear Notification");
    setState(() {
      _listNotification = [];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    registerNotification();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: ListView.separated(

        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: _listNotification.length,
        itemBuilder:(BuildContext context, int index) {
        return  Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              
              Text(
                'TITLE: ${_notificationInfo!.title}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight:  FontWeight.bold,
                    color: Colors.blue
                ),
              ),
              Text(
                'BODY: ${_notificationInfo!.body}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight:  FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: Colors.teal
                ),
              ),
              IconButton(
                  onPressed: ()=>showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(widget.title),
                      content: Text(widget.body),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),


                  icon: Icon(
                      Icons.arrow_drop_down, color: Colors.red
                  )
              )
            ],
          ),
        );

        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => removeItemAll(),
        backgroundColor: Colors.red,
        child: const Icon(Icons.remove_circle_outline),
      ),
     
    );
  }
}
