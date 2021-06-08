import 'dart:async';
import 'dart:io';

import 'package:flutter_zoom_plugin/zoom_view.dart';
import 'package:flutter_zoom_plugin/zoom_options.dart';

import 'package:flutter/material.dart';

class StartMeetingWidget extends StatelessWidget {

  ZoomOptions zoomOptions;
  ZoomMeetingOptions meetingOptions;

  Timer timer;

  StartMeetingWidget({Key key, meetingId}) : super(key: key) {
    this.zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      appKey: "Q9XJuMkc2cPGD1Dg87rXhpTfRSausN6gntOj", // Replace with with key got from the Zoom Marketplace
      appSecret: "mOmVNLaMAnsluNqBNYLbFI4IvyW0NxlEl4Yz", // Replace with with secret got from the Zoom Marketplace
    );
    this.meetingOptions = new ZoomMeetingOptions(
        userId: 'me',
        displayName: 'Aniket',
        meetingId: meetingId,
        zoomAccessToken: "eyJ6bV9za20iOiJ6bV9vMm0iLCJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJjbGllbnRzbSIsInVpZCI6IkkxN19USERxUU5xVl92VlM5azdqTWciLCJpc3MiOiJ3ZWIiLCJzdHkiOjEwMCwid2NkIjoidXMwMiIsImNsdCI6MCwic3RrIjoiNmNqc1Z5UHhwZ2lEdHRzcEExeVZWSEtNdFFDajZ3V0liRXJpY3djWEU0OC5CZ1lzVm1WclpUTkxWV294VVhoVldqSlJhbGRzTUVseE9FdzBja2s1UTBGWFMyMXFabmR6TVZaUVNtVkRTVDFBWWpSak1HUXlPVEpoWkRFMlpXWXdORFptTW1aaE16ZzRaREV4WkRoaU5XWTVZMlUxTlRSak9EaGpPRGxsTVdJd1lqa3lOVGd3WW1Wak9HVXdNREV3TkFBTU0wTkNRWFZ2YVZsVE0zTTlBQVIxY3pBeUFBQUJlZXZaMVg0QUVuVUFBQUEiLCJleHAiOjE2MjMxNjY3OTIsImlhdCI6MTYyMzE1OTU5MiwiYWlkIjoiRTZMS3h1bmNUajZtX1JBcG9tSFBfUSIsImNpZCI6IiJ9.9ofpzm8ps5wvU7dvD23lxIs5DrkbOufz4enTF5QaaDc",
        zoomToken: "<user_token>",
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "false",
        noAudio: "false",
        noDisconnectAudio: "false"
    );
  }

  bool _isMeetingEnded(String status) {
    var result = false;

    if (Platform.isAndroid)
      result = status == "MEETING_STATUS_DISCONNECTING" || status == "MEETING_STATUS_FAILED";
    else
      result = status == "MEETING_STATUS_IDLE";

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
          title: Text('Loading meeting '),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ZoomView(onViewCreated: (controller) {

          print("Created the view");

          controller.initZoom(this.zoomOptions)
              .then((results) {

            print("initialised");
            print(results);

            if(results[0] == 0) {

              controller.zoomStatusEvents.listen((status) {
                print("Meeting Status Stream: " + status[0] + " - " + status[1]);
                if (_isMeetingEnded(status[0])) {
                  Navigator.pop(context);
                  timer?.cancel();
                }
              });

              print("listen on event channel");

              controller.startMeeting(this.meetingOptions)
                  .then((joinMeetingResult) {

                timer = Timer.periodic(new Duration(seconds: 2), (timer) {
                  controller.meetingStatus(this.meetingOptions.meetingId)
                      .then((status) {
                    print("Meeting Status Polling: " + status[0] + " - " + status[1]);
                  });
                });

              });
            }

          }).catchError((error) {

            print("Error");
            print(error);
          });
        })
      ),
    );
  }

}
