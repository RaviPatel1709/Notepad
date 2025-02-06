import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotepadScreen(),
    );
  }
}

class NotepadScreen extends StatefulWidget {
  @override
  _NotepadScreenState createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> {
  List<TextEditingController> _noteControllers = [];
  List<String> _fileNames = [];
  List<FocusNode> _focusNodes = [];
  List<bool> _selectedFiles = [];
  bool _isInSelectionMode = false;
  bool _isGridView = false;
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredFileNames = [];
  List<TextEditingController> _filteredNoteControllers = [];

  // Load the notes from SharedPreferences
  void _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
    List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];

    int minLength = savedFileNames.length < savedFileContents.length
        ? savedFileNames.length
        : savedFileContents.length;

    setState(() {
      _fileNames = savedFileNames.take(minLength).toList();
      _noteControllers = savedFileContents
          .take(minLength)
          .map((content) => TextEditingController(text: content))
          .toList();
      _focusNodes = List.generate(minLength, (_) => FocusNode());
      _selectedFiles = List.generate(minLength, (_) => false);
      _filteredFileNames = List.from(_fileNames);
      _filteredNoteControllers = List.from(_noteControllers);
    });

    for (var controller in _noteControllers) {
      controller.addListener(() {
        setState(() {});
      });
    }
  }

  // Delete selected files
  Future<void> _deleteSelectedFiles(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Show confirmation dialog with a more attractive look
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners for a modern look
          ),
          title: Text(
            'Confirm Deletion',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red, // Color of the title to highlight the action
            ),
          ),
          content: Text(
            'Are you sure you want to delete the selected files?',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: <Widget>[
            // Cancel button with modern design
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed cancel
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade200, // Light grey background for cancel
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel, color: Colors.red), // Cancel icon
                  SizedBox(width: 8),
                  Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            // Delete button with attractive red color
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed deletion
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Red background for delete button
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, color: Colors.white), // Delete icon
                  SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // White text on delete button
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    // If the user confirmed the deletion
    if (confirmDelete == true) {
      List<String> newFileNames = [];
      List<String> newFileContents = [];

      setState(() {
        for (int i = 0; i < _fileNames.length; i++) {
          if (!_selectedFiles[i]) {
            newFileNames.add(_fileNames[i]);
            newFileContents.add(_noteControllers[i].text);
          }
        }

        _fileNames = List.from(newFileNames);
        _noteControllers = newFileContents
            .map((content) => TextEditingController(text: content))
            .toList();
        _focusNodes = List.generate(_fileNames.length, (_) => FocusNode());
        _selectedFiles = List.generate(_fileNames.length, (_) => false);

        _isInSelectionMode = false;
      });

      // Save updated data to SharedPreferences
      await prefs.setStringList('fileNames', newFileNames);
      await prefs.setStringList('fileContents', newFileContents);
    }
  }


  Future<void> _showCreateFileDialog() async {
    TextEditingController _fileNameController = TextEditingController();
    String _errorMessage = ''; // Variable to store error message

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Use StatefulBuilder to allow for state changes inside the dialog
          builder: (BuildContext context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15), // Rounded corners for the dialog
              ),
              elevation: 10, // Add shadow for better depth
              title: Text(
                "Enter File Name",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Better title styling
                ),
              ),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min, // Make sure content adjusts to fit
                children: [
                  TextField(
                    controller: _fileNameController,
                    decoration: InputDecoration(
                      hintText: "Create a new file",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                        borderSide: BorderSide(
                            color: Colors.orangeAccent), // Border color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                    autofocus: true, // Autofocus for quick typing
                    maxLength: 10, // Limit the file name to 20 characters
                    // maxLengthEnforced: true, // Enforce the maximum length
                  ),
                  SizedBox(
                      height:
                          10), // Add spacing between TextField and error message

                  // Show error message if present
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 10.0), // Space between error and button
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded button
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12), // Button padding
                  ),
                  onPressed: () {
                    String newFileName = _fileNameController.text.trim();

                    // Check if file name is empty
                    if (newFileName.isEmpty) {
                      setState(() {
                        _errorMessage =
                            "File name cannot be empty!"; // Set error message
                      });
                      return;
                    }

                    // Convert file names to lowercase for case-insensitive comparison
                    bool fileExists = _fileNames.any((file) =>
                        file.toLowerCase() == newFileName.toLowerCase());

                    if (fileExists) {
                      setState(() {
                        _errorMessage =
                            "A file with this name already exists!"; // Set error message
                      });
                      return;
                    }

                    setState(() {
                      _errorMessage = ''; // Clear error message if no error
                      _fileNames.insert(0, newFileName);
                      TextEditingController newController =
                          TextEditingController();
                      newController.addListener(() {
                        setState(() {});
                      });

                      _noteControllers.insert(0, newController);
                      _focusNodes.insert(0, FocusNode());
                      _selectedFiles.insert(0, false);
                    });

                    _filterFiles(_searchController
                        .text); // Re-filter after adding a new file
                    _saveAllNotes();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16), // Button text style
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Toggle selection of files
  void _toggleSelection(int index) {
    setState(() {
      _selectedFiles[index] = !_selectedFiles[index];
      _isInSelectionMode = _selectedFiles.contains(true);
    });
  }

  // Save all notes to SharedPreferences
  Future<void> _saveAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> fileContents =
        _noteControllers.map((controller) => controller.text).toList();

    await prefs.setStringList('fileNames', _fileNames);
    await prefs.setStringList('fileContents', fileContents);
  }

  // Show dialog to edit file name
  void _showEditFileNameDialog(int index) {
    TextEditingController _fileNameController =
    TextEditingController(text: _fileNames[index]);

    // FocusNode to handle the cursor placement
    FocusNode _focusNode = FocusNode();

    String _errorMessage = ''; // Variable to store error message

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Use StatefulBuilder to allow for state changes inside the dialog
          builder: (BuildContext context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              backgroundColor: Colors.white, // Dialog background color
              title: Text(
                "Edit File Name",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _fileNameController,
                      focusNode: _focusNode, // Set the focus node here
                      decoration: InputDecoration(
                        hintText: "Enter new file name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orangeAccent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      ),
                      autofocus: true, // Automatically focus when the dialog appears
                    ),
                    SizedBox(height: 10),
                    // Show error message if present
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    String newFileName = _fileNameController.text.trim();

                    // Check if the file name is empty
                    if (newFileName.isEmpty) {
                      setState(() {
                        _errorMessage = "File name cannot be empty.";
                      });
                      return;
                    }

                    // Check if the file name already exists
                    bool fileExists = _fileNames.any((file) =>
                    file.toLowerCase() == newFileName.toLowerCase() &&
                        file != _fileNames[index]);

                    if (fileExists) {
                      setState(() {
                        _errorMessage = "A file with this name already exists.";
                      });
                      return;
                    }

                    // If no error, update the file name
                    setState(() {
                      _fileNames[index] = newFileName;
                      _errorMessage = ''; // Clear error message
                    });

                    _filterFiles(_searchController.text); // Re-filter after editing the file name
                    _saveAllNotes();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange, // Button color
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Set the cursor in the text field after the dialog is shown
      Future.delayed(Duration(milliseconds: 100), () {
        _focusNode.requestFocus();
      });
    });
  }


  void _openFileDetails(int index) {
    print("Opening file at index: $index");
    print("Filtered file names: $_filteredFileNames");
    print(
        "Filtered note controllers length: ${_filteredNoteControllers.length}");

    if (index < 0 || index >= _filteredFileNames.length) {
      print("Error: Invalid index $index!");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileDetailScreen(
          fileName: _filteredFileNames[index],
          noteController: _filteredNoteControllers[index],
        ),
      ),
    ).then((_) {
      setState(() {
        _selectedFiles = List.generate(_fileNames.length, (_) => false);
        _isInSelectionMode = false;
        _searchController.clear();
        _filterFiles(""); // Reset filtered list
      });
    });
  }

  void _filterFiles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFileNames = List.from(_fileNames);
        _filteredNoteControllers = List.from(_noteControllers);
      } else {
        _filteredFileNames = [];
        _filteredNoteControllers = [];

        for (int i = 0; i < _fileNames.length; i++) {
          if (_fileNames[i].toLowerCase().contains(query.toLowerCase())) {
            _filteredFileNames.add(_fileNames[i]);
            _filteredNoteControllers.add(_noteControllers[i]);
          }
        }
      }

      // अगर फ़िल्टर के बाद कोई फ़ाइल नहीं बची तो सेलेक्शन मोड बंद कर दें।
      if (_filteredFileNames.isEmpty) {
        _isInSelectionMode = false;
      }

      // हमेशा चयनित फ़ाइलें रीसेट करें
      _selectedFiles = List.generate(_fileNames.length, (_) => false);
    });
  }

  void _selectAllFiles() {
    setState(() {
      bool allSelected = _selectedFiles.every((selected) => selected);
      if (allSelected) {
        _selectedFiles = List.generate(_fileNames.length, (_) => false);
        _isInSelectionMode = false;
      } else {
        _selectedFiles = List.generate(_fileNames.length, (_) => true);
        _isInSelectionMode = true;
      }
    });
  }

