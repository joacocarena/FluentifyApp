import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String lastWords = "";

  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    controller = TextEditingController();
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  //? Functions:
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(); // initialize the speaking function
    setState(() {});
  }

  void startListening() async {
    await _speechToText.listen(onResult: onSpeechResult);
    setState(() {
      
    });
  }

  void stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult res) {
    setState(() {
      lastWords = "${res.recognizedWords}";
    });
  }

  void onTextChanged(String text) {
    setState(() {
      lastWords = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluentify'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {}, 
              icon: const Icon(Icons.menu)
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 35, left: 20),
              child: const Align(
                alignment: Alignment.topLeft,
                child: Text('Translator', style: TextStyle(fontSize: 30))
              ),
            ),
            const SizedBox(height: 55),
      
            //? Request box:
            MessageBox(message: lastWords),
      
            const SizedBox(height: 20),
            Transform.rotate(
              angle: pi/2,
              child: FaIcon(FontAwesomeIcons.rightLeft, size: 30, color: Colors.cyan.shade400,),
            ),
            const SizedBox(height: 20),
      
            //? Response box:
            MessageBox(message: "resp"), //TODO: CHANGE THE TEXT BODY TO THE TRANSLATOR RESPONSE.
            const SizedBox(height: 60),
      
            //? prompt:
            Container(
              margin: const EdgeInsets.only(top: 90),
              child: SizedBox(
                height: 72,
                width: MediaQuery.of(context).size.width * .9,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      top: 0,
                      child: InputField(
                        speechToText: _speechToText, 
                        startListening: startListening,
                        stopListening: stopListening,
                        onTextChanged: onTextChanged,
                      )
                    ),
                    
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final SpeechToText speechToText;
  final VoidCallback startListening;
  final VoidCallback stopListening;
  final Function(String) onTextChanged;

  const InputField({super.key, required this.speechToText, required this.startListening, required this.stopListening, required this.onTextChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.cyan[100],
        borderRadius: const BorderRadius.only(topRight: Radius.circular(35), bottomRight: Radius.circular(35)),
      ), 
      child: Row(
        children: [
          Expanded(
            child: Container(             
              width: MediaQuery.of(context).size.width * .8,
              padding: const EdgeInsets.only(left: 20),
              child: TextField(
                onChanged: onTextChanged,
                decoration: const InputDecoration(
                  hintText: 'Type anything...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 80,
            width: 75,
            child: IconButton.filled(
              onPressed: speechToText.isNotListening ? startListening : stopListening,
              icon: Icon(speechToText.isNotListening ? Icons.mic_off : Icons.mic, color: Colors.white,),
              color: Colors.lightBlue.shade400,
              iconSize: 35,
            ),
          )
        ],
      ),
    );
  }
}

class MessageBox extends StatefulWidget {
  final String message;
  const MessageBox({super.key, required this.message});

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 320,
        height: 160,
        color: Colors.cyan.shade100,
        child: Center(child: Text(widget.message, style: const TextStyle(fontSize: 20))),
      ),
    );
  }
}