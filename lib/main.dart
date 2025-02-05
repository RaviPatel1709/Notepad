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
  Future<void> _deleteSelectedFiles() async {
    final prefs = await SharedPreferences.getInstance();

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

    // अपडेटेड डेटा को SharedPreferences में सेव करें
    await prefs.setStringList('fileNames', newFileNames);
    await prefs.setStringList('fileContents', newFileContents);
  }

  Future<void> _showCreateFileDialog() async {
    TextEditingController _fileNameController = TextEditingController();
    String _errorMessage = ''; // Variable to store error message

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder to allow for state changes inside the dialog
          builder: (BuildContext context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded corners for the dialog
              ),
              elevation: 10, // Add shadow for better depth
              title: Text(
                "Enter File Name",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, // Better title styling
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Make sure content adjusts to fit
                  children: [
                    TextField(
                      controller: _fileNameController,
                      decoration: InputDecoration(
                        hintText: "Enter new file name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                          borderSide: BorderSide(color: Colors.blueAccent), // Border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                      autofocus: true, // Autofocus for quick typing
                      maxLength: 10, // Limit the file name to 20 characters
                      // maxLengthEnforced: true, // Enforce the maximum length
                    ),
                    SizedBox(height: 10), // Add spacing between TextField and error message

                    // Show error message if present
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0), // Space between error and button
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded button
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button padding
                    ),
                    onPressed: () {
                      String newFileName = _fileNameController.text.trim();

                      // Check if file name is empty
                      if (newFileName.isEmpty) {
                        setState(() {
                          _errorMessage = "File name cannot be empty!"; // Set error message
                        });
                        return;
                      }

                      // Convert file names to lowercase for case-insensitive comparison
                      bool fileExists = _fileNames.any(
                              (file) => file.toLowerCase() == newFileName.toLowerCase());

                      if (fileExists) {
                        setState(() {
                          _errorMessage = "A file with this name already exists!"; // Set error message
                        });
                        return;
                      }

                      setState(() {
                        _errorMessage = ''; // Clear error message if no error
                        _fileNames.insert(0, newFileName);
                        TextEditingController newController = TextEditingController();
                        newController.addListener(() {
                          setState(() {});
                        });

                        _noteControllers.insert(0, newController);
                        _focusNodes.insert(0, FocusNode());
                        _selectedFiles.insert(0, false);
                      });

                      _filterFiles(_searchController.text); // Re-filter after adding a new file
                      _saveAllNotes();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Create',
                      style: TextStyle(color: Colors.white, fontSize: 16), // Button text style
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit File Name"),
          content: TextField(
            controller: _fileNameController,
            decoration: InputDecoration(hintText: "Edit file name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _fileNames[index] = _fileNameController.text;
                });

                _filterFiles(_searchController
                    .text); // Re-filter after editing the file name
                _saveAllNotes();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _openFileDetails(int index) {
    print("Opening file at index: $index");
    print("Filtered file names: $_filteredFileNames");
    print("Filtered note controllers length: ${_filteredNoteControllers.length}");

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
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        title: Text(
          "Notepad",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.blueAccent, size: 28),
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
              color: Colors.blueAccent,
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
              onPressed: _deleteSelectedFiles,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isGridView ? _buildGridView() : _buildListView(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateFileDialog,
        backgroundColor: Colors.blueAccent,
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
          padding: const EdgeInsets.only(bottom: 11.0), // Increase bottom padding
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
          _toggleSelection(index); // Allow single tap selection after long press
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
                  Icon(Icons.description, color: Colors.blueAccent),
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
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Edit') {
                        _showEditFileNameDialog(index);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'Edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(Icons.more_vert, color: Colors.grey.shade700),
                  ),
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
                        : 'Add content...',
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _filterFiles(_searchController.text);
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
                        Icon(Icons.description, color: Colors.blueAccent),
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
                                        .take(2)
                                        .join("\n")
                                    : "No content...",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
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
  // List to store controllers for each new file's content
  List<TextEditingController> newFileControllers = [];
  List<String> fileNames = []; // List to store new file names

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData(); // Call this in didChangeDependencies to reload data when screen is revisited
  }

  // Load data from SharedPreferences when the screen is opened
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load original file content
    String? savedNote = prefs.getString(widget.fileName);
    if (savedNote != null) {
      widget.noteController.text = savedNote;
    }

    // Load additional files (if any) specific to this file
    fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
    newFileControllers.clear(); // Clear the old list to prevent duplicates
    for (String fileName in fileNames) {
      String? fileContent = prefs.getString(fileName);
      if (fileContent != null) {
        TextEditingController newFileController =
            TextEditingController(text: fileContent);
        newFileControllers.add(newFileController);
      }
    }

    setState(() {}); // Trigger a rebuild after loading data
  }

  // Save data to SharedPreferences when text changes
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save the original note
    prefs.setString(widget.fileName, widget.noteController.text);

    // Save new files
    for (int i = 0; i < newFileControllers.length; i++) {
      prefs.setString(fileNames[i], newFileControllers[i].text);
    }

    // Save file names list specific to this file context
    prefs.setStringList('fileNames_${widget.fileName}', fileNames);
  }

  // Show create file dialog and save new file
  Future<void> _showCreateFileDialog() async {
    TextEditingController _fileNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter File Name"),
          content: TextField(
            controller: _fileNameController,
            decoration: InputDecoration(hintText: "Enter new file name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  String newFileName = _fileNameController.text.trim();
                  if (newFileName.isNotEmpty) {
                    // Add the new file name to the list specific to this file
                    fileNames.add(newFileName);

                    // Create a new controller for the new file's content
                    TextEditingController newFileController =
                        TextEditingController();
                    newFileControllers.add(newFileController);
                  }
                });

                // Save all data to SharedPreferences, specific to this file
                _saveData();

                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // Delete file method
  Future<void> _deleteFile(int index) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove file from SharedPreferences
    await prefs.remove(fileNames[index]);

    // Remove the file from the list and controller
    setState(() {
      fileNames.removeAt(index);
      newFileControllers.removeAt(index);
    });

    // Update file names list in SharedPreferences
    await prefs.setStringList('fileNames_${widget.fileName}', fileNames);
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete File"),
          content:
              Text("Are you sure you want to delete '${fileNames[index]}'?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteFile(index); // Call delete function
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Edit file name method
  Future<void> _editFileName(int index) async {
    TextEditingController _fileNameController =
        TextEditingController(text: fileNames[index]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit File Name"),
          content: TextField(
            controller: _fileNameController,
            decoration: InputDecoration(hintText: "Enter new file name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  String newFileName = _fileNameController.text.trim();
                  if (newFileName.isNotEmpty) {
                    // Update the file name in the list
                    fileNames[index] = newFileName;
                  }
                });

                // Save updated data to SharedPreferences
                _saveData();

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Build file item with delete and edit options
  Widget _buildFileItem(int index) {
    return GestureDetector(
      onLongPress: () {
        _showDeleteConfirmationDialog(
            index); // Long press for delete confirmation
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fileNames[index],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: Colors.orange), // Edit button
                        onPressed: () {
                          _editFileName(index); // Show dialog to edit file name
                        },
                      ),
                    ],
                  ),
                ],
              ),
              TextField(
                controller: newFileControllers[index],
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter content...',
                ),
                onChanged: (text) {
                  _saveData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.fileName), // Display the original file name in the AppBar
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // The original file's note (TextField for the initial file)
                TextField(
                  controller: widget.noteController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: 'Edit your note',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    _saveData();
                  },
                ),
                // Dynamically created new file content TextFields below the original one
                ...List.generate(fileNames.length, (index) {
                  return _buildFileItem(index); // Use the method for each file
                }),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateFileDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
