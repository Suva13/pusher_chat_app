import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  List data = [];

  String sendText = '';
  String channelNameText = '';
  String channelEventText = '';

  @override
  void initState() {
    pusherChannelSubscribeMethod();
    super.initState();
  }

  void pusherChannelSubscribeMethod() async {
    try {
      await pusher.init(
        apiKey: "0d6f63f09f5793d59753",
        cluster: "eu",
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
      );
      await pusher.subscribe(channelName: 'my-channel');
      await pusher.connect();
    } catch (e) {
      print("ERROR: $e");
    }
  }

  void onEvent(PusherEvent event) {
    print("onEvent: ${event.data}");
    print("channel name: ${event.channelName}");

    setState(() {
      if (event.data.length > 0) {
        data.add({
          "send": 1,
          "message": event.data,
        });
      }
    });
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    print("onSubscriptionSucceeded: $channelName data: $data");
  }

  void onSubscriptionError(String message, dynamic e) {
    print("onSubscriptionError: $message Exception: $e");
  }

  void onDecryptionFailure(String event, String reason) {
    print("onDecryptionFailure: $event reason: $reason");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    print("onMemberAdded: $channelName member: $member");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    print("onMemberRemoved: $channelName member: $member");
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    print("Connection: $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    print("onError: $message code: $code exception: $e");
  }

  void send() async {
  final response = await http.post(
    Uri.parse('http://192.168.29.230:3000/send-message'),
    headers: {"Content-Type": "application/json"},
    body: '{"channel": "my-channel", "message": "$sendText"}',
  );

  if (response.statusCode == 200) {
    print('Message sent successfully');
  } else {
    print('Failed to send message. Error: ${response.reasonPhrase}');
  }
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
            child: Column(
          children: [
            Expanded(
              flex: 8,
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  if (data[index]['send'] == 0) {
                    return Text(
                      data[index]['message'],
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 16),
                    );
                  } else {
                    return Text(
                      data[index]['message'],
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 16),
                    );
                  }
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                      flex: 9,
                      child: TextFormField(
                        onChanged: (data) {
                          setState(() {
                            sendText = data;
                          });
                        },
                      )),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: send,
                      child: const Icon(
                        Icons.send_sharp,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        )),
      ),
    );
  }
}
