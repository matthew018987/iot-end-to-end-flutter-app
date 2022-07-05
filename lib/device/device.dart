import 'package:iot_app/device/aws.dart';
import 'package:iot_app/device/device_data.dart';



class DeviceInf {
  late CloudConnectivity cloud;
  DeviceCloudInf cc = DeviceCloudInf();

  Future<void> init(CloudConnectivity cloud) async {
    this.cloud = cloud;
    await cc.init(cloud);
    await cc.getValues();
  }

}