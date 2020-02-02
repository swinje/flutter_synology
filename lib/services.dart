import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:synoapp/syno_download_tasks.dart';
import 'syno_auth.dart';
import 'syno_download.dart';
import 'syno_taskid.dart';
import 'syno_error.dart';
import 'syno_bt.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int SID_URL = 0;
const int AUTH_URL = 1;
const int SEARCH_URL = 2;
const int RESULT_URL = 3;
const int TASKS_URL = 4;
const int CREATE_DOWNLOAD = 5;
const int DELETE_DOWNLOAD = 6;

Map<String, String> headers = {};
SharedPreferences prefs;
String username, password, server, port, destination, ver;

String makeURL(int type) {
  switch (type) {
    case SID_URL:
      return ('http://' +
          server +
          ':' +
          port +
          '/webapi/auth.cgi?api=SYNO.API.Auth&version=' +
          ver +
          '&method=login&account=' +
          username +
          '&passwd=' +
          password +
          '&session=DownloadStation&format=cookie');
    case AUTH_URL:
      return ('http://' +
          server +
          ':' +
          port +
          '/webapi/query.cgi?api=SYNO.API.Info&version=1&' +
          ''
              'method=query&query=SYNO.API.Auth,SYNO.DownloadStation.Task');
    case SEARCH_URL:
      return ('http://' +
          server +
          ':' +
          port +
          '/webapi/' +
          'DownloadStation/btsearch.cgi?api=SYNO.DownloadStation' +
          '.BTSearch&version=1&method=start&module=enabled&keyword=');
    case RESULT_URL:
      return ('http://' +
          server +
          ':' +
          port +
          '/webapi/' +
          'DownloadStation/btsearch.cgi?api=SYNO.DownloadStation.' +
          'BTSearch&version=1&method=list&offset=0&limit=25&sort_by=seeds' +
          '&filter_category=&filter_title=&sort_direction=DESC&taskid=');
    case TASKS_URL:
      return ('http://' +
          server +
          ':' +
          port +
          '/webapi/' +
          'DownloadStation/task.cgi?api=SYNO.DownloadStation.' +
          'Task&version=1&method=list');
    case CREATE_DOWNLOAD:
      return ('http://' +
          server +
          ':' +
          port +
          '/webapi/' +
          'DownloadStation/task.cgi?api=SYNO.DownloadStation.' +
          'Task&version=1&method=create&destination='+destination+'&uri=');
    case DELETE_DOWNLOAD:
      return ('http://' +
          server +
          ':' +
          port +
          '/webapi/' +
          'DownloadStation/task.cgi?api=SYNO.DownloadStation.' +
          'Task&version=1&method=delete&id=');
  }
}

void updateCookie(http.Response response) {
  String rawCookie = response.headers['set-cookie'];
  if (rawCookie != null) {
    int index = rawCookie.indexOf(';');
    headers['cookie'] =
        (index == -1) ? rawCookie : rawCookie.substring(0, index);
  }
}

Future<bool> loadPreferences() async {
  prefs = await SharedPreferences.getInstance();
  username = prefs.getString('username');
  password = prefs.getString('password');
  server = prefs.getString('server');
  port = prefs.getString('port');
  destination = prefs.getString('destination');
  if (username == null || password == null || server == null || port == null)
    return false;
  return true;
}

Future<String> fetchSID() async {
  final response = await http.get(makeURL(SID_URL), headers: headers);
  updateCookie(response);

  if (response.statusCode == 200) {
    if (response.body.contains('error')) {
      SynoError sError = SynoError.fromJson(json.decode(response.body));
      print('Error ${sError.error.code}');
      return null;
    }
    return SynoDownload.fromJson(json.decode(response.body)).data.sid;
  } else {
    throw Exception('Failed to load sid');
  }
}

Future<String> fetchAuth() async {
  var response;
  try {
    response = await http.get(makeURL(AUTH_URL), headers: headers);
  } catch(e) {
    return null;
  }
  updateCookie(response);

  if (response.statusCode == 200) {
    ver = SynoAuth.fromJson(json.decode(response.body))
        .data
        .synoDownloadStationTask
        .maxVersion
        .toString();
    String sid = await fetchSID();
    return sid;
  } else {
    throw Exception('Failed to load auth');
  }
}

Future<String> doSearch(String searchTerm) async {
  String searchString = makeURL(SEARCH_URL) + Uri.encodeFull(searchTerm);

  final response = await http.get(searchString, headers: headers);
  updateCookie(response);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (jsonResponse.containsKey('error')) {
      String err = SynoError.fromJson(jsonResponse).error.code.toString();
      print('Search error $err');
      return null;
    }
    String taskid = SynoTask.fromJson(json.decode(response.body)).data.taskid;
    return taskid;
  } else {
    throw Exception('Failed to load task');
  }
}

Future<SynoBt> getResults(String taskid) async {
  final response =
      await http.get(makeURL(RESULT_URL) + taskid, headers: headers);
  updateCookie(response);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    return SynoBt.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to load results');
  }
}

Future<SynoDownloadTasks> getTasks() async {
  final response = await http.get(makeURL(TASKS_URL), headers: headers);
  updateCookie(response);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    return SynoDownloadTasks.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to load downloads');
  }
}

Future<void> createDownload(String uri) async {
  final response =
      await http.get(makeURL(CREATE_DOWNLOAD) + uri, headers: headers);
  updateCookie(response);
}

Future<void> deleteDownload(String id) async {
  final response =
      await http.get(makeURL(DELETE_DOWNLOAD) + id, headers: headers);
  updateCookie(response);
}
