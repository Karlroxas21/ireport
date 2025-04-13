import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
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
import 'package:ireport/views/forgot_password_view.dart';
import 'package:ireport/views/home.dart';
import 'package:ireport/views/send_forgot_password.dart';
import 'package:ireport/views/user_home_view.dart';
import 'package:ireport/views/user_incident_view.dart';
import 'package:shared_preferences/shared_preferences.dart' as custom;
import 'package:ireport/views/incident_view.dart';
import 'package:ireport/views/login_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ireport/views/register_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    await SupabaseService.initialize();
  } catch (e) {
    // INSERT LOADING ERROR PAGE HERE
    throw Exception('Failed to initialize Supabase: $e');
  }

  final appLinks = AppLinks();

  Uri? initialUri = await appLinks.getInitialLink();

  final prefs = await custom.SharedPreferences.getInstance();
  final userJson = prefs.getString('user_data');
  final metadataString = prefs.getString('user_metadata');

  if (userJson != null && metadataString != null) {
    final Map<String, dynamic> metadataMap =
        jsonDecode(metadataString) as Map<String, dynamic>;
    final String role = metadataMap['role'] ?? '';

    if (role == 'user') {
      initialUri ??= Uri.parse('/user-home');
    } else {
      initialUri ??= Uri.parse('/admin-home');
    }
  } else {
    initialUri ??= Uri.parse('/');
  }

  runApp(MyApp(initialUri: initialUri));
}

class MyApp extends StatefulWidget {
  final Uri? initialUri;

  const MyApp({super.key, required this.initialUri});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  late AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: widget.initialUri?.path ?? '/', // Use initialUri
      routes: [
        GoRoute(
            path: '/',
            name: '/',
            builder: (context, state) => const HomeView()),
        GoRoute(
            path: '/register',
            name: '/register',
            builder: (context, state) => const RegisterView()),
        GoRoute(
            path: '/login',
            name: '/login',
            builder: (context, state) => const LoginView()),
        GoRoute(
            path: '/user-home',
            name: '/user-home',
            builder: (context, state) => const UserHome()),
        GoRoute(
            path: '/admin-home',
            name: '/admin-home',
            builder: (context, state) => const AdminHomeView()),
        GoRoute(
            path: '/incident-view',
            name: '/incident-view',
            builder: (context, state) => const IncidentView()),
        GoRoute(
            path: '/admin-hotline',
            name: '/admin-hotline',
            builder: (context, state) => const AdminHotline()),
        GoRoute(
            path: '/admin-dashboard',
            name: '/admin-dashboard',
            builder: (context, state) => const AdminDashboardView()),
        GoRoute(
            path: '/create-admin-account',
            name: '/create-admin-account',
            builder: (context, state) => const CreateAdminAccount()),
        GoRoute(
            path: '/user-incident-view',
            name: '/user-incident-view',
            builder: (context, state) => const UserIncidentView()),
        GoRoute(
            path: '/email-confirmed',
            name: '/email-confirmed',
            builder: (context, state) => const EmailConfirmed()),
        GoRoute(
            path: '/send-forgot-password',
            name: '/send-forgot-password',
            builder: (context, state) => const ForgotPasswordScreen()),
        GoRoute(
            path: '/forgot-password',
            name: '/forgot-password',
            builder: (context, state) => const ForgotPassword()),
      ],
      redirect: (context, state) {
        final uri = state.uri;

        return null; // No redirection
      },
    );

    initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    if (widget.initialUri != null) {
      _handleDeepLink(widget.initialUri!);
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path == '/email-confirmed') {
      _router.pushNamed('/email-confirmed');
    } else if (uri.path == '/forgot-password') {
      _handlePasswordResetDeepLink(uri);
    }
  }

  Future<void> _handlePasswordResetDeepLink(Uri uri) async {
    try {
      print('Password reset deep link received: $uri');

      String? token;
      final supabaseService = SupabaseService();

      // Check fragment first (after #)
      if (uri.fragment.isNotEmpty) {
        final fragmentParams = Uri.splitQueryString(uri.fragment);
        token = fragmentParams['token'] ?? fragmentParams['access_token'];
      }

      // If not in fragment, check query params
      if (token == null && uri.queryParameters.containsKey('token')) {
        token = uri.queryParameters['token'];
      }

      print('Token found: ${token != null}');

      if (token != null) {
        // PKCE links, we need to exchange the token
        print('Exchanging PKCE token for session...');
        try {
          final response =
              await supabaseService.client.auth.getSessionFromUrl(uri);
          print('Session established from URL: ${response.session != null}');

          _router.pushNamed('/forgot-password');
          return;
        } catch (e) {
          print('Error exchanging token: $e');
        }
      }

      // Fall back to checking if we already have a session
      final session = supabaseService.client.auth.currentSession;
      print('Current session: ${session != null}');

      if (session != null) {
        _router.pushNamed('/forgot-password');
      } else {
        print(
            'No valid session established. Redirecting to reset password request screen');
        _router.pushNamed('/send-forgot-password');
      }
    } catch (e) {
      print('Error handling password reset deep link: $e');
      _router.pushNamed('/send-forgot-password');
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(SupabaseAuthProvider())),
        BlocProvider(create: (context) => NavigationBloc()),
      ],
      child: MaterialApp.router(routerConfig: _router),
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

      return role == 'user';
    }

    return false;
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
