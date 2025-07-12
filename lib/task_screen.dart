import 'package:flutter/material.dart';
import 'services.dart';
import 'syno_download_tasks.dart';
import 'dart:async';

class TaskScreen extends StatefulWidget {
  TaskScreen({Key? key, required this.notifyParent}) : super(key: key);

  final Function(String id) notifyParent;

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  SynoDownloadTasks searchResults = SynoDownloadTasks(data: Data(tasks: [], total: 0, offset: 0), success: false);
  bool searchInProgress = true;
  late String sid;
  Timer? t;

  @override
  void initState() {
    super.initState();
    loadSID();
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  void loadSID() async {
    sid = await fetchAuth();
    setState(() {});
    runSearch();
    Timer.periodic(const Duration(seconds: 10), (t) => runSearch());
  }

  void runSearch() async {
    if (!mounted) return;
    setState(() {
      searchInProgress = true;
    });

    searchResults = await getTasks();

    if (!mounted) return;
    setState(() {
      searchInProgress = false;
    });
  }

  void runDelete(int index, String id) async {
    await deleteDownload(id);
    setState(() {
      searchResults.data.tasks.removeAt(index);
    });
  }

  String fixString(String str) {
    int chunks = (str.length / 25).floor();
    String retStr = '';
    for (int i = 0; i < chunks; i++)
      retStr = retStr + str.substring(i * 25, (i + 1) * 25) + '\n';
    retStr = retStr + str.substring(chunks * 25);
    return retStr;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Downloads',
        home: Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context, false),
                ),
                title: Text('Downloads')),
            body: (searchResults.data.tasks.length > 0)
                ? Scrollbar(
                    child: ListView.builder(
                        itemCount: searchResults.data.tasks.length,
                        itemBuilder: (context, index) {
                          Task task = searchResults.data.tasks[index];
                          return Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  width: 1,
                                ),
                              ),
                              child: Container(
                                  height: 120,
                                  color: (task.status == 'finished' ||
                                          task.status == 'seeding')
                                      ? Theme.of(context).colorScheme.secondary
                                      : task.status == 'error'
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context).colorScheme.surface,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        highlightColor: Theme.of(context).colorScheme.secondary,
                                        onPressed: () {
                                          runDelete(index, task.id);
                                          widget.notifyParent(task.id);
                                        },
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Flexible(
                                              child: new Container(
                                                  padding: new EdgeInsets.only(
                                                      top: 20.0),
                                                  child: SingleChildScrollView(
                                                      child: Text(
                                                    fixString(task.title),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: null,
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      fontSize: 16.0,
                                                      color: Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                  )))),
                                          Text(
                                              task.status[0].toUpperCase() +
                                                  task.status.substring(1) +
                                                  ' (' +
                                                  (task.size / 1000000)
                                                      .toStringAsFixed(0) +
                                                  ' MB)',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ))
                                        ],
                                      ),
                                      SizedBox(width: 30),
                                      (task.status == 'finished' ||
                                              task.status == 'seeding' ||
                                              task.status == 'error' ||
                                              task.status == "paused")
                                          ? Container(child: Text(task.status))
                                          : SizedBox(
                                              height: 30,
                                              width: 30,
                                              child: Container(
                                                  color: Theme.of(context).colorScheme.tertiaryContainer,
                                                  child: Center(
                                                      child: Text(
                                                    task.downloaded.toString() +
                                                        "%",
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        color: Theme.of(context).colorScheme.onTertiaryContainer),
                                                  ))))
                                      //CircularProgressIndicator()
                                    ],
                                  )));
                        }))
                : Center(
                    child: Container(
                        alignment: Alignment(0.0, 0.0),
                        child: searchInProgress
                            ? SizedBox(
                                height: 200.0,
                                child: Stack(
                                  children: <Widget>[
                                    Center(
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        child: new CircularProgressIndicator(
                                            //strokeWidth: 15,
                                            //value: 1.0,
                                            ),
                                      ),
                                    ),
                                    Center(child: Text("Fetching")),
                                  ],
                                ),
                              )
                            : Text('No downloads',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontSize: 24.0,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ))))));
  }
}
