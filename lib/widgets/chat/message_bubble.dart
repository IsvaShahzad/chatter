import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(
      this.message,
      this.isMe,
      // this.userImage,
          {
        required this.key,
        required this.chatURL,
      });

  final String message;
  final bool isMe;
  // final String userImage;
  final String chatURL;
  final Key key;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.grey[300]
                    : Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              width: 140,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 9,
              ),
              child: Column(
                crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[

                  SizedBox(
                    height: 9.0,
                  ),
                  if (chatURL.isNotEmpty)
                    Image.network(
                      chatURL,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  if (message.isNotEmpty && chatURL.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        color: isMe ? Colors.black : Colors.white,
                      ),
                      textAlign: isMe ? TextAlign.end : TextAlign.start,
                    ),
                  if (message.isNotEmpty && chatURL.isEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        color: isMe ? Colors.black : Colors.white,
                      ),
                      textAlign: isMe ? TextAlign.end : TextAlign.start,
                    ),
                  // if (message.isNotEmpty && chatURL == null)
                  //   Text(
                  //     message,
                  //     style: TextStyle(
                  //       color: isMe ? Colors.black : Colors.white,
                  //     ),
                  //     textAlign: isMe ? TextAlign.end : TextAlign.start,
                  //   ),
                ],
              ),
            ),
          ],
        ),
        // Positioned(
        //   top: 0,
        //   left: isMe ? null : 120,
        //   right: isMe ? 120 : null,
        //   // child: CircleAvatar(
        //   //   backgroundImage: NetworkImage(userImage),
        //   // ),
        // ),
      ],
      clipBehavior: Clip.none,
    );
  }
}