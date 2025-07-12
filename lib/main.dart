import 'dart:async';
import 'package:flutter/material.dart';
import 'services.dart';
import 'syno_bt.dart';
import 'bt_item.dart';
import 'task_screen.dart';
import 'settings_screen.dart';

void main() => runApp(
      MyApp(),
    );

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AutomaticKeepAliveClientMixin {
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
      sid = await fetchAuth();
      setState(() {});
    }
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

    if (searchController.text.length == 0) return;

    setState(() {
      searchInProgress = true;
    });

    taskid = await doSearch(searchController.text);
    if (taskid.isNotEmpty) {
      getData(taskid);
      timer =
          Timer.periodic(Duration(seconds: 15), (Timer t) => getData(taskid));
    } else
      print('taskid null');
  }

  void stopSearch() {
    timer?.cancel();
    setState(() {
      searchInProgress = false;
    });
    FocusScope.of(context).requestFocus(searchFocusNode);
  }

  Widget progressIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Loading...",
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                )),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: LinearProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation(Theme.of(context).colorScheme.secondary),
          ),
        ),
      ],
    );
  }

  Widget searchField() {
    return TextFormField(
      cursorColor: Colors.white,
      cursorWidth: 3.0,
      controller: searchController,
      focusNode: searchFocusNode,
      enabled: !searchInProgress,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 24.0, color: Theme.of(context).colorScheme.onPrimary),
      decoration: new InputDecoration(
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          contentPadding:
              EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
          labelText: "Enter search term",
          labelStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20.0, color: Theme.of(context).colorScheme.onPrimary)),
    );
  }

  Widget listItemBT(int index) {
    if (index >= searchResults.data.items.length) return Container();

    Item sbt = searchResults.data.items[index];

    return Container(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
            child: BTItem(
                key: Key("btitem"),
                notifyParent: refresh,
                index: index,
                picked: sbt.picked,
                title: sbt.title,
                link: sbt.downloadUri,
                peers: sbt.peers,
                seeds: sbt.seeds)));
  }

  refresh(BuildContext context, int index) {
    searchResults.data.items[index].picked = true;
    createDownload(searchResults.data.items[index].downloadUri);
    setState(() {});
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskScreen(notifyParent: deleted)),
    );
  }

  deleted(String id) {}

  void showSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
    await loadSID();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Download',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          hintColor: Colors.amber,
          fontFamily: 'Roboto',
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          textTheme: TextTheme(
            headlineLarge:
                TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 28.0, fontStyle: FontStyle.italic),
            bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
        ),
        home: Builder(
            builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text('Download Search'),
                  actions: <Widget>[
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
                      ? SliverList(delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                          return listItemBT(index);
                        },
                        childCount: searchResults.data.items.length))
                      : searchInProgress
                          ? SliverFillRemaining(child: progressIndicator())
                          : SliverFillRemaining(
                              child: sid.isNotEmpty
                                  ? Container(
                                      alignment: Alignment(0.0, 0.0),
                                      child: Text('No downloads',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge
                                              ?.copyWith(
                                                fontSize: 24.0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              )))
                                  : startingUp
                                      ? Container(
                                          alignment: Alignment(0.0, 0.0),
                                          child: Text('Connecting...',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge
                                                  ?.copyWith(
                                                    fontSize: 24.0,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  )))
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
                                                    .headlineLarge
                                                    ?.copyWith(
                                                      fontSize: 24.0,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                    ))
                                          ],
                                        ))
                ]),
                floatingActionButton: sid.isEmpty
                    ? Container()
                    : !searchInProgress
                        ? FloatingActionButton(
                            onPressed: runSearch,
                            tooltip: 'Search',
                            child: new Icon(Icons.search))
                        : FloatingActionButton(
                            onPressed: stopSearch,
                            tooltip: 'Cancel',
                            child: new Icon(Icons.cancel)))));
  }
}
