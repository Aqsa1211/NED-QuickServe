import 'package:app_settings/app_settings.dart';
import 'package:food/utils/constant.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as Location;

getCurrentLocation() async {
  bool serviceEnabled;
  Location.Location location = Location.Location();
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      getCurrentLocation();
      return;
    }
  }
  Location.PermissionStatus permissionStatus;
  permissionStatus = await location.hasPermission();
  if (permissionStatus == Location.PermissionStatus.denied) {
    permissionStatus = await location.requestPermission();
  }
  if (permissionStatus == Location.PermissionStatus.deniedForever) {
    AppSettings.openAppSettings(type: AppSettingsType.location);
  }

  Location.LocationData locationData = await location.getLocation();
  List<Placemark> placemark = await placemarkFromCoordinates(
      locationData.latitude!, locationData.longitude!);

  Constants.locationString =
  '${placemark.first.street} ${placemark.first.locality} ${placemark.first.country}';
  print('------${Constants.locationString}');
}