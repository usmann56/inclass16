import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;
  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("messaging");
    messaging.getToken().then((value) {
      print(value);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      final type = event.data['type'] ?? "regular";
      final category = event.data['category'] ?? '';
      final message = event.notification?.body ?? "No message";
      final notificationTitle = event.notification?.title ?? "No title";

      _showCustomNotificationDialog(
        context,
        type,
        category,
        message,
        notificationTitle,
      );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  void _showCustomNotificationDialog(
    BuildContext context,
    String type,
    String category,
    String message,
    String notificationTitle,
  ) {
    Color bgColor = Colors.grey.shade200;
    IconData icon = Icons.message;

    switch (type) {
      case "important":
        bgColor = Colors.red.shade100;
        icon = Icons.warning;
        break;

      case "motivational":
        bgColor = Colors.blue.shade100;
        icon = Icons.emoji_events; // trophy icon
        break;

      case "wisdom":
        bgColor = Colors.purple.shade100;
        icon = Icons.lightbulb;
        break;

      case "regular":
      default:
        bgColor = Colors.grey.shade200;
        icon = Icons.message;
    }

    switch (category) {
      case "funny":
        bgColor = Colors.yellow.shade200;
        icon = Icons.emoji_emotions;
        break;

      case "love":
        bgColor = Colors.red.shade200;
        icon = Icons.favorite;
        break;

      case "success":
        bgColor = Colors.green.shade200;
        icon = Icons.stars;
        break;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 10),
            Text(notificationTitle.toUpperCase()),
          ],
        ),
        content: Text(message, style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      body: Center(child: Text("Messaging Tutorial")),
    );
  }
}
