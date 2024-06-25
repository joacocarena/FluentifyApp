import 'dart:async';
import 'dart:math';

import 'package:fluentify/services/translate_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  String translatedText = "";
  String sourceLang = "English"; //? default value
  String targetLang = "Spanish"; //? default value
  Timer? debounce;

  late TextEditingController controller;
  final ScrollController scrollController = ScrollController();
  bool showAppBarBg = true;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    controller = TextEditingController();
    scrollController.addListener(onScroll);
  }
  
  @override
  void dispose() {
    controller.dispose();
    debounce?.cancel();
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    super.dispose();
  }

  //? Functions:
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(); // initialize the speaking function
    setState(() {});
  }

  void startListening() async {
    await _speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  void stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void onScroll() {
    if (scrollController.position.userScrollDirection == ScrollDirection.reverse) { // scrolling down...
      setState(() {
        showAppBarBg = false;
      });
    } else if (scrollController.position.userScrollDirection == ScrollDirection.forward) { // scrolling up
      setState(() {
        showAppBarBg = true;
      });
    }
  }

  void onSpeechResult(SpeechRecognitionResult res) {
    setState(() {
      lastWords = res.recognizedWords;
      onTextChanged(lastWords);
    });
  }

  void onTextChanged(String text) {
    setState(() {
      lastWords = text;
    });
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 800), () {translateText(text);});
  }

  Future<void> translateText(String text) async {
    if (text.isEmpty) {
      setState(() {
        translatedText = "";
      });
      return;
    }
    try {
      final translation = await TranslateService.translateText(
        text, 
        TranslateService.getLanguageCode(sourceLang), 
        TranslateService.getLanguageCode(targetLang),
      );
      setState(() {
        translatedText = translation;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Translation Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        title: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          height: 55,
        ),
        backgroundColor: Colors.transparent,
      ),

      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // ignore: avoid_unnecessary_containers
            Container( //? Language selector
              child: Column(
                children: [
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        padding: const EdgeInsets.only(left: 12, right: 5),
                        color: Colors.cyan.shade100,
                        child: DropdownButton<String>(
                          value: sourceLang,
                          isExpanded: true,
                          iconEnabledColor: Colors.blue.shade600,
                          iconSize: 25,
                          underline: const SizedBox(),
                          items: TranslateService.languages.map((Map<String, String> lang) {
                            return DropdownMenuItem<String>(
                              value: lang['name'],
                              child: Text(lang['name']!)
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              sourceLang = newValue!;
                            });
                          }
                        ),
                      ),
                      const SizedBox(width: 15),
                      FaIcon(FontAwesomeIcons.arrowRightArrowLeft, color: Colors.blue.shade200, size: 28),
                      const SizedBox(width: 15),

                      Container(
                        width: 120,
                        padding: const EdgeInsets.only(left: 12, right: 5),
                        color: Colors.cyan.shade100,
                        child: DropdownButton<String>(
                          value: targetLang,
                          isExpanded: true,
                          iconEnabledColor: Colors.blue.shade600,
                          iconSize: 25,
                          underline: const SizedBox(),
                          items: TranslateService.languages.map((Map<String, String> lang) {
                            return DropdownMenuItem<String>(
                              value: lang['name'],
                              child: Text(lang['name']!)
                            );
                          }).toList(), 
                          onChanged: (String? newValue) {
                            setState(() {
                              targetLang = newValue!;
                            });
                          }
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 10),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        final temp = sourceLang;
                        sourceLang = targetLang;
                        targetLang = temp;
                      });
                    }, 
                    icon: FaIcon(FontAwesomeIcons.arrowsRotate, color: Colors.blue.shade500, size: 32)
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
      
            //? Request box:
            MessageBox(message: lastWords),
      
            const SizedBox(height: 20),
            Transform.rotate(
              angle: pi/2,
              child: FaIcon(FontAwesomeIcons.rightLeft, size: 30, color: Colors.blue.shade200,),
            ),
            const SizedBox(height: 20),
      
            //? Response box:
            MessageBox(message: translatedText),
      
            //? prompt:
            Container(
              margin: const EdgeInsets.only(top: 60),
              child: SizedBox(
                height: 65,
                width: MediaQuery.of(context).size.width * .9,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 10,
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
            height: 90,
            width: 70,
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
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(child: Text(
            widget.message, 
            style: const TextStyle(fontSize: 20),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          )),
        ),
      ),
    );
  }
}