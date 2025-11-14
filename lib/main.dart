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
      final type = event.data['type'] ?? "";
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
    Curve animationCurve = Curves.easeInOut;
    double scaleFactor = 1.0;
    bool typeHandled = false;

    String? getFontForType(String type) {
      switch (type) {
        case "important":
          return "Arial";
        case "motivational":
          return "Roboto";
        case "wisdom":
          return "Georgia";
        default:
          return null;
      }
    }

    String? getFontForCategory(String category) {
      switch (category) {
        case "funny":
          return "Courier New";
        case "love":
          return "Times New Roman";
        case "success":
          return "Verdana";
        default:
          return null;
      }
    }

    final resolvedFont = getFontForType(type) ?? getFontForCategory(category);

    switch (type) {
      case "important":
        bgColor = Colors.red.shade100;
        icon = Icons.warning;
        animationCurve = Curves.elasticOut;
        scaleFactor = 1.1;
        typeHandled = true;
        break;

      case "motivational":
        bgColor = Colors.blue.shade100;
        icon = Icons.emoji_events;
        animationCurve = Curves.decelerate;
        scaleFactor = 1.05;
        typeHandled = true;
        break;

      case "wisdom":
        bgColor = Colors.purple.shade100;
        icon = Icons.lightbulb;
        animationCurve = Curves.fastOutSlowIn;
        scaleFactor = 1.07;
        typeHandled = true;
        break;
    }

    if (!typeHandled) {
      switch (category) {
        case "funny":
          bgColor = Colors.yellow.shade200;
          icon = Icons.emoji_emotions;
          animationCurve = Curves.bounceOut;
          scaleFactor = 1.15;
          break;

        case "love":
          bgColor = Colors.pink.shade200;
          icon = Icons.favorite;
          animationCurve = Curves.easeInCirc;
          scaleFactor = 1.08;
          break;

        case "success":
          bgColor = Colors.green.shade200;
          icon = Icons.stars;
          animationCurve = Curves.easeOutBack;
          scaleFactor = 1.12;
          break;
      }
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (_, __, ___) => SizedBox(),
      transitionBuilder: (_, animation, __, child) {
        return Transform.scale(
          scale: Tween<double>(begin: 0.85, end: scaleFactor)
              .animate(
                CurvedAnimation(parent: animation, curve: animationCurve),
              )
              .value,
          child: Opacity(
            opacity: animation.value,
            child: AlertDialog(
              backgroundColor: bgColor.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 30, color: Colors.black),
                        const SizedBox(width: 10),
                        Text(
                          notificationTitle,
                          style: TextStyle(
                            fontFamily: resolvedFont ?? 'RobotoCondensed',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: TextStyle(
                        fontFamily: resolvedFont ?? 'Roboto',
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "OK",
                          style: TextStyle(
                            fontFamily: resolvedFont ?? 'RobotoCondensed',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
