import 'package:flutter/material.dart';
import 'package:arsh_final/screens/movie_code_screen.dart';
import 'package:arsh_final/utils/app_state.dart';
import 'package:arsh_final/utils/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final myController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isInvalid = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _formKey.currentState?.validate();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enter Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: isInvalid
            ? AlertDialog(
                title: Text('No Session Found'),
                content: Text('Please enter a valid code'),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isInvalid = false;
                        myController.text = "";
                      });
                    },
                    child: Text('OK'),
                  )
                ],
              )
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      maxLength: 4,
                      keyboardType: TextInputType.numberWithOptions(),
                      controller: myController,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter the code from your friend',
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _joinSession(int.parse(myController.text));
                    if (!isInvalid && mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MovieCodeScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 50),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                  child: Text('Submit'),
                ),
              ]),
      ),
    );
  }

  Future<void> _joinSession(code) async {
    String? deviceId = Provider.of<AppState>(context, listen: false).deviceId;
    final storageRef = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print('Code: $code');
    }
    //call api
    final response = await HttpHelper.joinSession(deviceId, code);

    if (response['data'] != null) {
      await storageRef.setString("sessionId", response['data']['session_id']);
      setState(() {
        isInvalid = false;
      });
      if (kDebugMode) {
        print(response['data']['message']);
      }
    } else {
      setState(() {
        isInvalid = true;
      });
      if (kDebugMode) {
        print(response['message']);
      }
    }
  }
}

class DialogExample extends StatelessWidget {
  const DialogExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('AlertDialog Title'),
          content: const Text('AlertDialog description'),
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
      child: const Text('Show Dialog'),
    );
  }
}
