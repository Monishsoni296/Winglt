import 'package:buzz_chat/cloud_storage.dart';
import 'package:buzz_chat/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;
late String rid;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.rid, required this.rname})
      : super(key: key);
  final String rid;
  final String rname;
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageCoontroller = TextEditingController();
  late String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentuser();
  }

  void getCurrentuser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        rid = widget.rid;
        print(widget.rid);
        print(loggedInUser?.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
        title: Text(widget.rname,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageCoontroller,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                      child: const Text('upload', style: kSendButtonTextStyle),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UploadImagePage(rid: widget.rid),
                          ),
                        );
                      }),
                  TextButton(
                    onPressed: () {
                      messageCoontroller.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser?.uid,
                        'receiver': widget.rid,
                        'time': DateTime.now(),
                      });
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('time').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child:
                CircularProgressIndicator(backgroundColor: Colors.blueAccent),
          );
        }
        final messages = snapshot.data?.docs;
        if (messages != null) {
          List<MessageBubble> messagesBubbles = [];
          for (var message in messages) {
            final Map<String, dynamic> messageDataMap =
                message.data() as Map<String, dynamic>;
            final messageText = messageDataMap['text'];
            final messageSender = messageDataMap['sender'];
            final messageReceiver = messageDataMap['receiver'];
            final messageImg = messageDataMap['imgURL'];

            if ((messageSender != loggedInUser!.uid && messageSender != rid) ||
                (messageReceiver != rid &&
                    messageReceiver != loggedInUser!.uid)) {
              continue;
            }

            final currentUser = loggedInUser!.uid;

            final bubble = MessageBubble(
                sender: messageSender,
                text: messageText,
                isMe: currentUser == messageSender,
                url: messageImg);

            messagesBubbles.add(bubble);
          }
          return Expanded(
            child: ListView(
              //reverse: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              children: messagesBubbles,
            ),
          );
        }
        return const Column();
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String? text;
  final String sender;
  final bool isMe;
  final String? url;

  MessageBubble({
    required this.sender,
    required this.isMe,
    this.text,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(sender,
            style: const TextStyle(fontSize: 12.0, color: Colors.black54)),
        Material(
          color: isMe ? Color.fromARGB(255, 122, 211, 253) : Colors.white,
          elevation: 5.0,
          borderRadius: isMe
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                  topLeft: Radius.circular(30.0))
              : const BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                  topRight: Radius.circular(30.0)),
          child: text != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Text('$text',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: isMe ? Colors.white : Colors.black,
                      )),
                )
              : Image.network(
                  url!,
                  height: 400, width: 400,
                  // Adjust how the image fits within Material
                ),
        )
      ],
    );
  }
}
