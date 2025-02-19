import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upbmining/Controller/coin_controller.dart';
import 'package:upbmining/components/drawer.dart';
import 'package:upbmining/components/sync_popup.dart';
import 'package:upbmining/hive/boxes.dart';
import 'package:upbmining/hive/user_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final String binaryText =
      List.generate(700, (index) => index.isEven ? '1' : '0').join(' ');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndShowPopup();
    });
  }

  /// Function to check if popup has already been shown today
  Future<void> checkAndShowPopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the last shown date
    String? lastShownDate = prefs.getString('last_popup_date');
    String todayDate =
        DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format

    if (lastShownDate != todayDate) {
      // Show the popup since it's a new day
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          barrierDismissible: false, // Prevents dismissing by tapping outside
          builder: (context) => const SyncPopup(),
        );
      });

      // Save the new date
      await prefs.setString('last_popup_date', todayDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoinController>(builder: (context, coin, _) {
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
        body: Stack(
          children: [
            // Display the updated coin value
            Positioned(
              top: 10,
              left: 0,
              right: 0, // This ensures the text is centered horizontally
              child: Center(
                child: Text(
                  coin.coinValue.toString(),
                  // Get the coin value from CoinController
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),

            // Scrollable binary text
            Positioned(
              top: 50,
              left: 0,
              right: 0, // This ensures that the text is horizontally centered
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
            // ElevatedButton(
            //     onPressed: () {
            //       showDialog(
            //         context: context,
            //         barrierColor: Colors.black
            //             .withOpacity(0.5), // Semi-transparent background
            //         builder: (context) => const SyncPopup(),
            //       );
            //     },
            //     child: const Text("Sync")),

            // Animated button positioned at the bottom
            const Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedButton(),
            ),
          ],
        ),
      );
    });
  }

  Widget _infoBox(String title, String value) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _simpleContainer(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({super.key});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentId = 1; // Start ID at 1

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);

    // Initialize _currentId based on existing data
    _initializeCurrentId();
  }

  Future<void> _initializeCurrentId() async {
    try {
      if (userInfo.isNotEmpty) {
        // Find the highest existing ID and increment it
        List<int> keys = userInfo.keys.cast<int>().toList();
        _currentId =
            (keys.isEmpty) ? 1 : keys.reduce((a, b) => a > b ? a : b) + 1;
      }
    } catch (e) {
      debugPrint('Error initializing current ID: $e');
    }
  }

  void _handleButtonPress(CoinController coinProvider) async {
    try {
      // Store user info with proper error handling
      if (!userInfo.isOpen) {
        userInfo = await Hive.openBox('userInfo');
      }

      final userInfoKey = _currentId;
      final userInfoValue = UserInfo(
        id: _currentId.toString(),
        account_no: "UPB1W0ZRT22",
        reward: "4",
        generated_code: coinProvider.generatedCode,
        date_time: DateTime.now(),
      );

      userInfo.put(userInfoKey, userInfoValue);
      debugPrint('✅ User info saved with key: $userInfoKey');

      // Call provider methods with error handling
      coinProvider.refreshCoin();
      coinProvider.generateNumber();
      debugPrint('✅ Coin refreshed and number generated');

      // Print all stored user info
      _printLastUserInfo();

      // Increment the ID for the next input
      setState(() {
        _currentId++;
      });
      // userInfo.close();
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

  void _printLastUserInfo() {
    try {
      if (userInfo.isNotEmpty) {
        final lastKey = userInfo.keys.last;
        final storedUserInfo = userInfo.get(lastKey) as UserInfo?;

        if (storedUserInfo != null) {
          debugPrint('🗂️ Last Stored User Info:');
          debugPrint('-----------------------------------');
          debugPrint('ID: ${storedUserInfo.id}');
          debugPrint('Account No: ${storedUserInfo.account_no}');
          debugPrint('Reward: ${storedUserInfo.reward}');
          debugPrint('Generated Code: ${storedUserInfo.generated_code}');
          debugPrint('Date Time: ${storedUserInfo.date_time}');
          debugPrint('-----------------------------------');
        } else {
          debugPrint('❌ No user info found for the last key.');
        }
      } else {
        debugPrint('❌ User info box is empty.');
      }
    } catch (e) {
      debugPrint('❌ Error printing last user info: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoinController>(
      builder: (context, coinProvider, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: ScaleTransition(
            scale: _animation,

            child: NeoPopTiltedButton(
              isFloating: true,
              onTapUp: () {
                _handleButtonPress(coinProvider);
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
            // child: ElevatedButton(
            //   onPressed: () => _handleButtonPress(coinProvider),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.green,
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            //   ),
            //   child: const Text(
            //     "Tap Me",
            //     style: TextStyle(fontSize: 18),
            //   ),
            // ),
          ),
        );
      },
    );
  }
}
