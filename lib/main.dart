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

  void _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
    List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];

    int minLength = savedFileNames.length < savedFileContents.length ? savedFileNames.length : savedFileContents.length;

    setState(() {
      _fileNames = savedFileNames.take(minLength).toList();
      _noteControllers = savedFileContents.take(minLength)
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

  void _filterFiles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFileNames = List.from(_fileNames);
        _filteredNoteControllers = List.from(_noteControllers);
      } else {
        _filteredFileNames = _fileNames.where((fileName) => fileName.toLowerCase().contains(query.toLowerCase())).toList();
        _filteredNoteControllers = _filteredFileNames.map((fileName) {
          int index = _fileNames.indexOf(fileName);
          return _noteControllers[index];
        }).toList();
      }
    });
  }

  Future<void> _deleteSelectedFiles() async {
    setState(() {
      List<int> toRemove = [];
      for (int i = 0; i < _selectedFiles.length; i++) {
        if (_selectedFiles[i]) {
          toRemove.add(i);
        }
      }

      for (int i = toRemove.length - 1; i >= 0; i--) {
        _fileNames.removeAt(toRemove[i]);
        _noteControllers.removeAt(toRemove[i]);
        _focusNodes.removeAt(toRemove[i]);
        _selectedFiles.removeAt(toRemove[i]);
      }

      _isInSelectionMode = false;
    });

    _saveAllNotes();
  }

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
                    _fileNames.add(newFileName);
                    TextEditingController newController = TextEditingController();
                    newController.addListener(() {
                      setState(() {});
                    });

                    _noteControllers.add(newController);
                    _focusNodes.add(FocusNode());
                    _selectedFiles.add(false);
                  }
                });

                _filterFiles(_searchController.text); // Re-filter after adding a new file
                _saveAllNotes();
                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      _selectedFiles[index] = !_selectedFiles[index];
      _isInSelectionMode = _selectedFiles.contains(true);
    });
  }

  Future<void> _saveAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> fileContents =
    _noteControllers.map((controller) => controller.text).toList();

    await prefs.setStringList('fileNames', _fileNames);
    await prefs.setStringList('fileContents', fileContents);
  }

  void _showEditFileNameDialog(int index) {
    TextEditingController _fileNameController = TextEditingController(text: _fileNames[index]);

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

                _filterFiles(_searchController.text); // Re-filter after editing the file name
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileDetailScreen(
          fileName: _fileNames[index],
          noteController: _noteControllers[index],
        ),
      ),
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isInSelectionMode = !_isInSelectionMode;
      if (!_isInSelectionMode) {
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

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notepad"),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleView,
            tooltip: 'Toggle View',
          ),
          if (_isInSelectionMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedFiles,
              tooltip: 'Delete Selected Files',
            ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FileSearchDelegate(_fileNames, _noteControllers),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isGridView ? _buildGridView() : _buildListView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateFileDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _filteredFileNames.length,
      itemBuilder: (context, index) {
        return _buildFileItem(index);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _filteredFileNames.length,
      itemBuilder: (context, index) {
        return _buildFileItem(index);
      },
    );
  }

  Widget _buildFileItem(int index) {
    return GestureDetector(
      onTap: () => _openFileDetails(index),
      onLongPress: () {
        _toggleSelectionMode();
        setState(() {
          _selectedFiles[index] = !_selectedFiles[index];
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(12),
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
                  Expanded(
                    child: Text(
                      '📄 ${_filteredFileNames[index]}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (_isInSelectionMode)
                    IconButton(
                      icon: _selectedFiles[index]
                          ? Icon(Icons.check_circle, color: Colors.blue)
                          : Icon(Icons.radio_button_unchecked, color: Colors.grey),
                      onPressed: () => _toggleSelection(index),
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
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  index < _filteredNoteControllers.length && _filteredNoteControllers[index].text.isNotEmpty
                      ? _filteredNoteControllers[index].text.split("\n").take(2).join("\n")
                      : 'No content...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FileSearchDelegate extends SearchDelegate {
  final List<String> fileNames;
  final List<TextEditingController> noteControllers;

  FileSearchDelegate(this.fileNames, this.noteControllers);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clears the query
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Closes the search
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Only show results when the query is not empty
    if (query.isEmpty) {
      return Center(child: Text('Start typing to search files'));
    }

    // Filter the file names based on the search query
    List<String> filteredFileNames = fileNames
        .where((fileName) => fileName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    List<TextEditingController> filteredNoteControllers = filteredFileNames.map((fileName) {
      int index = fileNames.indexOf(fileName);
      return noteControllers[index];
    }).toList();

    // If no results match the query, show a "No results" message
    if (filteredFileNames.isEmpty) {
      return Center(child: Text('No results found'));
    }

    return _buildFileListView(filteredFileNames, filteredNoteControllers);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Only show suggestions when the query is not empty
    if (query.isEmpty) {
      return Center(child: Text('Start typing to search files'));
    }

    // Filter the file names based on the search query
    List<String> filteredFileNames = fileNames
        .where((fileName) => fileName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    List<TextEditingController> filteredNoteControllers = filteredFileNames.map((fileName) {
      int index = fileNames.indexOf(fileName);
      return noteControllers[index];
    }).toList();

    // If no results match the query, show a "No results" message
    if (filteredFileNames.isEmpty) {
      return Center(child: Text('No results found'));
    }

    return _buildFileListView(filteredFileNames, filteredNoteControllers);
  }

  Widget _buildFileListView(List<String> filteredFileNames, List<TextEditingController> filteredNoteControllers) {
    // Display a list of filtered file names based on search query
    return ListView.builder(
      itemCount: filteredFileNames.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredFileNames[index]),
          subtitle: Text(
            filteredNoteControllers[index].text.isEmpty
                ? 'No content...'
                : filteredNoteControllers[index].text.split("\n").take(2).join("\n"),
          ),
          onTap: () {
            // Open file details or edit
            print('Opening file: ${filteredFileNames[index]}');
          },
        );
      },
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
        TextEditingController newFileController = TextEditingController(text: fileContent);
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
                    TextEditingController newFileController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName), // Display the original file name in the AppBar
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
                    // Save changes as they are made
                    _saveData();
                  },
                ),
                // Dynamically created new file content TextFields below the original one
                ...List.generate(fileNames.length, (index) {
                  // Check if the number of controllers is less than the fileNames length
                  // This will prevent the index error by making sure we don't access invalid indexes
                  if (index < newFileControllers.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display file name as a label
                          Text(
                            'File: ${fileNames[index]}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // TextField for new file content
                          TextField(
                            controller: newFileControllers[index], // Each new file gets its own controller
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              // labelText: 'New File Content',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (text) {
                              // Save changes as they are made
                              _saveData();
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox.shrink(); // Return an empty widget if something goes wrong
                  }
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



