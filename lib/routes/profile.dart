import 'package:ctl_client/routes/component/claim.dart';
import 'package:flutter_web/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InheritedSession extends InheritedWidget {
  final String sessionID;

  InheritedSession({this.sessionID, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(InheritedSession);
  }
}

class Profile extends StatefulWidget {
  final String _sessionID;

  Profile(this._sessionID);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> _userCache;
  bool isLoaded = false;

  _ProfileState();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Text("CTL Client"),
        ),
      ),
      body: isLoaded
          ? InheritedSession(
              sessionID: widget._sessionID,
              child: ProfileDisplay(_userCache),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<void> loadUser() async {
    final String sessionID = widget._sessionID;
    final response = await http
        .get("http://localhost:8081/profile", headers: {"Session": sessionID});
    setState(() {
      _userCache = json.decode(response.body);
      isLoaded = true;
    });
  }
}

class ProfileDisplay extends StatelessWidget {
  final ProfileData profileData;

  ProfileDisplay(Map<String, dynamic> rawUser)
      : profileData = ProfileData.fromJson(rawUser);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Card(
                  color: Colors.deepOrange,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ProfileComponent("Name", profileData.username),
                            ProfileComponent("Email", profileData.email),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ProfileComponent("Last Claimed",
                                profileData.lastClaimTime.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ClaimView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileData {
  final String username;
  final String email;
  final int lastClaimTime;

  const ProfileData(this.username, this.email, this.lastClaimTime);

  ProfileData.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        email = json['email'],
        lastClaimTime = json['time'];
}

class ProfileComponent extends StatelessWidget {
  final String _title;
  final String _content;

  ProfileComponent(this._title, this._content);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            Text(
              _title,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            Text(
              _content,
              style: TextStyle(
                fontSize: 20,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
