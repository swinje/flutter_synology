import 'dart:convert';
import 'package:download/syno_download_tasks.dart';
import 'package:http/http.dart' as http;
import 'syno_auth.dart';
import 'syno_download.dart';
import 'syno_taskid.dart';
import 'syno_error.dart';
import 'syno_bt.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int sidUrl = 0;
const int authUrl = 1;
const int searchUrl = 2;
const int resultUrl = 3;
const int tasksUrl = 4;
const int createDownload = 5;
const int deleteDownload = 6;

Map<String, String> headers = {};
late SharedPreferences prefs;
late String username, password, server, port, destination, ver;
late bool twoFactorEnabled;

Uri makeURL(int type, {String? otpCode}) {
  switch (type) {
    case sidUrl:
      String url =
          'http://$server:$port/webapi/auth.cgi?api=SYNO.API.Auth&version=$ver&method=login&account=$username&passwd=$password&session=DownloadStation&format=cookie';
      if (otpCode != null && otpCode.isNotEmpty) {
        url += '&otp_code=$otpCode';
      }
      return Uri.parse(url);
    case authUrl:
      return Uri.parse(
          'http://$server:$port/webapi/query.cgi?api=SYNO.API.Info&version=1&method=query&query=SYNO.API.Auth,SYNO.DownloadStation.Task');
    case searchUrl:
      return Uri.parse(
          'http://$server:$port/webapi/DownloadStation/btsearch.cgi?api=SYNO.DownloadStation.BTSearch&version=1&method=start&module=enabled&keyword=');
    case resultUrl:
      return Uri.parse(
          'http://$server:$port/webapi/DownloadStation/btsearch.cgi?api=SYNO.DownloadStation.BTSearch&version=1&method=list&offset=0&limit=25&sort_by=seeds&filter_category=&filter_title=&sort_direction=DESC&taskid=');
    case tasksUrl:
      return Uri.parse(
          'http://$server:$port/webapi/DownloadStation/task.cgi?api=SYNO.DownloadStation.Task&version=1&method=list&additional=file');
    case createDownload:
      return Uri.parse(
          'http://$server:$port/webapi/DownloadStation/task.cgi?api=SYNO.DownloadStation.Task&version=1&method=create&destination=$destination&uri=');
    case deleteDownload:
      return Uri.parse(
          'http://$server:$port/webapi/DownloadStation/task.cgi?api=SYNO.DownloadStation.Task&version=1&method=delete&id=');
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
  if (username.isEmpty || password.isEmpty || server.isEmpty || port.isEmpty) {
    return false;
  }
  return true;
}

Future<String> fetchSID({String? otpCode}) async {
  final response =
      await http.get(makeURL(sidUrl, otpCode: otpCode), headers: headers);
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
    response = await http.get(makeURL(authUrl), headers: headers);
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
      Uri.parse(makeURL(searchUrl).toString() + Uri.encodeFull(searchTerm));

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
  final response = await http
      .get(Uri.parse(makeURL(resultUrl).toString() + taskid), headers: headers);
  updateCookie(response);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    return SynoBt.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to load results');
  }
}

Future<SynoDownloadTasks> getDownloadTasks() async {
  final response = await http.get(makeURL(tasksUrl), headers: headers);
  updateCookie(response);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    return SynoDownloadTasks.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to load downloads');
  }
}

Future<Map<String, dynamic>> createDownloadTask(String uri) async {
  final response = await http.get(
      Uri.parse(makeURL(createDownload).toString() + uri),
      headers: headers);
  updateCookie(response);

  Map<String, dynamic> decodedBody = json.decode(response.body);
  return {
    'code': decodedBody['error']?['code'],
    'success': decodedBody['success'],
  };
}

Future<void> deleteDownloadTask(String id) async {
  final response = await http.get(
      Uri.parse(makeURL(deleteDownload).toString() + id),
      headers: headers);
  updateCookie(response);
}
