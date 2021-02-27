import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io';
import 'dart:async';

// Import Dependencies
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Student extends StatefulWidget {
  @override
  _StudentState createState() => _StudentState();
}

class _StudentState extends State<Student> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  num position = 1;

  final key = UniqueKey();

  _doneLoading() {
    setState(() {
      position = 0;
      print('[State 0]: Done loading');
    });
  }

  _startLoading() {
    setState(() {
      position = 1;
      print('[State 1]: Start Loading');
    });
  }

  _launchUrlOutside(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      print('Cannot launch $url');
    }
  }

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
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        drawer: infoDrawer(),
        appBar: appBar(),
        body: body(),
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        // ignore: deprecated_member_use
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      },
    );
  }

  Widget appBar() {
    return AppBar(
      leading: Builder(
        builder: (BuildContext context) {
          return new GestureDetector(
            onTap: () {},
            child: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              tooltip: "More",
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          );
        },
      ),
      title: const Text('Student Module'),
      actions: <Widget>[
        NavigationControls(_controller.future),
      ],
    );
  }

  Widget infoDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'POLYTECHNIC UNIVERSITY OF THE PHILIPPINES',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Times New Roman',
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: CircleAvatar(
                          backgroundImage: AssetImage('assets/pup-logo.png'),
                          radius: 15,
                        ),
                        margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      ),
                      Text(
                        'PUP-SIS Student Module',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.red[900],
            ),
          ),
          ListTile(
            title: Text('Back to main page'),
            onTap: () {
              // Pop the drawer
              Navigator.pop(context);
              // Pop the current route and go to home page
              Navigator.popAndPushNamed(context, '/');
            },
          ),
          ListTile(
            title: Text('Terms of Use'),
            onTap: () => _launchUrlOutside('https://www.pup.edu.ph/terms'),
          ),
          ListTile(
            title: Text('Privacy Statement'),
            onTap: () => _launchUrlOutside('https://www.pup.edu.ph/privacy'),
          ),
        ],
      ),
    );
  }

  Widget body() {
    return Builder(
      builder: (BuildContext context) {
        return IndexedStack(
          index: position,
          children: <Widget>[
            WebView(
              initialUrl: 'https://sis8.pup.edu.ph/student/',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              // ignore: prefer_collection_literals
              javascriptChannels: <JavascriptChannel>[
                _toasterJavascriptChannel(context),
              ].toSet(),
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith('https://www.pup.edu.ph/')) {
                  _launchUrlOutside(request.url);
                  return null;
                } else if (request.url.startsWith('https://sis1.pup.edu.ph/') ||
                    request.url.startsWith('https://sis2.pup.edu.ph/') ||
                    request.url.startsWith('https://sis8.pup.edu.ph/')) {
                  return NavigationDecision.navigate;
                } else {
                  return NavigationDecision.prevent;
                }
              },
              key: key,
              onPageStarted: (String url) {
                _startLoading();
              },
              onPageFinished: (String url) {
                _doneLoading();
              },
              gestureNavigationEnabled: true,
            ),
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'Loading...',
                          style: TextStyle(fontSize: 15),
                        )),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_left),
              tooltip: 'Back',
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoBack()) {
                        await controller.goBack();
                      } else {
                        Scaffold.of(context).removeCurrentSnackBar();
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No back history."),
                          ),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_right),
              tooltip: 'Forward',
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoForward()) {
                        await controller.goForward();
                      } else {
                        Scaffold.of(context).removeCurrentSnackBar();
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No forward history."),
                          ),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller.reload();
                      Scaffold.of(context).removeCurrentSnackBar();
                      Scaffold.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("The page has been reloaded."),
                        ),
                      );
                    },
            ),
          ],
        );
      },
    );
  }
}
