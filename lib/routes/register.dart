import 'package:flutter_web/material.dart';
import 'package:ctl_client/routes/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterWidgetState();
  }
}

class RegisterWidgetState extends State<RegisterWidget> {
  final _formKey = GlobalKey<FormState>();

  final emailFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();
  final usernameFieldController = TextEditingController();

  String _email;
  bool isLoading = false;
  bool hasTried = false;
  bool registered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        color: Colors.lightGreenAccent,
        child: registered
            ? RegisterSuccess()
            : Center(
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0),
                                    child: Text(
                                      "Register",
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
                                    "Username",
                                    Icons.person,
                                    (value) {
                                      if (value.isEmpty) {
                                        return "Please enter a username";
                                      }
                                      return null;
                                    },
                                    usernameFieldController,
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
                                          register(
                                              emailFieldController.text,
                                              usernameFieldController.text,
                                              passwordFieldController.text);
                                          setState(() => isLoading = true);
                                        }
                                      },
                                      child: Text("Register"),
                                    ),
                                  ),
                                  hasTried == true && _email == null
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 15.0),
                                          child: Text(
                                            "Username and/or email already registered.",
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

  Future<void> register(String email, String username, String password) async {
    final response = await http.post(
      'http://localhost:8081/register',
      body: json
          .encode({"email": email.toLowerCase(), "username": username, "password": password}),
    );
    setState(() {
      _email = json.decode(response.body)["email"];
      isLoading = false;
      hasTried = true;

      if (_email != null) {
        registered = true;
      }
    });
  }
}

class RegisterSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: <Widget>[
              Text("Successfully registered. Please click "),
              InkWell(
                child: Text(
                  "here",
                  style: TextStyle(
                    color: Colors.lightBlue,
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginWidget(),
                    ),
                  );
                },
              ),
              Text(" to login.")
            ],
          ),
        ),
      ),
    );
  }
}
