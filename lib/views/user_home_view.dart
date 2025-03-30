import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ireport/enums/menu_action.dart';
import 'package:ireport/services/auth/supabase.dart';
import 'package:ireport/services/bloc/auth_bloc.dart';
import 'package:ireport/services/bloc/auth_event.dart';
import 'package:ireport/services/bloc/navigation_bloc.dart';
import 'package:ireport/services/crud.dart';
import 'package:ireport/views/admin_hotline.dart';
import 'package:ireport/views/home.dart';
import 'package:ireport/views/user_history_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final List<String> _titles = ['My account', 'History', 'Report', 'Hotlines'];

  late final CrudService _crudService = CrudService(SupabaseService().client);

  Future<Map<String, dynamic>> getUserMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final userMetadata = prefs.getString('user_metadata');
    if (userMetadata != null) {
      return Map<String, dynamic>.from(jsonDecode(userMetadata) as Map);
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(),
      child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _titles[state.selectedIndex],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              PopupMenuButton<MenuLoggedInAction>(
                onSelected: (value) async {
                  switch (value) {
                    case MenuLoggedInAction.logout:
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();

                      context.read<AuthBloc>().add(const AuthEventLogout());

                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (Route<dynamic> route) => false,
                      );
                      break;

                    case MenuLoggedInAction.hotlines:
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/admin-hotline',
                        (Route<dynamic> route) => false,
                      );
                      break;
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem<MenuLoggedInAction>(
                      value: MenuLoggedInAction.hotlines,
                      child: Text('Hotlines'),
                    ),
                    PopupMenuItem<MenuLoggedInAction>(
                      value: MenuLoggedInAction.logout,
                      child: Text('Log Out'),
                    ),
                  ];
                },
              )
            ],
          ),
          body: IndexedStack(
            index: state.selectedIndex,
            children: [
              Scaffold(
                body: FutureBuilder<Map<String, dynamic>>(
                  future: getUserMetadata(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No user data available.'));
                    } else {
                      final userDetails = snapshot.data!;
                      print(userDetails);
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'First Name: ${userDetails['first_name'] ?? ' '}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              const Divider(color: Colors.grey),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Last Name: ${userDetails['last_name'] ?? ' '}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              const Divider(color: Colors.grey),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Phone Number: ${userDetails['phone'] ?? ' '}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              const Divider(color: Colors.grey),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Email: ${userDetails['email'] ?? ' '}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const UserHistory(),
              const HomeView(),
              const AdminHotline(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            fixedColor: Colors.black,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            currentIndex: context.read<NavigationBloc>().state.selectedIndex,
            onTap: (index) =>
                context.read<NavigationBloc>().add(ChangePageEvent(index)),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.people), label: 'Account'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history), label: 'History'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.analytics), label: 'Report'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.emergency), label: 'Hotlines'),
            ],
          ),
        );
      }),
    );
  }
}
