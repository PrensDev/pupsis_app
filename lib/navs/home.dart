import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Leave this app?"),
        content: Text("Are you sure you want to leave?"),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "No",
              style: TextStyle(
                color: Colors.grey[900],
              ),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: Text("Yes"),
            onPressed: () => SystemNavigator.pop(),
            color: Colors.red[900],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/pup-logo.png'),
                    radius: 50,
                  ),
                  margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: Text(
                  "Hi, PUPian!",
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: Text(
                  "Please click to your destination",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: 35),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    FlatButton(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Text(
                        "Student",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      color: Colors.blue[800],
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/student');
                      },
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    FlatButton(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Text(
                        "Faculty",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      color: Colors.red[800],
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/faculty');
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 75,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "By using this service, you understood and agree to the PUP Online Services Terms of Use and Privacy Statement",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
