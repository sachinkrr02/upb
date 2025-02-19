import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upbmining/Controller/coin_controller.dart';
import 'package:upbmining/Controller/device_info.dart';
import 'package:upbmining/Login/Splash.dart';
import 'package:upbmining/firebase_options.dart';
import 'package:upbmining/hive/boxes.dart';
import 'package:upbmining/hive/user_info.dart';
import 'Controller/login_controller.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserInfoAdapter());
  userInfo = await Hive.openBox<UserInfo>("userInfo");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => LoginController()),
      ChangeNotifierProvider(create: (context) => CoinController()),
      ChangeNotifierProvider(create: (context) => DeviceInfoProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
