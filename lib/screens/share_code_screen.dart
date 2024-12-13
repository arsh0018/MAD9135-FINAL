import 'package:arsh_final/screens/movie_code_screen.dart';
import 'package:arsh_final/utils/app_state.dart';
import 'package:arsh_final/utils/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShareCodeScreen extends StatefulWidget {
  const ShareCodeScreen({super.key});

  @override
  State<ShareCodeScreen> createState() => _ShareCodeScreenState();
}

class _ShareCodeScreenState extends State<ShareCodeScreen> {
  String code = "Unset";

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Share Code',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Column(
            children: [
              Text('Code: $code'),
              Text('Share this code with your friend'),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MovieCodeScreen()),
                  );
                },
                child: Text('Begin'),
              )
            ],
          ),
        ));
  }

  Future<void> _startSession() async {
    String? deviceId = Provider.of<AppState>(context, listen: false).deviceId;

    final storageRef = await SharedPreferences.getInstance();

    if (kDebugMode) {
      print('Device id from Share Code Screen: $deviceId');
    }
    //call api
    final response = await HttpHelper.startSession(deviceId);

    storageRef.setString("sessionId", response['data']['session_id']);
    if (kDebugMode) {
      print(response['data']['code']);
    }
    setState(() {
      code = response['data']['code'];
    });
  }
}
