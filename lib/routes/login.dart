import 'package:flutter_web/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ctl_client/routes/profile.dart';

class LoginWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginWidgetState();
  }
}

class LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();

  final emailFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();

  String _sessionID;
  bool isLoading = false;
  bool hasTried = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        color: Colors.lightGreenAccent,
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : SizedBox(
                  height: 500,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                "Authenticate",
                                style: TextStyle(
                                  fontSize: 30,
                                ),
                              ),
                            ),
                            LoginField(
                              "Email",
                              Icons.email,
                              (value) {
                                if (value.isEmpty) {
                                  return "Please enter an email";
                                }
                                return null;
                              },
                              emailFieldController,
                            ),
                            LoginField(
                              "Password",
                              Icons.security,
                              (value) {
                                if (value.isEmpty) {
                                  return "Please enter a password";
                                }
                                return null;
                              },
                              passwordFieldController,
                              isPassword: true,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: RaisedButton(
                                color: Colors.lightBlueAccent,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    login(emailFieldController.text,
                                        passwordFieldController.text);
                                    setState(() => isLoading = true);
                                  }
                                },
                                child: Text("Login"),
                              ),
                            ),
                            hasTried == true && _sessionID == null
                                ? Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text(
                                      "Incorrect details",
                                      style: TextStyle(color: Colors.red),
                                    ))
                                : null
                          ].where((widget) => widget != null).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      'http://localhost:8081/login',
      body: json.encode({"email": email, "password": password}),
    );
    setState(() {
      _sessionID = json.decode(response.body)["session_id"];
      isLoading = false;
      hasTried = true;

      if (_sessionID != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profile(_sessionID)),
        );
      }
    });
  }
}

class LoginField extends StatelessWidget {
  final _labelText;
  final IconData _iconData;
  final bool isPassword;
  final _validator;
  final _controller;

  const LoginField(
      this._labelText, this._iconData, this._validator, this._controller,
      {this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: _controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: _labelText,
          icon: Icon(_iconData),
        ),
        validator: _validator,
      ),
    );
  }
}
