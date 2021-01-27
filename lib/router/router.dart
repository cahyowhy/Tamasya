import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:tamasya/screen/flight-offer-screen.dart';

import 'package:tamasya/screen/hotel-offer-screen.dart';
import 'package:tamasya/screen/tour-activitiy-screen.dart';

class Routers {
  static const initialRoute = FlightOfferScreen.RouteName;
  static List<GetPage> navigationPages = [
    GetPage(name: FlightOfferScreen.RouteName, page: () => FlightOfferScreen()),
    GetPage(name: HotelOfferScreen.RouteName, page: () => HotelOfferScreen()),
    GetPage(name: TourActivitiyScreen.RouteName, page: () => TourActivitiyScreen()),
  ];


  static List<GetPage> pages = [...navigationPages];
}
