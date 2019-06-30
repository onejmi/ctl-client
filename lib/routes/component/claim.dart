import 'package:ctl_client/routes/profile.dart';
import 'package:flutter_web/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClaimView extends StatelessWidget {
  final controller = TextEditingController();
  final String url = "http://localhost:8081/claim";

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.only(left: 16.0),
        child: Column(
          children: <Widget>[
            Claimer(controller: controller, url: url),
            ClaimViewer()
          ],
        ),
      ),
    );
  }
}

class Claimer extends StatelessWidget {
  Claimer({
    Key key,
    @required this.controller,
    @required this.url,
  }) : super(key: key);

  final TextEditingController controller;
  final String url;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.amberAccent,
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Claimer",
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 30,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: 450,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        icon: Icon(Icons.send),
                        labelText: "Claim",
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please provide a message.";
                        } else if (value.length > 25) {
                          return "Messages must be 25 characters or less.";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              RaisedButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Claim",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    final claimMessage = controller.text;
                    final sessionID = InheritedSession.of(context).sessionID;
                    http.post(url,
                        headers: {"Session": sessionID},
                        body: json.encode({"message": claimMessage}));
                    controller.text = "";
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClaimViewer extends StatefulWidget {
  static const url = "http://localhost:8081/latest";

  @override
  _ClaimViewerState createState() => _ClaimViewerState();
}

class _ClaimViewerState extends State<ClaimViewer> {
  Map<String, dynamic> jsonBulb;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => grabLatestClaim(context));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.greenAccent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                isLoading
                    ? CircularProgressIndicator()
                    : Expanded(
                        child: SizedBox(
                          height: 100.0,
                          child: RichText(
                            text: TextSpan(
                              text: "${jsonBulb['username']} said ",
                              style: TextStyle(
                                fontSize: 25,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "\"${jsonBulb['message']}\"",
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                RaisedButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.refresh),
                    ),
                    onPressed: () {
                      setState(() => isLoading = true);
                      grabLatestClaim(context);
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> grabLatestClaim(BuildContext context) async {
    final sessionID = InheritedSession.of(context).sessionID;
    final response =
        await http.get(ClaimViewer.url, headers: {"Session": sessionID});
    setState(() {
      jsonBulb = json.decode(response.body);
      isLoading = false;
    });
  }
}
