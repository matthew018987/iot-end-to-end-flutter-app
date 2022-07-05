import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:iot_app/device/aws.dart';


class DeviceCloudInf {
  late CloudConnectivity cloud;
  String deviceID = '';

  Future<void> init(CloudConnectivity cloud) async {
    this.cloud = cloud;
  }

  Future<void> getValues() async {
    bool authenticated = cloud.checkAuthenticatedSync();
    // authenticated can be false when user credentials are correct but token has expired
    // the following will try to refresh the token and updated authenticated state
    if (!authenticated) {
      await cloud.getCredentials();
      authenticated = cloud.checkAuthenticatedSync();
    }

    if (authenticated) {
      try {
        await Future.wait(
          [
            getDeviceId(),
            getSensorData(),
            getTwoWeekPoints(),
          ]
        );
      } catch (e) {
        //print(e.toString());
      }
    }
    return;
  }

  Future getDeviceId() async {
    const String query = '''
      query getUserDevices {
        getUserDevices {
          deviceID
          userID
        }
      }
      ''';

    String response = await cloud.query(query);
    await parseUserDeviceResponse(response);
  }

  Future setDeleteDevice(String deviceID) async {
    const String query = '''mutation deleteUserDevice {
      deleteUserDevice {
        deviceID
      }
    }''';

    await cloud.query(query);
  }

  Future getTwoWeekPoints() async {
    const String query = '''query getTwoWeekSummary {
      getTwoWeekSummary {
        items {
          temp
          hum
          timestamp
        }
      }
    }''';

    String response = await cloud.query(query);

    await parseTwoWeekSummary(response);
  }

  Future getSensorData() async {
    const String query = '''query data {
      getSensorData {
        items {
          temp
          hum
          timestamp
        }
      }
    }''';

    String response = await cloud.query(query);
    await parseSensorData(response);
  }

  // server response strings to device data structures
  parseUserDeviceResponse(String respBody) async {
    String deviceId = '';
    final resp = jsonDecode(respBody);
    if (resp["data"]['getUserDevices'].length > 0) {
      String deviceId = resp["data"]['getUserDevices']['deviceID'];
      if (kDebugMode) {
        print('deviceID:$deviceId');
      }
    }
    return deviceId;
  }

  parseSensorData(String respBody) async {
    final resp = jsonDecode(respBody);
    if (resp["data"]["getSensorData"] != null) {
      var sensorItemList = resp["data"]["getSensorData"];
      if (sensorItemList['items'].length > 0) {
        for (int i = 0; i < resp["data"]["getSensorData"]["items"].length; i++) {
          var dataPoint = resp["data"]["getSensorData"]["items"][i];
          try {
            double temp = 0;
            if (dataPoint.containsKey("temp")) {
              temp = dataPoint["temp"].toDouble();
            }
            double humidity = 0;
            if (dataPoint.containsKey("hum")) {
              humidity = dataPoint["hum"].toDouble();
            }
            int timestamp = 0;
            if (dataPoint.containsKey("timestamp")) {
              timestamp = dataPoint["timestamp"] * 1000;
            }

            DateTime eventTime = DateTime.fromMillisecondsSinceEpoch(
                timestamp, isUtc: true);

            if (kDebugMode) {
              print('data point: $eventTime $temp C, $humidity %RH');
            }

            // TODO store results
          } catch (e) {
            //print(e);
          }


        }
      }
    }

  }

  parseTwoWeekSummary(String respBody) {
    final resp = jsonDecode(respBody);
    if (resp["data"]['getTwoWeekSummary']['items'].length > 0) {
      if (resp["data"]["getTwoWeekSummary"]["items"][0] != null) {
        for (int i = 0; i < resp["data"]["getTwoWeekSummary"]["items"].length; i++) {
          var dataPoint = resp["data"]["getTwoWeekSummary"]["items"][i];
          try {
            double temp = 0;
            if (dataPoint.containsKey("temp")) {
              temp = dataPoint["temp"].toDouble();
            }
            double humidity = 0;
            if (dataPoint.containsKey("hum")) {
              humidity = dataPoint["hum"].toDouble();
            }
            int timestamp = 0;
            if (dataPoint.containsKey("timestamp")) {
              timestamp = dataPoint["timestamp"] * 1000;
            }

            DateTime eventTime = DateTime.fromMillisecondsSinceEpoch(
                timestamp, isUtc: true);

            if (kDebugMode) {
              print('data point: $eventTime $temp C, $humidity %RH');
            }
            // TODO store results
          } catch (e) {
            //print(e);
          }

        }
      }
    }
  }

}
