import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ireport/enums/incident_categories.dart';
import 'package:ireport/enums/menu_action.dart';
import 'package:ireport/services/auth/supabase.dart';
import 'package:ireport/services/bloc/auth_bloc.dart';
import 'package:ireport/services/bloc/auth_state.dart' as auth;
import 'package:ireport/services/crud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ireport/views/login_view.dart';
import 'package:ireport/views/register_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  File? _selectedImage;
  bool _isSubmitting = false;

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

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson =
        prefs.getString('user_data'); // Retrieve the stored JSON string
    if (userJson != null) {
      final Map<String, dynamic> userMap =
          jsonDecode(userJson) as Map<String, dynamic>;
      return userMap['id'] as String?; // Access the 'id' field
    }
    return null; // Return null if userJson is not found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FutureBuilder<String?>(
          future: SharedPreferences.getInstance()
              .then((prefs) => prefs.getString('user_data')),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink(); // Show nothing while loading
            }
            if (snapshot.hasData && snapshot.data != null) {
              return const SizedBox
                  .shrink(); // Hide the AppBar if metadataString has a value
            }
            return BlocBuilder<AuthBloc, auth.AuthState>(
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginView(),
                                ),
                              );
                              break;
                            case MenuAction.register:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterView(),
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder: (context) {
                          return const [
                            PopupMenuItem<MenuAction>(
                              value: MenuAction.login,
                              child: Text('Log In'),
                            ),
                            PopupMenuItem<MenuAction>(
                              value: MenuAction.register,
                              child: Text('Register'),
                            ),
                          ];
                        },
                      )
                    ],
                  );
                }
              },
            );
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
                        'Title*',
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
                    FutureBuilder<String?>(
                      future: SharedPreferences.getInstance().then(
                        (prefs) => prefs.getString('user_metadata'),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox
                              .shrink(); // Show nothing while loading
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          print('user_metadata: ${snapshot.data}');
                          return const SizedBox
                              .shrink(); // Hide the field if metadataString has a value
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Name(Optional)',
                            ),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: "Enter your name here",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Incident Type*',
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
                      'Location*',
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
                      'Description*',
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
                    const SizedBox(height: 16),
                    const Text('Attach Picture(Optional)'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _pickImage(ImageSource.camera),
                              child: const Text('Camera'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              child: const Text('Gallery'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_selectedImage != null) ...[
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.file(_selectedImage!),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Image.file(
                              _selectedImage!,
                              height: 100,
                              width: 100,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            child: const Text('Remove Image'),
                          ),
                        ],
                      ],
                    )
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
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            setState(() {
                              _isSubmitting = true;
                            });
                            final title = _titleController.text;
                            final name = await SharedPreferences.getInstance()
                                .then((prefs) {
                              final metadataString =
                                  prefs.getString('user_metadata');
                              if (metadataString != null) {
                                final metadataMap = jsonDecode(metadataString)
                                    as Map<String, dynamic>;
                                final firstName =
                                    metadataMap['first_name'] ?? '';
                                final lastName = metadataMap['last_name'] ?? '';
                                return '$firstName $lastName'
                                    .trim();
                              }
                              return _nameController
                                  .text; // Fallback to the name entered in the form
                            });
                            final userId = await getUserId() ?? null;
                            final location = _locationController.text;
                            final description = _descriptionController.text;
                            var category = _selectedCategory?.label;

                            String? imageUrl;

                            if (_selectedCategory == Category.category11) {
                              category = _otherCategoryController.text;
                            }
                            final fileName =
                                DateTime.now().toString() + "_" + title;

                            final reportData = {
                              'title': title,
                              'reported_by': userId,
                              'name': name,
                              'incident_type': category,
                              'location': location,
                              'description': description,
                              'status': DEFAULT_STATUS,
                            };

                            try {
                              if (_selectedImage != null) {
                                final response = await _crudService.uploadFile(
                                    _selectedImage!, fileName);

                                if (response) {
                                  imageUrl =
                                      await _crudService.getImageFile(fileName);
                                } else {
                                  throw Exception(
                                      'Failed to upload image: ${response}');
                                }
                              }

                              if (imageUrl != null) {
                                reportData['image_url'] = imageUrl;
                              }

                              final result =
                                  await _crudService.insertReport(reportData);
                              if (result) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Report submitted successfully')),
                                );
                                _titleController.clear();
                                _nameController.clear();
                                _locationController.clear();
                                _descriptionController.clear();
                                setState(() {
                                  _selectedCategory = null;
                                  _selectedImage = null;
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
                                    content:
                                        Text('Failed to submit report: $e')),
                              );
                            } finally {
                              setState(() {
                                _isSubmitting = false;
                              });
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Special Characters are not allowed')),
                            );
                          }
                        },
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text(
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
