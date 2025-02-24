import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:upbmining/Controller/coin_controller.dart';
import 'package:upbmining/Controller/device_info.dart';
import 'package:upbmining/Controller/syncCoin.dart';
import 'package:upbmining/Login/Splash.dart';
import 'package:upbmining/Login/forgotpass.dart';
import 'package:upbmining/Login/refer_page.dart';
import 'package:upbmining/Login/login.dart';
import 'package:upbmining/Home/Homepage.dart';
import 'package:upbmining/hive/boxes.dart';
import 'package:upbmining/hive/user_info.dart';
import 'Controller/login_controller.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserInfoAdapter());
  userInfo = await Hive.openBox<UserInfo>("userInfo");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginController()),
        ChangeNotifierProvider(create: (context) => CoinController()),
        ChangeNotifierProvider(create: (context) => DeviceInfoProvider()),
        ChangeNotifierProvider(create: (context) => SyncProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? referralCode;

  @override
  void initState() {
    super.initState();
    _handleDeepLink();
  }

  /// **Handles deep links and navigates accordingly**
  Future<void> _handleDeepLink() async {
    const MethodChannel deepLinkChannel = MethodChannel('deep_link_channel');

    deepLinkChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'handleDeepLink') {
        String deepLink = call.arguments;
        Uri uri = Uri.parse(deepLink);

        setState(() {
          referralCode = uri.queryParameters["ref"];
        });

        if (referralCode != null && context.mounted) {
          Navigator.pushNamed(
            context,
            '/refer',
            arguments: referralCode,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPB Mining',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/refer': (context) => ReferScreen(
              referralCode:
                  ModalRoute.of(context)!.settings.arguments as String?,
            ),
      },
    );
  }
}
