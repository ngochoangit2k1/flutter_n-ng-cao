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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
Future _firebaseBackgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
}
class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });

  String? title;
  String? body;
}
class _MyHomePageState extends State<MyHomePage> {

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

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if(message.notification != null){
        print("message recieved");
        print(message.notification!.title);
        print(message.notification!.body);
      };

      PushNotification newNotification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
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
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
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
      body: Center(


      ),
     
    );
  }
}
