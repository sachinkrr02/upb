import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upbmining/Controller/api_service.dart';
import 'package:upbmining/Controller/coin_controller.dart';
import 'package:upbmining/Controller/login_controller.dart';
import 'package:upbmining/Controller/syncCoin.dart';
import 'package:upbmining/components/drawer.dart';
import 'package:upbmining/components/sync_popup.dart';
import 'package:upbmining/hive/user_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _controller;
  bool _showCoins = false;
  double _coinPosition = 0; // Start position at bottom
  bool _isMoving = false; // Prevents multiple clicks
  bool _coinVisible = false; // Controls coin visibility

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndShowPopup();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> checkAndShowPopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastShownDate = prefs.getString('last_popup_date');
    String todayDate = DateTime.now().toIso8601String().split('T')[0];

    if (lastShownDate != todayDate) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const SyncPopup(),
        );
      });
      await prefs.setString('last_popup_date', todayDate);
    }
  }

  void _startCoinAnimation(CoinController coinProvider) {
    if (_isMoving) return;

    setState(() {
      _isMoving = true;
      _coinVisible = true;
      _coinPosition =
          MediaQuery.of(context).size.height - 150; // Start from bottom
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        _coinPosition = 100; // Move to the top slowly
      });
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _coinVisible = false;
        _isMoving = false;
      });

      coinProvider.refreshCoin();
      coinProvider.generateNumber();
    });
  }

  Future<void> _handleButtonPress(CoinController coinProvider) async {
    try {
      final userInfoBox = await Hive.openBox<UserInfo>('userInfo');

      int nextId = userInfoBox.isNotEmpty ? userInfoBox.length + 1 : 1;

      UserInfo user = UserInfo(
        id: nextId,
        accountNo: "UPB1W0ZRT22",
        reward: 4,
        blovk: coinProvider.generatedCode,
        dateTime: DateTime.now().toString(),
        isSynced: 1,
      );

      await userInfoBox.put(user.id, user);
      debugPrint('✅ User info saved');

      coinProvider.refreshCoin();
      coinProvider.generateNumber();
      debugPrint('✅ Coin refreshed and number generated');

      // Start the coin animation
      if (!_controller.isAnimating) {
        setState(() {
          _showCoins = true;
        });

        _controller.forward().then((_) {
          setState(() {
            _showCoins = false;
            _controller.reset();
          });
        });
      }
    } catch (e) {
      debugPrint('❌ Error during button press action: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred, please try again'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void shareData() async {
    try {
      String text = "Check out this amazing app!";
      String url = "https://example.com"; // Replace with your URL
      await Share.share("$text\n$url");
    } catch (e) {
      debugPrint("Error sharing: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to share data!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CoinController, LoginController>(
        builder: (context, coin, login, _) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          backgroundColor: Colors.white,
        ),
        drawer: const CustomDrawer(),
        onDrawerChanged: (isOpened) {
          if (isOpened) {
            // Call your API function when the drawer is opened
            Provider.of<LoginController>(context, listen: false)
                .fetchUserById();
          }
        },
        body: Stack(
          children: [
            if (_coinVisible)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOut,
                left: MediaQuery.of(context).size.width / 2 - 25,
                top: _coinPosition,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/fav.png', // Replace with your coin image
                      width: 40,
                      height: 40,
                    ),
                    Image.asset(
                      'assets/images/fav.png', // Replace with your coin image
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  coin.coinValue.toString(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    coin.binaryOutput,
                    style: const TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: NeoPopTiltedButton(
                  isFloating: true,
                  onTapUp: () async {
                    _startCoinAnimation(coin);
                    _handleButtonPress(coin);
                    await login.fetchUserById();
                  },
                  decoration: const NeoPopTiltedButtonDecoration(
                    color: Color.fromRGBO(255, 235, 52, 1),
                    plunkColor: Color.fromRGBO(255, 235, 52, 1),
                    shadowColor: Color.fromRGBO(36, 36, 36, 1),
                    showShimmer: true,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 70.0,
                      vertical: 15,
                    ),
                    child: Text('Play Now'),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
