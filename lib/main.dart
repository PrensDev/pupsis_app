import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

// Import Dependencies
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(
      MaterialApp(
        home: WebViewExample(),
        debugShowCheckedModeBanner: false,
        title: 'PUP-SIS Student Module',
        color: Colors.red[800],
      ),
    );

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  num position = 1;

  final key = UniqueKey();

  _doneLoading() {
    setState(() {
      position = 0;
    });
  }

  _startLoading() {
    setState(() {
      position = 1;
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
        title: Text("Are you sure you want to leave?"),
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
            onPressed: () => Navigator.pop(context, true),
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
        floatingActionButton: favoriteButton(),
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

  Widget favoriteButton() {
    return FutureBuilder<WebViewController>(
      future: _controller.future,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return FloatingActionButton(
            onPressed: () async {
              final String url = await controller.data.currentUrl();
              Scaffold.of(context).removeCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(content: Text('Current url: $url')),
              );
            },
            child: Icon(Icons.link),
          );
        }
        return Container();
      },
    );
  }

  Widget appBar() {
    return AppBar(
      backgroundColor: Colors.red[900],
      leading: Builder(
        builder: (BuildContext context) {
          return new GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: IconButton(
              icon: Icon(
                Icons.info_rounded,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
      title: const Text('PUP-SIS'),
      actions: <Widget>[
        NavigationControls(_controller.future),
        SampleMenu(_controller.future),
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
                        'PUP-SIS',
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
                } else {
                  return NavigationDecision.navigate;
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
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller);

  final Future<WebViewController> controller;
  final CookieManager cookieManager = CookieManager();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        return PopupMenuButton<MenuOptions>(
          onSelected: (MenuOptions value) {
            switch (value) {
              case MenuOptions.showUserAgent:
                _onShowUserAgent(controller.data, context);
                break;
              case MenuOptions.listCookies:
                _onListCookies(controller.data, context);
                break;
              case MenuOptions.clearCookies:
                _onClearCookies(context);
                break;
              case MenuOptions.addToCache:
                _onAddToCache(controller.data, context);
                break;
              case MenuOptions.listCache:
                _onListCache(controller.data, context);
                break;
              case MenuOptions.clearCache:
                _onClearCache(controller.data, context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
            PopupMenuItem<MenuOptions>(
              value: MenuOptions.showUserAgent,
              child: const Text('Show user agent'),
              enabled: controller.hasData,
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCookies,
              child: Text('List cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCookies,
              child: Text('Clear cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.addToCache,
              child: Text('Add to cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCache,
              child: Text('List cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCache,
              child: Text('Clear cache'),
            ),
          ],
        );
      },
    );
  }

  void _onShowUserAgent(
      WebViewController controller, BuildContext context) async {
    // Send a message with the user agent string to the Toaster JavaScript channel we registered
    // with the WebView.
    await controller.evaluateJavascript(
        'Toaster.postMessage("User Agent: " + navigator.userAgent);');
  }

  void _onListCookies(
      WebViewController controller, BuildContext context) async {
    final String cookies =
        await controller.evaluateJavascript('document.cookie');
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Cookies:'),
          _getCookieList(cookies),
        ],
      ),
    ));
  }

  void _onAddToCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript(
        'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  void _onListCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript('caches.keys()'
        '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
        '.then((caches) => Toaster.postMessage(caches))');
  }

  void _onClearCache(WebViewController controller, BuildContext context) async {
    await controller.clearCache();
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text("Cache cleared."),
    ));
  }

  void _onClearCookies(BuildContext context) async {
    final bool hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies.';
    }
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Widget _getCookieList(String cookies) {
    if (cookies == null || cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets =
        cookieList.map((String cookie) => Text(cookie));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
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
