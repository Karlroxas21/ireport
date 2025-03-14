import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ireport/enums/incident_categories.dart';
import 'package:ireport/enums/menu_action.dart';
import 'package:ireport/services/auth/supabase.dart';
import 'package:ireport/services/bloc/auth_bloc.dart';
import 'package:ireport/services/bloc/auth_state.dart' as auth;
import 'package:ireport/services/crud.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DEFAULT_STATUS = 'pending';
  Category? _selectedCategory;
  final TextEditingController _otherCategoryController =
      TextEditingController();

  late final CrudService _crudService = CrudService(SupabaseService().client);
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // try {
    //   await SupabaseService.initialize();
    // } catch (e) {
    //   rethrow;
    // }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<AuthBloc, auth.AuthState>(
          builder: (context, state) {
            if (state is auth.AuthStateLoggedIn) {
              return const SizedBox.shrink();
            } else {
              return AppBar(
                title: const Text(
                  'Incident Report',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  PopupMenuButton<MenuAction>(
                    onSelected: (value) async {
                      switch (value) {
                        case MenuAction.login:
                          Navigator.pushNamed(context, '/login');
                          break;
                        case MenuAction.adminDashboard:
                          // context.read<AuthBloc>().add(const AuthEventLogout());
                          break;
                        case MenuAction.adminHome:
                          // context.read<AuthBloc>().add(const AuthEventLogout());
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem<MenuAction>(
                          value: MenuAction.login,
                          child: Text('Log In'),
                        ),
                      ];
                    },
                  )
                ],
              );
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Incident Details",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const Text(
                      "Provide information about the incident you want to report",
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Title',
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: "Brief title of the incident",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Special characters are not allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Name(Optional)',
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Enter your name here",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Incident Type',
                    ),
                    DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      hint: const Text('Select an incident type'),
                      items: Category.values
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category.label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                        hoverColor: Colors.transparent,
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an incident type';
                        }
                        return null;
                      },
                    ),
                    if (_selectedCategory == Category.category11) ...[
                      const SizedBox(height: 10),
                      TextFormField(
                      controller: _otherCategoryController,
                      decoration: InputDecoration(
                        hintText: "Specify the incident type",
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                        return 'Please specify the incident type';
                        }
                        return null;
                      },
                      ),
                    ],
                    const SizedBox(height: 10),
                    const Text(
                      'Location',
                    ),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: "Enter the exact location here",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
                          return 'Special characters are not allowed';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final title = _titleController.text;
                      final name = _nameController.text;
                      final location = _locationController.text;
                      final description = _descriptionController.text;
                      var category = _selectedCategory?.label;
                      if (_selectedCategory == Category.category11) {
                        category = _otherCategoryController.text;
                      }

                      final reportData = {
                        'title': title,
                        'name': name,
                        'incident_type': category,
                        'location': location,
                        'description': description,
                        'status': DEFAULT_STATUS,
                      };

                      try {
                        final result =
                            await _crudService.insertReport(reportData);
                        if (result) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Report submitted successfully')),
                          );
                          _titleController.clear();
                          _nameController.clear();
                          _locationController.clear();
                          _descriptionController.clear();
                          setState(() {
                            _selectedCategory = null;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to submit report')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to submit report: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Special Characters are not allowed')),
                      );
                    }
                  },
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
