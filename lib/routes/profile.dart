import 'package:flutter_web/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Profile extends StatefulWidget {
  final String _sessionID;

  Profile(this._sessionID);

  @override
  _ProfileState createState() => _ProfileState(_sessionID);
}

class _ProfileState extends State<Profile> {
  final String _sessionID;

  Map<String, dynamic> _userCache;
  bool isLoaded = false;

  _ProfileState(this._sessionID);

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
      body: Center(
        child:
            isLoaded ? ProfileDisplay(_userCache) : CircularProgressIndicator(),
      ),
    );
  }

  Future<void> loadUser() async {
    final response = await http
        .get("http://localhost:8081/profile", headers: {"Session": _sessionID});
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
    return Card(
      child: Column(
        children: <Widget>[
          Text("Name: ${profileData.username}"),
          Text("Email: ${profileData.email}"),
          Text("lastClaim: ${profileData.lastClaimTime}"),
        ],
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
