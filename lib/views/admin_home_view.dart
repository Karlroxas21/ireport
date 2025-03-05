import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ireport/enums/menu_action.dart';
import 'package:ireport/services/bloc/auth_bloc.dart';
import 'package:ireport/services/bloc/navigation_bloc.dart';
import 'package:ireport/views/admin_dashboard_view.dart';
import 'package:ireport/views/home.dart';
import 'package:ireport/views/incident_view.dart';

import '../services/bloc/auth_event.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  final List<String> _titles = ['Home', 'Dashboard', 'Report'];

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
                        context.read<AuthBloc>().add(const AuthEventLogout());

                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (Route<dynamic> route) => false,
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return const [
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
                                  title: const Text("Report New Incident"),
                                  trailing:
                                      const Icon(Icons.arrow_forward, size: 18),
                                  onTap: () {
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
                                  title: const Text("View All Incidents"),
                                  trailing:
                                      const Icon(Icons.arrow_forward, size: 18),
                                  onTap: () {
                                    // Navigator.pushNamed(context, '/view-incidents');
                                  },
                                  tileColor: Colors.transparent,
                                  selectedTileColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                ),
                                ListTile(
                                  contentPadding:
                                      const EdgeInsets.only(right: 86),
                                  title: const Text("Extract All Reports"),
                                  trailing:
                                      const Icon(Icons.download, size: 18),
                                  onTap: () {
                                    // Navigator.pushNamed(context, '/view-incidents');
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
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Pending Status
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.pending,
                                            color: Colors.orange),
                                        SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Pending",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            Text(
                                              "123",
                                              style: TextStyle(fontSize: 14),
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.error, color: Colors.red),
                                        SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Critical",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            Text(
                                              "5",
                                              style: TextStyle(fontSize: 14),
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.green),
                                        SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Resolved",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            Text(
                                              "20",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                const AdminDashboardView(),
                const HomeView(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: context.read<NavigationBloc>().state.selectedIndex,
              onTap: (index) =>
                  context.read<NavigationBloc>().add(ChangePageEvent(index)),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.analytics), label: 'Report'),
              ],
            ),
          );
        },
      ),
    );
  }
}
