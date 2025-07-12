import 'dart:convert';
import 'package:download/syno_download_tasks.dart';
import 'package:http/http.dart' as http;
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
late SharedPreferences prefs;
late String username, password, server, port, destination, ver;
late bool twoFactorEnabled;

Uri makeURL(int type, {String? otpCode}) {
  switch (type) {
    case SID_URL:
      String url = 'http://' +
          server +
          ':' +
          port +
          '/webapi/auth.cgi?api=SYNO.API.Auth&version=' +
          ver +
          '&method=login&account=' +
          username +
          '&passwd=' +
          password +
          '&session=DownloadStation&format=cookie';
      if (otpCode != null && otpCode.isNotEmpty) {
        url += '&otp_code=' + otpCode;
      }
      return Uri.parse(url);
    case AUTH_URL:
      return Uri.parse('http://' +
          server +
          ':' +
          port +
          '/webapi/query.cgi?api=SYNO.API.Info&version=1&' +
          'method=query&query=SYNO.API.Auth,SYNO.DownloadStation.Task');
    case SEARCH_URL:
      return Uri.parse('http://' +
          server +
          ':' +
          port +
          '/webapi/' +
          'DownloadStation/btsearch.cgi?api=SYNO.DownloadStation' +
          '.BTSearch&version=1&method=start&module=enabled&keyword=');
    case RESULT_URL:
      return Uri.parse('http://' +
          server +
          ':' +
          port +
          '/webapi/' +
          'DownloadStation/btsearch.cgi?api=SYNO.DownloadStation.' +
          'BTSearch&version=1&method=list&offset=0&limit=25&sort_by=seeds' +
          '&filter_category=&filter_title=&sort_direction=DESC&taskid=');
    case TASKS_URL:
      return Uri.parse('http://' +
          server +
          ':' +
          port +
          '/webapi/' +
          'DownloadStation/task.cgi?api=SYNO.DownloadStation.' +
          'Task&version=1&method=list&additional=file');
    case CREATE_DOWNLOAD:
      return Uri.parse('http://' +
          server +
          ':' +
          port +
          '/webapi/' +
          'DownloadStation/task.cgi?api=SYNO.DownloadStation.' +
          'Task&version=1&method=create&destination=' +
          destination +
          '&uri=');
    case DELETE_DOWNLOAD:
      return Uri.parse('http://' +
          server +
          ':' +
          port +
          '/webapi/' +
          'DownloadStation/task.cgi?api=SYNO.DownloadStation.' +
          'Task&version=1&method=delete&id=');
  }
  return Uri.parse("");
}

void updateCookie(http.Response response) {
  String rawCookie = response.headers['set-cookie'] ?? "";
  if (rawCookie.isNotEmpty) {
    int index = rawCookie.indexOf(';');
    headers['cookie'] =
        (index == -1) ? rawCookie : rawCookie.substring(0, index);
  }
}

Future<bool> loadPreferences() async {
  prefs = await SharedPreferences.getInstance();
  username = prefs.getString('username') ?? "";
  password = prefs.getString('password') ?? "";
  server = prefs.getString('server') ?? "";
  port = prefs.getString('port') ?? "";
  destination = prefs.getString('destination') ?? "";
  twoFactorEnabled = prefs.getBool('twoFactor') ?? false;
  if (username.isEmpty || password.isEmpty || server.isEmpty || port.isEmpty)
    return false;
  return true;
}

Future<String> fetchSID({String? otpCode}) async {
  final response =
      await http.get(makeURL(SID_URL, otpCode: otpCode), headers: headers);
  updateCookie(response);

  if (response.statusCode == 200) {
    if (response.body.contains('error')) {
      SynoError sError = SynoError.fromJson(json.decode(response.body));
      print('Error fetchSID ${sError.error.code}');
      return ''; // Return empty string instead of null
    }
    return SynoDownload.fromJson(json.decode(response.body)).data.sid;
  } else {
    throw Exception('Failed to load sid');
  }
}

Future<String> fetchAuth({String? otpCode}) async {
  http.Response response;
  try {
    response = await http.get(makeURL(AUTH_URL), headers: headers);
  } catch (e) {
    return ''; // Return empty string instead of null
  }
  updateCookie(response);

  if (response.statusCode == 200) {
    final authData = SynoAuth.fromJson(json.decode(response.body)).data;
    if (authData == null) {
      print('Error: authData is null');
      return '';
    }
    final Syno? downloadStationTask = authData.synoDownloadStationTask;
    if (downloadStationTask != null) {
      ver = downloadStationTask.maxVersion.toString();
    } else {
      print('Warning: synoDownloadStationTask is null');
      ver = '1';
    }
    String sid;
    if (otpCode != null && otpCode.isNotEmpty) {
      sid = await fetchSID(otpCode: otpCode);
    } else {
      sid = await fetchSID();
    }

    return sid;
  } else {
    throw Exception('Failed to load auth ${response.body}');
  }
}

Future<String> doSearch(String searchTerm) async {
  Uri searchString =
      Uri.parse(makeURL(SEARCH_URL).toString() + Uri.encodeFull(searchTerm));

  final response = await http.get(searchString, headers: headers);
  updateCookie(response);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (jsonResponse.containsKey('error')) {
      String err = SynoError.fromJson(jsonResponse).error.code.toString();
      print('Error search $err');
      return "";
    }
    String taskid = SynoTask.fromJson(json.decode(response.body)).data.taskid;
    return taskid;
  } else {
    throw Exception('Failed to load task');
  }
}

Future<SynoBt> getResults(String taskid) async {
  final response = await http.get(
      Uri.parse(makeURL(RESULT_URL).toString() + taskid),
      headers: headers);
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

Future<Map<String, dynamic>> createDownload(String uri) async {
  final response = await http.get(
      Uri.parse(makeURL(CREATE_DOWNLOAD).toString() + uri),
      headers: headers);
  updateCookie(response);

  Map<String, dynamic> decodedBody = json.decode(response.body);
  return {
    'code': decodedBody['error']?['code'],
    'success': decodedBody['success'],
  };
}

Future<void> deleteDownload(String id) async {
  final response = await http.get(
      Uri.parse(makeURL(DELETE_DOWNLOAD).toString() + id),
      headers: headers);
  updateCookie(response);
}