// Toggle selection mode
  void _toggleSelectionMode() {
    setState(() {
      _isInSelectionMode = !_isInSelectionMode;
      // Keep the selection mode active after the second long press if any files are selected
      if (!_isInSelectionMode && !_selectedFiles.contains(true)) {
        _selectedFiles = List.generate(_fileNames.length, (_) => false);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(() {
      _filterFiles(_searchController.text);
    });
  }

  // Toggle between grid and list view
  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white60,
        elevation: 4,
        shadowColor: Colors.white60,
        title: Text(
          "My notes",
          style: TextStyle(
            color:  (Colors.black),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black45, size: 28),
            onPressed: () async {
              final selectedFile = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    fileNames: _fileNames,
                    noteControllers: _noteControllers,
                  ),
                ),
              );

              if (selectedFile != null) {
                int index = _fileNames.indexOf(selectedFile);
                _openFileDetails(index);
              }
            },
            tooltip: "Search Notes",
          ),
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.orange,
              size: 28,
            ),
            onPressed: _toggleView,
            tooltip: 'Toggle View',
          ),
          if (_isInSelectionMode)
            IconButton(
              icon: Icon(Icons.select_all, color: Colors.orange, size: 28),
              onPressed: _selectAllFiles,
              tooltip: 'Select All',
            ),
          if (_isInSelectionMode)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
              onPressed: () async {
                await _deleteSelectedFiles(context); // Pass the context here
              },
              tooltip: 'Delete Selected Files',
            ),

          SizedBox(width: 10), // Extra spacing for better UI
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Deselect all files when the user taps outside
          if (_isInSelectionMode) {
            setState(() {
              _selectedFiles = List.generate(_fileNames.length, (_) => false);
              _isInSelectionMode = false;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.white60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _fileNames.isEmpty ? _buildEmptyState() : (_isGridView ? _buildGridView() : _buildListView()),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateFileDialog,
        backgroundColor: Colors.orange,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: Icon(
            Icons.add,
            key: ValueKey<int>(1),
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Build ListView
  Widget _buildListView() {
    List<int> sortedIndexes =
        List.generate(_fileNames.length, (index) => index);

    return ListView.builder(
      itemCount: sortedIndexes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding:
              const EdgeInsets.only(bottom: 11.0), // Increase bottom padding
          child: _buildFileItem(sortedIndexes[index]),
        );
      },
    );
  }

  // Build GridView
  Widget _buildGridView() {
    List<int> sortedIndexes =
        List.generate(_fileNames.length, (index) => index);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: sortedIndexes.length,
      itemBuilder: (context, index) {
        return _buildFileItem(sortedIndexes[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            "No files found.",
            style: TextStyle(fontSize: 24, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            "Tap the '+' button to create a new file.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build each file item in the list/grid
  Widget _buildFileItem(int index) {
    return GestureDetector(
      onLongPress: () {
        if (!_isInSelectionMode) {
          _toggleSelectionMode(); // Enable selection mode
          _toggleSelection(index); // Select the first file
        }
      },
      onTap: () {
        if (_isInSelectionMode) {
          _toggleSelection(
              index); // Allow single tap selection after long press
        } else {
          _openFileDetails(index); // Open file if not in selection mode
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description, color: Color(0xFFFFA500)),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '${_filteredFileNames[index]}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange, size: 19),
                    onPressed: () {
                      _showEditFileNameDialog(index); // Trigger the same function when this button is pressed
                    },
                  )

                ],
              ),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 11 * 8.0),
                  child: Text(
                    index < _filteredNoteControllers.length &&
                            _filteredNoteControllers[index].text.isNotEmpty
                        ? _filteredNoteControllers[index].text
                        : 'Add title...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final List<String> fileNames;
  final List<TextEditingController> noteControllers;

  SearchScreen({required this.fileNames, required this.noteControllers});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredFileNames = [];
  List<TextEditingController> _filteredNoteControllers = [];
  FocusNode _searchFocusNode = FocusNode(); // FocusNode

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _filterFiles(_searchController.text);
    });

    // Automatically focus on the search field when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  void _filterFiles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFileNames = [];
        _filteredNoteControllers = [];
      } else {
        _filteredFileNames = widget.fileNames
            .where((fileName) =>
                fileName.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _filteredNoteControllers = _filteredFileNames.map((fileName) {
          int index = widget.fileNames.indexOf(fileName);
          return widget.noteControllers[index];
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 6,
        leading: IconButton(onPressed: (){Navigator.pop(context);},
    icon: Icon(Icons.arrow_back_ios_new_outlined,),),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode, // Set the focus node here
            decoration: InputDecoration(
              hintText: "Search files...",
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.blueAccent),
            ),
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
      ),
      body: _filteredFileNames.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, color: Colors.grey[400], size: 60),
                  SizedBox(height: 16),
                  Text(
                    "No files found. Try searching...",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _filteredFileNames.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context, _filteredFileNames[index]);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.description, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _filteredFileNames[index],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _filteredNoteControllers[index].text.isNotEmpty
                                    ? _filteredNoteControllers[index]
                                        .text
                                        .split("\n")
                                        .take(1)
                                        .join("\n")
                                    : "Add title...",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.grey[600], size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class FileDetailScreen extends StatefulWidget {
  final String fileName;
  final TextEditingController noteController;

  FileDetailScreen({required this.fileName, required this.noteController});

  @override
  _FileDetailScreenState createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends State<FileDetailScreen> {
  List<TextEditingController> newFileControllers = [];
  List<String> fileNames = [];
  List<FocusNode> focusNodes = [];
  List<bool> _selectedFiles = []; // To track the selection of files
  bool _isInSelectionMode = false; // Flag to track if we are in selection mode

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load original file content
    String? savedNote = prefs.getString(widget.fileName);
    if (savedNote != null) {
      widget.noteController.text = savedNote;
    }

    // Load additional files
    fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
    _selectedFiles = List.generate(
        fileNames.length, (_) => false); // Initialize selection list
    newFileControllers.clear();
    focusNodes.clear(); // Clear focus nodes
    for (String fileName in fileNames) {
      String? fileContent = prefs.getString(fileName);
      if (fileContent != null) {
        TextEditingController newFileController =
            TextEditingController(text: fileContent);
        newFileControllers.add(newFileController);

        FocusNode newFocusNode = FocusNode();
        focusNodes.add(newFocusNode); // Add a FocusNode for the new file
      }
    }

    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.fileName, widget.noteController.text);

    for (int i = 0; i < newFileControllers.length; i++) {
      prefs.setString(fileNames[i], newFileControllers[i].text);
    }

    prefs.setStringList('fileNames_${widget.fileName}', fileNames);
  }

  Future<void> _deleteSelectedFiles(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Show confirmation dialog with a more attractive look
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners for a modern look
          ),
          title: Text(
            'Confirm Deletion',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent, // Color of the title to highlight the action
            ),
          ),
          content: Text(
            'Are you sure you want to delete the selected files?',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: <Widget>[
            // Cancel button with modern design
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed cancel
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade300, // Light grey background for cancel
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel, color: Colors.redAccent), // Cancel icon
                  SizedBox(width: 8),
                  Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            // Delete button with attractive red color
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed deletion
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent, // Red background for delete button
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, color: Colors.white), // Delete icon
                  SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // White text on delete button
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    // If the user confirmed the deletion
    if (confirmDelete == true) {
      List<String> newFileNames = [];
      List<String> newFileContents = [];

      setState(() {
        for (int i = 0; i < _selectedFiles.length; i++) {
          if (!_selectedFiles[i]) {
            newFileNames.add(fileNames[i]);
            newFileContents.add(newFileControllers[i].text);
          }
        }

        fileNames = List.from(newFileNames);
        newFileControllers = newFileContents
            .map((content) => TextEditingController(text: content))
            .toList();
        focusNodes = List.generate(fileNames.length, (_) => FocusNode());
        _selectedFiles = List.generate(fileNames.length, (_) => false);
        _isInSelectionMode = false;
      });

      // Update the data in SharedPreferences
      await prefs.setStringList('fileNames_${widget.fileName}', fileNames);
      for (int i = 0; i < newFileControllers.length; i++) {
        await prefs.setString(fileNames[i], newFileControllers[i].text);
      }
    }
  }


  void _selectAllFiles() {
    setState(() {
      // Select all files
      for (int i = 0; i < _selectedFiles.length; i++) {
        _selectedFiles[i] = true;
      }
    });
  }

  void _deselectAllFiles() {
    setState(() {
      // Deselect all files and disable selection mode
      for (int i = 0; i < _selectedFiles.length; i++) {
        _selectedFiles[i] = false;
      }
      _isInSelectionMode = false; // Disable selection mode
    });
  }

  Future<void> _showCreateFileDialog() async {
    TextEditingController _fileNameController = TextEditingController();
    String _errorMessage = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 10,
              title: Text(
                "Enter File Name",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _fileNameController,
                    decoration: InputDecoration(
                      hintText: "Create a new file",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                        borderSide: BorderSide(color: Colors.blue), // Border color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                    autofocus: true,
                    maxLength: 10,
                  ),
                  SizedBox(height: 10),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded button
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button padding
                  ),
                  onPressed: () {
                    String newFileName = _fileNameController.text.trim();

                    if (newFileName.isEmpty) {
                      setState(() {
                        _errorMessage = "File name cannot be empty!";
                      });
                      return;
                    }

                    bool fileExists = fileNames.any((file) =>
                    file.toLowerCase() == newFileName.toLowerCase());

                    if (fileExists) {
                      setState(() {
                        _errorMessage = "A file with this name already exists!";
                      });
                      return;
                    }

                    setState(() {
                      _errorMessage = '';
                      fileNames.insert(0, newFileName);
                      TextEditingController newController = TextEditingController();
                      newFileControllers.insert(0, newController);
                      FocusNode newFocusNode = FocusNode();
                      focusNodes.insert(0, newFocusNode);
                      _selectedFiles.insert(0, false); // Initialize selection state
                    });

                    // Save data and reload to reflect changes
                    _saveData();
                    _loadData(); // Reload data to ensure the UI is updated

                    // Ensure focus is requested only after the widget is stable
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Check if the widget is still mounted (active)
                      if (mounted) {
                        // Ensure that the context is valid before calling requestFocus
                        if (focusNodes.isNotEmpty) {
                          FocusScope.of(context).requestFocus(focusNodes[0]);
                        }
                      }
                    });

                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _editFileName(int index) async {
    TextEditingController _fileNameController =
    TextEditingController(text: fileNames[index]);
    String _errorMessage = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: Colors.white,
              title: Text(
                "Edit File Name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _fileNameController,
                      autofocus: true, // Automatically shows cursor
                      decoration: InputDecoration(
                        hintText: "Enter new file name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orangeAccent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    String newFileName = _fileNameController.text.trim();

                    // Check if the file name is empty
                    if (newFileName.isEmpty) {
                      setState(() {
                        _errorMessage = "File name cannot be empty!";
                      });
                      return;
                    }

                    // Check if the file name already exists
                    bool fileExists = fileNames.any((file) =>
                    file.toLowerCase() == newFileName.toLowerCase() &&
                        file != fileNames[index]);

                    if (fileExists) {
                      setState(() {
                        _errorMessage = "A file with this name already exists!";
                      });
                      return;
                    }

                    // If no error, update the file name
                    setState(() {
                      _errorMessage = ''; // Clear error message
                      fileNames[index] = newFileName;
                    });

                    _saveData();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFileItem(int index) {
    return GestureDetector(
      onLongPress: () {
        // Sirf tabhi chale jab selection mode inactive ho
        if (!_isInSelectionMode) {
          setState(() {
            _isInSelectionMode = true; // Selection mode enable
            _selectedFiles[index] = true; // Pehli file automatically select
          });
        }
      },
      onTap: () {
        // Sirf tabhi chale jab selection mode active ho
        if (_isInSelectionMode) {
          setState(() {
            _selectedFiles[index] = !_selectedFiles[index]; // Toggle selection

            // Agar sari files unselect ho gayi, to selection mode off karna hai
            bool anyFileSelected = _selectedFiles.contains(true);
            if (!anyFileSelected) {
              _isInSelectionMode = false; // Selection mode disable
            }
          });
        }
      },

      child: Column(
        children: [
          SizedBox(height: 11,),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
              border: Border.all(
                color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                   Icon(Icons.description, color: Colors.blue),
                   SizedBox(width: 7,),
                   Expanded(
                     child:
                         Text(
                           fileNames[index],
                           style: TextStyle(
                             fontWeight: FontWeight.bold,
                             fontSize: 20,
                             color: Colors.black87,
                           ),
                           overflow: TextOverflow.ellipsis,
                         ),


                   ),
                   IconButton(
                       icon: Icon(Icons.edit, color: Colors.blue, size: 19),
                       onPressed: () {
                         _editFileName(index);
                       },
                     ),
                 ],
               ),

                SizedBox(height: 6),
                TextField(
                  controller: newFileControllers[index],
                  focusNode: focusNodes[index], // Set the FocusNode here
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Write your notes...',
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                  onChanged: (text) {
                    _saveData();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isInSelectionMode) {
          setState(() {
            _isInSelectionMode = false;
            _selectedFiles =
                List.generate(fileNames.length, (_) => false); // Deselect all
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white60,
          elevation: 4,
          shadowColor: Colors.white60,
          title: Row(
            children: [
              Icon(Icons.description, color: Color(0xFFFFA500)),
              SizedBox(width: 11,),
              Text(
                widget.fileName,
                style: TextStyle(
                  color: Colors.black, // Title color
                  fontWeight: FontWeight.bold, // Bold font
                  fontSize: 22, // Increased font size
                ),
              ),

            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.black), // Back button color
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            // Select/Deselect All button - toggles between selecting and deselecting all files
            if (_isInSelectionMode)
              IconButton(
                icon: Icon(
                  _selectedFiles.every((selected) => selected) // Check if all are selected
                      ? Icons.select_all // Show Deselect All when all files are selected
                      : Icons.select_all, // Show Select All when not all files are selected
                  color: Colors.orange,
                  size: 28,
                ),
                onPressed: () {
                  if (_selectedFiles.every((selected) => selected)) {
                    _deselectAllFiles(); // Unselect all files
                  } else {
                    _selectAllFiles(); // Select all files
                  }
                },
                tooltip: _selectedFiles.every((selected) => selected)
                    ? 'Deselect All' // Tooltip when all files are selected
                    : 'Select All', // Tooltip when not all files are selected
              ),
            // Delete button - only shows if some files are selected
            if (_isInSelectionMode && _selectedFiles.any((selected) => selected))
              IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
                onPressed: () async {
                  await _deleteSelectedFiles(context); // Pass context to the method
                },
                tooltip: 'Delete Selected Files',
              ),

            SizedBox(width: 10), // Extra spacing for better UI
          ],

        ),
        body: Stack(
          children: [
            // GestureDetector for empty space
            GestureDetector(
              behavior: HitTestBehavior
                  .translucent, // Only detects taps on empty areas
              onTap: () {
                widget.noteController.selection = TextSelection.fromPosition(
                  TextPosition(offset: widget.noteController.text.length),
                );
                FocusScope.of(context)
                    .requestFocus(FocusNode()); // Move cursor to TextField
              },
              child: Container(), // Ensures GestureDetector covers the background
            ),

            // Main ListView Content
            ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: widget.noteController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: 'Title...',
                          labelStyle: TextStyle(color: Colors.blue,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),  // Smooth rounded corners
                            borderSide: BorderSide(color: Colors.orange, width: 2), // Stylish orange border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue, width: 2), // Black border when focused
                          ),
                          filled: true,
                          fillColor: Colors.white10 // Subtle background color
                        ),
                        style: TextStyle(fontSize: 18, color: Colors.black87), // Elegant text style
                        onChanged: (text) {
                          _saveData();
                        },
                      ),

                      ...List.generate(fileNames.length, (index) {
                        return _buildFileItem(
                            index); // Long press functionality will remain unchanged
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateFileDialog,
          backgroundColor: Colors.blue,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.add,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
