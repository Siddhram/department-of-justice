import 'dart:convert';
import 'dart:io';
// import 'package:image/image.dart' as img; // Import the image package
import 'dart:convert';
import 'dart:math';
import 'package:doj/chatbot.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:doj/ai.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart'; // Import the image_picker package

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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

  List<ChatMessage> messages = [];
  String imageUrl = "";
  String myid = "siddharamsutr@gmail.com";

  ChatUser currentUser = ChatUser(
      id: '0',
      firstName: "user",
      profileImage:
          'https://media.licdn.com/dms/image/v2/D4D03AQE5ufZYKW5V1g/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1696580075435?e=1729728000&v=beta&t=Mybc0AuOm7nHtmgmC4fFfCXYbqalOK74Om7qYE8aQgA');

  ChatUser gemini = ChatUser(
      id: '1',
      firstName: 'gemini',
      profileImage:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTQNqAXm_ahi8K8DOgGvl2fGYRcgqZ3SAyH0OFSCJDqZ3n7Dbb_cDYUihCrDpDXI_GS3E&usqp=CAU');

  @override
  void initState() {
    super.initState();
    initTts();
    initspeech();
    func();
    // firstp("");
  }

  void func() {
    ChatMessage responseMessage = ChatMessage(
      text: "Hello Namaste🙏 Greetings from Pdf summarizer ",
      user: gemini,
      createdAt: DateTime.now(),
    );
    setState(() {
      messages = [responseMessage, ...messages];
    });
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

  void speak(String text) async {
    await flutterTts.speak(text);
    // Store the AI's response as a message
    ChatMessage responseMessage = ChatMessage(
      text: text,
      user: gemini,
      createdAt: DateTime.now(),
    );
    setState(() {
      messages = [responseMessage, ...messages];
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
    final url = Uri.parse('https://find-ans-in-pdfs-b22.onrender.com/process');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      // "sessionId": session_id,
      "prompt": result,
      "url": url
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          geminitalk = data['response'].toString().replaceAll("*", "");
        });
        speak(geminitalk); // Speak and store the AI's response as a message
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
    // speak();
    // setState(() {});
  }

  void _sendMessage(ChatMessage chatMessage) async {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      print(url);
      final body = jsonEncode({
        // "sessionId": session_id,
        "prompt": question,
        "url": url
      });

      final response = await http.post(
        Uri.parse('https://find-ans-in-pdfs-b22.onrender.com/process'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        geminitalk = result['response'].toString().replaceAll("*", "");
        // speak(geminitalk); // Speak and store the AI's response as a message
        ChatMessage responseMessage = ChatMessage(
          text: geminitalk,
          user: gemini,
          createdAt: DateTime.now(),
        );
        setState(() {
          messages = [responseMessage, ...messages];
        });
      } else {
        print('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  String url = "";

  PlatformFile? pickFiles;
  UploadTask? uploadTask;
  Future sellectfile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    setState(() {
      pickFiles = result.files.first;
    });
  }

  Future uploadfile() async {
    final path = 'files/${pickFiles!.name}';
    final file = File(pickFiles!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() {});
    final urldownload = await snapshot.ref.getDownloadURL();
    setState(() {
      url = urldownload;
    });
    print(urldownload + " ----- ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 3.0),
          child: Row(
            children: [
              Container(
                // padding: EdgeInsets.all(8), // Add padding around the image
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Circular shape
                  border: Border.all(
                    color: Colors.white, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                child: CircleAvatar(
                  radius: 24, // Adjust the radius as needed
                  backgroundImage: NetworkImage(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTQNqAXm_ahi8K8DOgGvl2fGYRcgqZ3SAyH0OFSCJDqZ3n7Dbb_cDYUihCrDpDXI_GS3E&usqp=CAU', // Replace with your image URL
                  ),
                  backgroundColor: Colors
                      .transparent, // Optional: If you want no background color
                ),
              ),
              SizedBox(width: 20), // Add some spacing between the icon and text
              Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PDF to Text AI",  
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // ClipRRect(
          //   borderRadius:
          //       BorderRadius.circular(10), // Adjust the border radius if needed
          //   child: SvgPicture.network(
          //     'https://doj.gov.in/wp-content/themes/sdo-theme/images/emblem.svg', // SVG image URL
          //     width: 300, // Adjust the width as needed
          //     height: 200, // Adjust the height as needed
          //     fit: BoxFit.cover, // Adjust the fit as needed
          //   ),
          // ),
          Expanded(
            child: DashChat(
              inputOptions: InputOptions(
                trailing: [
                  IconButton(
                    icon: Icon(
                        isListening ? Icons.mic : Icons.mic_off,
                        color: isListening ? Colors.red : Colors.black,
                        ),
                    onPressed: () {
                      // sellectfile();
                      if (isListening) {
                        stopListening();
                      } else {
                        startListening();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.stop, // Stop icon
                      color: Colors.red, // Color for the stop icon
                      // Icons.upload,
                      // color: pickFiles == null
                      //     ? Colors.grey
                      //     : url == ""
                      //         ? Colors.black
                      //         : Colors.green,
                    ),
                    onPressed: () {
                      // if (pickFiles != null) {
                      //   uploadfile();
                      // }
                      stopSpeaking(); // Stops TTS when clicked
                    },
                  ),
                ],
              ),
              currentUser: currentUser,
              onSend: _sendMessage,
              messages: messages,
              messageOptions: MessageOptions(
                currentUserContainerColor:
                    Colors.black, // Background color for sent messages
                currentUserTextColor:
                    Colors.white, // Text color for sent messages
              ),
            ),
          ),
        ],
      ),
    );
  }
}
