import 'package:HyS/pages/clients/clients.dart';
import 'package:HyS/pages/drivers/drivers.dart';
import 'package:HyS/pages/overView/overview.dart';
import 'package:HyS/routing/routes.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case OverViewPageRoute:
      return _getPageRoute(OverView());
    case DriversPageRoute:
      return _getPageRoute(Drivers());
    case ClientsPageRoute:
      return _getPageRoute(Clients());
    case AuthenticationPageRoute:
      return _getPageRoute(OverView());

    default:
      return _getPageRoute(OverView());
  }
}

PageRoute _getPageRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}
