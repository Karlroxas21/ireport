import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ireport/enums/menu_action.dart';
import 'package:ireport/services/auth/supabase.dart';
import 'package:ireport/services/bloc/auth_bloc.dart';
import 'package:ireport/services/bloc/navigation_bloc.dart';
import 'package:ireport/services/crud.dart';
import 'package:ireport/views/admin_dashboard_view.dart';
import 'package:ireport/views/admin_hotline.dart';
import 'package:ireport/views/create_admin_view.dart';
import 'package:ireport/views/home.dart';
import 'package:ireport/views/incident_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/bloc/auth_event.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  final List<String> _titles = ['Home', 'Dashboard', 'Report', 'Hotlines'];

  late final CrudService _crudService = CrudService(SupabaseService().client);

  @override
  void initState() {
    super.initState();
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

                        context.go('/');
                        break;
                      case MenuLoggedInAction.createAdminAccount:
                        context.push('/create-admin-account');
                        // Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => const CreateAdminAccount(),
                        //       ),
                        //     );
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem<MenuLoggedInAction>(
                        value: MenuLoggedInAction.createAdminAccount,
                        child: Text('Create Admin Account'),
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
                Container(
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Report and track incidents in real-time"),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Quick Actions",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const Text(
                                  "Common task you might want to do",
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                ListTile(
                                  contentPadding:
                                      const EdgeInsets.only(right: 86),
                                  title: const Text("View All Incidents"),
                                  trailing:
                                      const Icon(Icons.arrow_forward, size: 18),
                                  onTap: () {
                                    context
                                        .read<NavigationBloc>()
                                        .add(ChangePageEvent(1));
                                    // Navigator.pushNamed(context, '/view-incidents');
                                  },
                                  tileColor: Colors.transparent,
                                  selectedTileColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                ),
                                ListTile(
                                  contentPadding:
                                      const EdgeInsets.only(right: 86),
                                  title: const Text("Report New Incident"),
                                  trailing:
                                      const Icon(Icons.arrow_forward, size: 18),
                                  onTap: () {
                                    context
                                        .read<NavigationBloc>()
                                        .add(ChangePageEvent(2));

                                    // Navigator.pushNamed(context, '/report-incident');
                                  },
                                  tileColor: Colors.transparent,
                                  selectedTileColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                ),
                                ListTile(
                                  contentPadding:
                                      const EdgeInsets.only(right: 86),
                                  title: const Text("Emergency Hotlines"),
                                  trailing:
                                      const Icon(Icons.arrow_forward, size: 18),
                                  onTap: () {
                                    context
                                        .read<NavigationBloc>()
                                        .add(ChangePageEvent(3));
                                  },
                                  tileColor: Colors.transparent,
                                  selectedTileColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                          // Status Overview
                          const SizedBox(height: 16),
                          const Text(
                            "Status Overview",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: StreamBuilder<List<String>>(
                              stream: _crudService.getReportStatuses(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                      child: Text('No data available'));
                                } else {
                                  final statuses = snapshot.data!;
                                  final inProgressCount = statuses
                                      .where(
                                          (status) => status == 'in-progress')
                                      .length;
                                  final pendingCount = statuses
                                      .where((status) => status == 'pending')
                                      .length;
                                  final criticalCount = statuses
                                      .where((status) => status == 'critical')
                                      .length;
                                  final resolvedCount = statuses
                                      .where((status) => status == 'resolved')
                                      .length;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // In-progress
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.autorenew,
                                                color: Colors.blue),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "In-progress",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                Text(
                                                  "$inProgressCount",
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Pending Status
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.hourglass_empty,
                                                color: Colors.orange),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Pending",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                Text(
                                                  "$pendingCount",
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Critical Status
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.error,
                                                color: Colors.red),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Critical",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                Text(
                                                  "$criticalCount",
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Resolved Status
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check_circle,
                                                color: Colors.green),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Resolved",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                Text(
                                                  "$resolvedCount",
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const AdminDashboardView(),
                const HomeView(),
                const AdminHotline()
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
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.analytics), label: 'Report'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.emergency), label: 'Hotlines'),
              ],
            ),
          );
        }));
  }
}
