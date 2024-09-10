import 'dart:convert';
import 'package:doj/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AIpage extends StatefulWidget {
  final String data;
  AIpage({Key? key, required this.data}) : super(key: key);

  @override
  State<AIpage> createState() => _AIpageState();
}

class _AIpageState extends State<AIpage> {
  FlutterTts flutterTts = FlutterTts();
  Map? currentVoice;
  String ttsInput = "";
  String session_id = "siddharamsutar23@gmail.com";
  final SpeechToText _speechToText = SpeechToText();
  bool seppChEnable = false;
  String wordspoken = "";
  double confidence = 0;
  bool isListening = false;
  String geminitalk = "";

  @override
  void initState() {
    super.initState();
    initTts();
    initspeech();
    // firstp("");
  }

  void initTts() async {
    try {
      var voices = await flutterTts.getVoices;
      List<Map> _voices = List<Map>.from(voices);
      _voices =
          _voices.where((_voice) => _voice["name"].contains("en")).toList();
      if (_voices.isNotEmpty) {
        setVoice(_voices.first);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void setVoice(Map voice) {
    flutterTts.setVoice({
      "name": voice["name"],
      "locale": voice["locale"],
    });
    setState(() {
      currentVoice = voice;
    });
  }

  void speak() {
    setState(() {
      String a = geminitalk;
      flutterTts.speak(a);
    });
  }

  void stopSpeaking() async {
    await flutterTts.stop(); // Stops the TTS immediately
  }

  void initspeech() async {
    try {
      seppChEnable = await _speechToText.initialize(
        onError: (errorNotification) {
          print("Speech recognition initialization error: $errorNotification");
        },
        onStatus: (status) {
          print("Speech recognition status: $status");
        },
      );
      if (seppChEnable) {
        setState(() {});
      } else {
        print("Speech recognition not available on this device");
        setState(() {
          seppChEnable = false;
        });
      }
    } catch (e) {
      print("An error occurred during initialization: $e");
      setState(() {
        seppChEnable = false;
      });
    }
  }

  void startListening() async {
    if (wordspoken.isNotEmpty) {
      setState(() {
        geminitalk = "";
      });
    }

    await _speechToText.listen(
      onResult: onSpeechResult,
    );
    setState(() {
      confidence = 0;
      isListening = true;
    });
  }

  Future<void> gemitext(String result) async {
    final url = Uri.parse('https://jsgemiintegration.onrender.com/history');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode(
        {
           "sessionId": "siddharamsutar23@gmail.com",
      "prompt": result + widget.data + ""
          });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          geminitalk = data['response'].toString().replaceAll("*", "");
          // session_id = data['session_id'].toString();
        });
        speak();
      } else {
        print("Failed to get response from API");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> firstp(String result) async {
    print(result + widget.data);
    final url = Uri.parse('https://jsgemiintegration.onrender.com/history');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      // "prompt": result + widget.data + "",
      // "image_url": "",
      // "session_id": session_id
       "sessionId":"siddharamsutar23@gmail.com",
    "prompt": result + widget.data + ""
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          geminitalk = data['response'].toString().replaceAll("*", "") + "";
          // session_id = data['session_id'].toString();
        });

        speak();
      } else {
        print("Failed to get response from API");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      wordspoken = "${result.recognizedWords}";
      confidence = result.confidence;
    });
    if (!_speechToText.isListening) {
      startListening(); // Restart listening if it stops automatically
    }
  }

  void stopListening() async {
    await _speechToText.stop();
    setState(() {
      isListening = false;
    });
    await gemitext(wordspoken);
    speak();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Row(
            children: [
              Text('Department of Justice',
                  style: TextStyle(color: Colors.white)),
              Icon(Icons.balance, size: 28, color: Colors.white),
            ],
          ),
        ),
      ),
      // drawer: Drawer(
      //   // backgroundColor: Colors.white,
      //   // surfaceTintColor: Colors.amber,
      //   // shadowColor: Colors.white,
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: <Widget>[
      //       DrawerHeader(
      //         decoration: BoxDecoration(
      //           color: Colors.black,
      //         ),
      //         child: Text(
      //           'Navigation',
      //           style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 24,
      //           ),
      //         ),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.home),
      //         title: Text('Home Page'),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => Homepage()),
      //           );
      //         },
      //       ),
      //       // ListTile(
      //       //   leading: Icon(Icons.chat),
      //       //   title: Text('AI Page'),
      //       //   onTap: () {
      //       //     Navigator.push(
      //       //       context,
      //       //       MaterialPageRoute(builder: (context) => AIpage(data: "")),
      //       //     );
      //       //   },
      //       // ),
      //     ],
      //   ),
      // ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                child: Text(
                  isListening
                      ? "Listening..."
                      : seppChEnable
                          ? "Tap the microphone to listen..."
                          : "Speech is not available",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'MyCustomFont',
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Text(
                            wordspoken,
                            style: TextStyle(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    geminitalk != ""
                        ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        "AI response : \n",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        geminitalk,
                                        style: TextStyle(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Text(''),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (currentVoice != null)
                  Text(
                    "Current Voice: AI",
                    style: TextStyle(fontSize: 18),
                  ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'listen_button', // Unique tag
                  backgroundColor: Colors.black,
                  onPressed: () {
                    if (isListening) {
                      stopListening();
                    } else {
                      startListening();
                    }
                  },
                  tooltip: 'Listen',
                  child: Icon(
                    isListening ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: 'stop_button', // Unique tag
                  backgroundColor: Colors.red,
                  onPressed: stopSpeaking, // Stop TTS when clicked
                  tooltip: 'Stop',
                  child: Icon(
                    Icons.stop,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: 'chat_button', // Unique tag
                  backgroundColor: Colors.black,
                  onPressed: () {
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Homepage()),
                      );
                    } catch (e) {
                      print('Error navigating to Homepage: $e');
                    }
                  },
                  tooltip: 'Chat',
                  child: Icon(
                    Icons.chat,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),

            SizedBox(height: 20),
            //             SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.black, // Background color
            //         shape: CircleBorder(), // Circular shape
            //         padding: EdgeInsets.all(20), // Padding to increase size
            //       ),
            //       onPressed: (){
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(builder: (context) => Homepage()),
            //         );
            //       },
            //       child: Icon(
            //         Icons.chat,
            //         color: Colors.white,
            //         size: 24, // Icon size
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
