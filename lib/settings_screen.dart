import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;
  bool _obscureText = true;

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
    usernameController.text = prefs.getString('username') ?? "";
    passwordController.text = prefs.getString('password') ?? "";
    serverController.text = prefs.getString('server') ?? "192.168.0.5";
    portController.text = prefs.getString('port') ?? "5000";
    destinationController.text = prefs.getString('destination') ?? "video";
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
                              decoration: InputDecoration(
                                  hintText: 'user',
                                  labelText: 'Username',
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                      bottom: 10.0, left: 10.0, right: 10.0),
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              }),
                          TextFormField(
                              controller: passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                  hintText: 'password',
                                  labelText: 'Password',
                                  filled: true,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText ? Icons.visibility : Icons.visibility_off,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      bottom: 10.0, left: 10.0, right: 10.0),
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              }),
                          TextFormField(
                              controller: serverController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  hintText: 'server',
                                  labelText: 'Server',
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                      bottom: 10.0, left: 10.0, right: 10.0),
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              }),
                          TextFormField(
                              controller: portController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  hintText: 'port',
                                  labelText: 'Port',
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                      bottom: 10.0, left: 10.0, right: 10.0),
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              }),
                          TextFormField(
                              controller: destinationController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  hintText: 'destination',
                                  labelText: 'Destination',
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                      bottom: 10.0, left: 10.0, right: 10.0),
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              }),
                          Container(
                            width: width,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary, // background
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onPrimary, // foreground
                              ),
                              onPressed: () => saveGoBack(),
                              child: Text('Save'),
                            ),
                            margin: const EdgeInsets.all(20.0),
                          )
                        ],
                      ),
                    ))));
  }
}
