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

  bool _twoFactor = false;

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
    _twoFactor = prefs.getBool('twoFactor') ?? false;
    setState(() {});
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
    await prefs.setBool('twoFactor', _twoFactor);
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, true),
            ),
            title: Text('Settings')),
        body: Builder(
            builder: (context) => Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                            controller: usernameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                hintText: 'user',
                                labelText: 'Username',
                                filled: true,
                                contentPadding: EdgeInsets.only(
                                    top: 5.0,
                                    bottom: 12.0,
                                    left: 10.0,
                                    right: 10.0),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                                hintText: 'password',
                                labelText: 'Password',
                                filled: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                contentPadding: EdgeInsets.only(
                                    top: 5.0,
                                    bottom: 12.0,
                                    left: 10.0,
                                    right: 10.0),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                            controller: serverController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                hintText: 'server',
                                labelText: 'Server',
                                filled: true,
                                contentPadding: EdgeInsets.only(
                                    top: 5.0,
                                    bottom: 12.0,
                                    left: 10.0,
                                    right: 10.0),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                            controller: portController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                hintText: 'port',
                                labelText: 'Port',
                                filled: true,
                                contentPadding: EdgeInsets.only(
                                    top: 5.0,
                                    bottom: 12.0,
                                    left: 10.0,
                                    right: 10.0),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                            controller: destinationController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                hintText: 'destination',
                                labelText: 'Destination',
                                filled: true,
                                contentPadding: EdgeInsets.only(
                                    top: 5.0,
                                    bottom: 12.0,
                                    left: 10.0,
                                    right: 10.0),
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
                      ),
                      CheckboxListTile(
                        title: Text("2-factor"),
                        value: _twoFactor,
                        onChanged: (newValue) {
                          setState(() {
                            _twoFactor = newValue ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "If downloads do not start, you need to use an admin account. Enable 2-factor if required",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
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
                )));
  }
}
