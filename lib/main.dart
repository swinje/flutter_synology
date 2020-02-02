import 'dart:async';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'services.dart';
import 'syno_bt.dart';
import 'bt_item.dart';
import 'task_screen.dart';
import 'settings_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  SynoBt searchResults;
  Timer timer;
  String taskid;
  bool searchInProgress = false;
  final searchController = TextEditingController();
  String sid;
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
    if (searchResults.data.finished || searchResults.data.items.length >= 25) {
      timer?.cancel();
      searchInProgress = false;
    }
  }

  void runSearch() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (searchController.text.length == 0) return;

    setState(() {
      searchInProgress = true;
    });

    taskid = await doSearch(searchController.text);
    if (taskid != null) {
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
  }

  Widget progressIndicator() {
    return LiquidLinearProgressIndicator(
      value: 0.5,
      valueColor: AlwaysStoppedAnimation(Colors.pink),
      backgroundColor: Colors.white,
      borderColor: Colors.white,
      borderWidth: 0.0,
      borderRadius: 0.0,
      direction: Axis.horizontal,
      center: Text("Loading...",
          style: const TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          )),
    );
  }

  Widget searchField() {
    return TextFormField(
      cursorColor: Colors.blue,
      controller: searchController,
      style: TextStyle(fontSize: 24.0, color: Colors.white),
      decoration: new InputDecoration(
          fillColor: Colors.pink,
          filled: true,
          contentPadding:
              EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
          labelText: "Enter search term",
          labelStyle: TextStyle(color: Colors.white, fontSize: 20.0)),
    );
  }

  Widget listItemBT(int index) {
    if (index >= searchResults.data.items.length) return null;

    Item sbt = searchResults.data.items[index];

    return Container(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: BTItem(
            notifyParent: refresh,
            index: index,
            picked: sbt.picked,
            title: sbt.title,
            link: sbt.downloadUri,
            peers: sbt.peers,
            seeds: sbt.seeds));
  }

  refresh(int index) {
    searchResults.data.items[index].picked = true;
    createDownload(searchResults.data.items[index].downloadUri);
    setState(() {});
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
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Download',
        theme: ThemeData(
          primarySwatch: Colors.blue,
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
                      child: sid != null ? searchField() : Container()),
                  (searchResults != null && searchResults.data.items.length > 0)
                      ? SliverList(delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                          return listItemBT(index);
                        }))
                      : searchInProgress
                          ? SliverFillRemaining(child: progressIndicator())
                          : SliverFillRemaining(
                              child: sid != null
                                  ? Container(
                                      alignment: Alignment(0.0, 0.0),
                                      child: Text('No downloads',
                                          style: const TextStyle(
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          )))
                                  : startingUp
                                      ? Container(
                                          alignment: Alignment(0.0, 0.0),
                                          child: Text('Connecting...',
                                          style: const TextStyle(
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          )))
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.warning,
                                                size: 100.0, color: Colors.red),
                                            Text('Check settings',
                                                style: const TextStyle(
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ))
                                          ],
                                        ))
                ]),
                floatingActionButton: sid == null
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
