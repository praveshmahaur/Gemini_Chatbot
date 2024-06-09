import 'dart:developer';
import 'dart:io';
//import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:typed_data'; // Correct import for Uint8List
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final gemini = Gemini.instance;
  ChatUser Me = ChatUser(id: "1", firstName: "Pravesh");
  ChatUser GeminiUser = ChatUser(id: "2", firstName: "Gemini");
  List<ChatMessage> Allmessages = [];
  List<ChatUser> typing = <ChatUser>[];

  void sendMessage(ChatMessage message) async {
    setState(() {
      typing.add(GeminiUser);
      Allmessages = [message, ...Allmessages];
      //Allmessages.insert(0, message);
    });
    try {
      String question = message.text;
      List<Uint8List>? images;
      //<List<int>> images = [];
      if (message.medias?.isNotEmpty ?? false) {
        images = [
          File(message.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastMessage = Allmessages.firstOrNull;
        if (lastMessage != null && lastMessage.user == GeminiUser) {
          lastMessage = Allmessages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous${current.text}") ??
              "";
          lastMessage.text += response;
          setState(() {
            Allmessages = [lastMessage!, ...Allmessages];
          });
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous${current.text}") ??
              "";
          ChatMessage messageG = ChatMessage(
              user: GeminiUser, createdAt: DateTime.now(), text: response);

          setState(() {
            typing.remove(GeminiUser);
            Allmessages = [messageG, ...Allmessages];
          });
        }
      });
    } catch (e) {
      log("$e");
    }
  }

  void sendImageInput() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage message = ChatMessage(
        user: Me,
        createdAt: DateTime.now(),
        text: "Describe this picture",
        medias: [
          ChatMedia(url: file.path, fileName: "", type: MediaType.image)
        ],
      );
      sendMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gemini",
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
                color: Colors.black,
                letterSpacing: .4,
                fontWeight: FontWeight.w400),
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Spacer(),
            Text("data"),
          ],
        ),
      ),
      body: DashChat(
        currentUser: Me,
        onSend: sendMessage,
        messages: Allmessages,
        typingUsers: typing,
        inputOptions: InputOptions(alwaysShowSend: true, leading: [
          IconButton(
              onPressed: () {
                sendImageInput();
              },
              icon: Icon(Icons.image))
        ]),
      ),
    );
  }
}
