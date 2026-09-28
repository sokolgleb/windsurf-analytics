import 'package:go_router/go_router.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/my_spots/my_spots_screen.dart';
import '../screens/raw_data/raw_data_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/my-spots',
      builder: (context, state) => const MySpotsScreen(),
    ),
    GoRoute(
      path: '/raw-data',
      builder: (context, state) => const RawDataScreen(),
    ),
  ],
);
