import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ireport/services/auth/supabase.dart';
import 'package:ireport/services/auth/supabase_auth_provider.dart';
import 'package:ireport/services/bloc/auth_bloc.dart';
import 'package:ireport/services/bloc/auth_event.dart';
import 'package:ireport/services/bloc/auth_state.dart';
import 'package:ireport/services/bloc/navigation_bloc.dart';
import 'package:ireport/views/admin_dashboard_view.dart';
import 'package:ireport/views/admin_home_view.dart';
import 'package:ireport/views/admin_hotline.dart';
import 'package:ireport/views/create_admin_view.dart';
import 'package:ireport/views/email_confirmed_view.dart';
import 'package:ireport/views/home.dart';
import 'package:ireport/views/link_expired_view.dart';
import 'package:ireport/views/user_home_view.dart';
import 'package:ireport/views/user_incident_view.dart';
import 'package:shared_preferences/shared_preferences.dart' as custom;

import 'package:ireport/views/incident_view.dart';
import 'package:ireport/views/login_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ireport/views/register_view.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  try {
    await SupabaseService.initialize();
  } catch (e) {
    // INSERT LOADING ERROR PAGE HERE
    print(e);
  }

  final prefs = await custom.SharedPreferences.getInstance();
  final userJson = prefs.getString('user_data');
  final metadataString = prefs.getString('user_metadata');

  Widget initialScreen;

  if (userJson != null && metadataString != null) {
    final Map<String, dynamic> metadataMap =
        jsonDecode(metadataString) as Map<String, dynamic>;
    final String role = metadataMap['role'] ?? '';

    if (role == 'user') {
      initialScreen = const UserHome();
    } else {
      initialScreen = const AdminHomeView();
    }
  } else {
    initialScreen = const HomeView();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(SupabaseAuthProvider())),
        BlocProvider(create: (context) => NavigationBloc()),
      ],
      child: MaterialApp(
        home: initialScreen,
        routes: {
          '/login': (context) => const LoginView(),
          '/admin-home': (context) => const AdminHomeView(),
          '/home': (context) => const HomeView(),
          '/incident-view': (context) => const IncidentView(),
          '/admin-hotline': (context) => const AdminHotline(),
          '/register': (context) => const RegisterView(),
          '/user-home': (context) => const UserHome(),
          '/user-incident-view': (context) => const UserIncidentView(),
          '/create-admin-account': (context) => const CreateAdminAccount(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _pages = [
    const AdminHomeView(),
    const AdminDashboardView(),
    const HomeView(),
  ];

  Future<Map<String, dynamic>?> getUserMetadata() async {
    final prefs = await custom.SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      final Map<String, dynamic> userMap =
          jsonDecode(userJson) as Map<String, dynamic>;
      return userMap['userMetadata'] as Map<String, dynamic>?;
    }
    return null;
  }

  Future<bool> isUser() async {
    final userMetadata = await getUserMetadata();

    if (userMetadata != null) {
      final String role = userMetadata['role'];

      print('METHOD: $role');

      return role == 'user';
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {},
      builder: (BuildContext context, AuthState state) {
        if (state is AuthStateLoggedIn) {
          final userMetadata = state.userMetadata;
          // final isUserRole = userMetadata?['role'] == 'user';
          return Scaffold(
            body: BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, navState) {
                return _pages[navState.selectedIndex];
              },
            ),
            bottomNavigationBar: FutureBuilder<bool>(
              future: isUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink(); // Show nothing while loading
                }
                final isUserRole = snapshot.data ?? false;
                return BottomNavigationBar(
                  currentIndex:
                      context.read<NavigationBloc>().state.selectedIndex,
                  onTap: (index) => context
                      .read<NavigationBloc>()
                      .add(ChangePageEvent(index)),
                  items: isUserRole
                      ? const [
                          BottomNavigationBarItem(
                              icon: Icon(Icons.analytics), label: 'Report'),
                        ]
                      : const [
                          BottomNavigationBarItem(
                              icon: Icon(Icons.home), label: 'Home'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.dashboard), label: 'Dashboard'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.analytics), label: 'Report'),
                        ],
                );
              },
            ),
          );
        } else {
          return const HomeView();
        }
      },
    );
  }
}
