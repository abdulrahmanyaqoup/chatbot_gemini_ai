// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:chatbot_gemini_ai/View/loading.dart';
import 'package:chatbot_gemini_ai/constant.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _chatHistory = [];
  String? _file;
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  late final ChatSession _chat;
  bool is_loading = false;
  @override
  void initState() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-001',
      apiKey: API_KEY,
    );
    _visionModel = GenerativeModel(
      model: 'gemini-1.5-pro-001',
      apiKey: API_KEY,
    );
    _chat = _model.startChat();
    super.initState();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void getAnswer(text) async {
    is_loading = true;
    late final GenerateContentResponse response;
    if (_file != null) {
      final firstImage = await (File(_file!).readAsBytes());
      final prompt = TextPart(text);
      final imageParts = [
        DataPart('image/jpeg', firstImage),
      ];
      response = await _visionModel.generateContent([
        Content.multi([prompt, ...imageParts]),
      ]);
      _file = null;
    } else {
      var content = Content.text(text.toString());
      response = await _chat.sendMessage(content);
    }
    setState(() {
      is_loading = false;
      _chatHistory.add({
        "time": DateTime.now(),
        "message": response.text,
        "isSender": false,
        "isImage": false
      });
      _file = null;
      _chatController.clear();
    });

    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.14,
        backgroundColor: const Color.fromARGB(255, 18, 106, 82),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rubix AI",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              " Ask Me Anything You Want !",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 160,
              child: ListView.builder(
                itemCount: _chatHistory.length,
                shrinkWrap: false,
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      _chatHistory[index]["isSender"]
                          ? _chatHistory[index]["time"] != null
                              ? (_chatHistory[index]["time"] == "")
                                  ? const Text("")
                                  : Column(
                                      children: [
                                        Text(
                                          DateFormat.EEEE()
                                              .format(
                                                  _chatHistory[index]["time"])
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF74AA9C),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          _chatHistory[index]["time"]
                                              .toString()
                                              .substring(10, 16),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF74AA9C),
                                          ),
                                        ),
                                      ],
                                    )
                              : const SizedBox(
                                  height: 0,
                                  width: 0,
                                )
                          : const SizedBox(
                              height: 0,
                              width: 0,
                            ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 14, right: 14, top: 10, bottom: 10),
                        child: Align(
                          alignment: (_chatHistory[index]["isSender"]
                              ? Alignment.topRight
                              : Alignment.topLeft),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              color: (_chatHistory[index]["isSender"]
                                  ? const Color.fromARGB(255, 18, 106, 82)
                                  : const Color.fromARGB(255, 168, 227, 211)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: _chatHistory[index]["isImage"]
                                ? Image.file(
                                    File(_chatHistory[index]["message"]),
                                    width: 200,
                                  )
                                : Text(
                                    _chatHistory[index]["message"],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: _chatHistory[index]["isSender"]
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: (is_loading == true)
                    ? const ThreeDots()
                    : Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              onPressed: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['jpg', 'jpeg', 'png'],
                                );
                                if (result != null) {
                                  setState(() {
                                    _file = result.files.first.path;
                                  });
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0),
                              ),
                              child: Ink(
                                height: 50,
                                width: 50,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    _file == null ? Icons.image : Icons.check,
                                    color:
                                        const Color.fromARGB(255, 18, 106, 82),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 18, 106, 82),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50.0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: TextField(
                                  cursorColor: Colors.black,
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(50.0),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(50.0),
                                      ),
                                    ),
                                    hintText: "Type a message",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(50.0),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(8.0),
                                  ),
                                  controller: _chatController,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: MaterialButton(
                              onPressed: () {
                                setState(() {
                                  if (_chatController.text.isNotEmpty) {
                                    if (_file != null) {
                                      _chatHistory.add({
                                        "time": DateTime.now(),
                                        "message": _file,
                                        "isSender": true,
                                        "isImage": true
                                      });
                                    }
                                    _chatHistory.add({
                                      "time":
                                          _file == null ? DateTime.now() : "",
                                      "message": _chatController.text,
                                      "isSender": true,
                                      "isImage": false
                                    });
                                  }
                                });
                                _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent,
                                );
                                getAnswer(_chatController.text);
                                _chatController.clear();
                                FocusScope.of(context).unfocus();
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0),
                              ),
                              child: Ink(
                                height: 50,
                                width: 50,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.send,
                                    color: Color.fromARGB(255, 18, 106, 82),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
