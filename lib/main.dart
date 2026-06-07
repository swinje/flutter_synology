import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'services.dart';
import 'syno_bt.dart';
import 'bt_item.dart';
import 'task_screen.dart';
import 'settings_screen.dart';

void main() {
  // Setup logging
  Logger.root.level = Level.ALL; // Log everything
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Download',
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.system,
    home: MyApp(),
  ));
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: brightness,
      secondary: Colors.amber,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        elevation: 2,
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  SynoBt searchResults = SynoBt(data: Data(items: []), success: false);
  Timer? timer;
  String taskid = "";
  bool searchInProgress = false;
  final searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  String sid = "";
  bool startingUp = true;

  @override
  void initState() {
    super.initState();
    loadSID();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> loadSID() async {
    bool infoSet = await loadPreferences();
    startingUp = false;
    if (infoSet) {
      String? otpCode;
      if (twoFactorEnabled) {
        otpCode = await requestOtpIfTwoFactorEnabled();
      }
      sid = await fetchAuth(otpCode: otpCode);
      setState(() {});
    }
  }

  Future<String?> requestOtpIfTwoFactorEnabled() async {
    if (twoFactorEnabled) {
      return await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: Text('Enter OTP Code'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'OTP Code',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
    return null;
  }

  void getData(String taskid) async {
    searchResults = await getResults(taskid);
    setState(() {});
    if ((searchResults.data.finished ?? false) ||
        searchResults.data.items.length >= 25) {
      timer?.cancel();
      searchInProgress = false;
    }
  }

  void runSearch() async {
    FocusScope.of(context).requestFocus(FocusNode());
    FocusScope.of(context).unfocus();

    if (searchController.text.isEmpty) return;

    setState(() {
      searchInProgress = true;
    });

    taskid = await doSearch(searchController.text);
    if (taskid.isNotEmpty) {
      getData(taskid);
      timer =
          Timer.periodic(Duration(seconds: 15), (Timer t) => getData(taskid));
    } else {
      setState(() {
        searchInProgress = false;
      });
    }
  }

  void stopSearch() {
    timer?.cancel();
    setState(() {
      searchInProgress = false;
    });
    FocusScope.of(context).requestFocus(searchFocusNode);
  }

  Widget progressIndicator() {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Loading...",
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
            )),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.0),
          child: LinearProgressIndicator(),
        ),
      ],
    );
  }

  Widget searchField() {
    final theme = Theme.of(context);
    return TextFormField(
      controller: searchController,
      focusNode: searchFocusNode,
      enabled: !searchInProgress,
      style: theme.textTheme.titleLarge,
      decoration: const InputDecoration(
          filled: true,
          labelText: "Enter search term",
          prefixIcon: Icon(Icons.search)),
    );
  }

  Widget listItemBT(int index) {
    if (index >= searchResults.data.items.length) return Container();

    Item sbt = searchResults.data.items[index];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: BTItem(
          key: Key("btitem_$index"),
          notifyParent: refresh,
          index: index,
          picked: sbt.picked,
          title: sbt.title,
          link: sbt.downloadUri,
          peers: sbt.peers,
          seeds: sbt.seeds),
    );
  }

  void refresh(BuildContext context, int index) {
    searchResults.data.items[index].picked = true;
    createDownloadTask(searchResults.data.items[index].downloadUri);
    setState(() {});
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TaskScreen(notifyParent: deleted)),
    );
  }

  void deleted(String id) {}

  void showSettings(BuildContext context) async {
    final bool? didPop = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
    if (didPop == false) {
      await loadSID();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Builder(
        builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Download Search'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add_link),
                  onPressed: () async {
                    final link = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        final controller = TextEditingController();
                        return AlertDialog(
                          title: Text('Add Download'),
                          content: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Enter link',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, controller.text),
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    if (link != null && link.isNotEmpty) {
                      final result = await createDownloadTask(link);
                      if (mounted && context.mounted) {
                        final bool success = result['success'] ?? false;
                        final message = success
                            ? 'Download created'
                            : 'Download failed with code: ${result['code']}';
                        final snackBar = SnackBar(content: Text(message));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    showSettings(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TaskScreen(notifyParent: deleted)),
                    );
                  },
                )
              ],
            ),
            body: CustomScrollView(slivers: <Widget>[
              SliverToBoxAdapter(
                  child: sid.isNotEmpty ? searchField() : Container()),
              (searchResults.data.items.isNotEmpty)
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                      return listItemBT(index);
                    }, childCount: searchResults.data.items.length))
                  : searchInProgress
                      ? SliverFillRemaining(child: progressIndicator())
                      : SliverFillRemaining(
                          child: sid.isNotEmpty
                              ? Container(
                                  alignment: Alignment(0.0, 0.0),
                                  child: Text('No downloads',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge))
                              : startingUp
                                  ? Container(
                                      alignment: Alignment(0.0, 0.0),
                                      child: Text('Connecting...',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge))
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.warning,
                                            size: 100.0,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error),
                                        Text('Check settings',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge)
                                      ],
                                    ))
            ]),
            floatingActionButton: sid.isEmpty
                ? Container()
                : !searchInProgress
                    ? FloatingActionButton(
                        onPressed: runSearch,
                        tooltip: 'Search',
                        child: Icon(Icons.search))
                    : FloatingActionButton(
                        onPressed: stopSearch,
                        tooltip: 'Cancel',
                        child: Icon(Icons.cancel))));
  }
}
