import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  SharedPreferences prefs;

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController serverController = TextEditingController();
  TextEditingController portController = TextEditingController(text: '5000');
  TextEditingController destinationController =
      TextEditingController(text: 'video');

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  void loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    usernameController.text = prefs.getString('username');
    passwordController.text = prefs.getString('password');
    serverController.text = prefs.getString('server');
    portController.text = prefs.getString('port');
    destinationController.text = prefs.getString('destination');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void saveGoBack() async {
    await prefs.setString('username', usernameController.text.trim());
    await prefs.setString('password', passwordController.text.trim());
    await prefs.setString('server', serverController.text.trim());
    await prefs.setString('port', portController.text.trim());
    await prefs.setString('destination', destinationController.text.trim());
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Settings',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context, false),
                ),
                title: Text('Settings')),
            body: Builder(
                builder: (context) => Form(
                      key: _formKey,
                      child: ListView(
                        children: <Widget>[
                          SizedBox(height: 50),
                          TextFormField(
                              controller: usernameController,
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                  hintText: 'user',
                                  labelText: 'Username',
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                      bottom: 10.0, left: 10.0, right: 10.0),
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 20.0)),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              }),
                          TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: new InputDecoration(
                                  hintText: 'password',
                                  labelText: 'Password',
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                      bottom: 10.0, left: 10.0, right: 10.0),
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 20.0)),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              }),
                          TextFormField(
                              controller: serverController,
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                  hintText: 'server',
                                  labelText: 'Server',
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                      bottom: 10.0, left: 10.0, right: 10.0),
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 20.0)),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              }),
                          TextFormField(
                              controller: portController,
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                  hintText: 'port',
                                  labelText: 'Port',
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                      bottom: 10.0, left: 10.0, right: 10.0),
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 20.0)),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              }),
                          TextFormField(
                              controller: destinationController,
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                  hintText: 'destination',
                                  labelText: 'Destination',
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                      bottom: 10.0, left: 10.0, right: 10.0),
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 20.0)),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              }),
                          Container(
                            width: width,
                            child: new RaisedButton(
                              child: new Text(
                                'Save',
                                style: new TextStyle(color: Colors.white),
                              ),
                              onPressed: () => saveGoBack(),
                              color: Colors.blue,
                            ),
                            margin: new EdgeInsets.all(20.0),
                          )
                        ],
                      ),
                    ))));
  }
}
