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
import 'package:ireport/views/home.dart';

import 'package:ireport/views/incident_view.dart';
import 'package:ireport/views/login_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  
  await dotenv.load(fileName: ".env");
  try {
    await SupabaseService.initialize();
   
  } catch (e) {
    // INSERT LOADING ERROR PAGE HERE
    print(e);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
         BlocProvider(create: (context) => AuthBloc(SupabaseAuthProvider())),
        BlocProvider(create: (context) => NavigationBloc()),
      ],
      child: MaterialApp(
        home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(SupabaseAuthProvider()),
        child: const HomeView(),
      ),
        routes: {
          '/login': (context) => const LoginView(),
          '/admin-home': (context) => const AdminHomeView(),
          '/home': (context) => const HomeView(),
          // Add other routes here
        },
      ),
    );
  }
  //   return MaterialApp(
  //     title: 'Flutter Demo',
  //     theme: ThemeData(
  //       useMaterial3: true,
  //     ),
  //     home: const MyHomePage(title: ''),
  //     routes: {
  //       '/login': (context) => const LoginView(),
  //       '/admin-dashboard': (context) => const AdminDashboardView(),
  //       '/admin-home': (context) => const AdminHomeView(),
  //       '/incident-view': (context) => const IncidentView(),
  //     },
  //   );
  // }
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

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {},
      builder: (BuildContext context, AuthState state) {
        if (state is AuthStateLoggedIn) {
          return Scaffold(
            body: BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, navState) {
                return _pages[navState.selectedIndex];
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex:
                    context.read<NavigationBloc>().state.selectedIndex,
                onTap: (index) =>
                    context.read<NavigationBloc>().add(ChangePageEvent(index)),
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard), label: 'Dashboard'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.analytics), label: 'Report'),
                ]),
          );
        }else {
          return const HomeView();
        }
      },
    );
  }
}
