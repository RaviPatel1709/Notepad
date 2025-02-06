// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//   }
//
//   Future<void> _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     setState(() {
//       _fileNames = savedFileNames;
//       _noteControllers = savedFileContents
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(savedFileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(savedFileNames.length, (_) => false);
//     });
//
//     // Add listener to update preview instantly
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {}); // Update the UI on text change
//       });
//     }
//   }
//
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//     _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     _fileNames.add(newFileName);
//                     TextEditingController newController =
//                     TextEditingController();
//                     newController.addListener(() {
//                       setState(() {}); // Instant preview update
//                     });
//
//                     _noteControllers.add(newController);
//                     _focusNodes.add(FocusNode());
//                     _selectedFiles.add(false);
//                   }
//                 });
//
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openFileDetails(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _fileNames[index],
//           noteController: _noteControllers[index],
//         ),
//       ),
//     );
//   }
//
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//     });
//   }
//
//   Future<void> _deleteSelectedFiles() async {
//     setState(() {
//       for (int i = _selectedFiles.length - 1; i >= 0; i--) {
//         if (_selectedFiles[i]) {
//           _fileNames.removeAt(i);
//           _noteControllers.removeAt(i);
//           _focusNodes.removeAt(i);
//           _selectedFiles.removeAt(i);
//         }
//       }
//       _isInSelectionMode = false;
//     });
//
//     _saveAllNotes();
//   }
//
//   void _updateFileName(int index, String newName) {
//     setState(() {
//       _fileNames[index] = newName;
//     });
//     _saveAllNotes();
//   }
//
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//     TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _updateFileName(index, _fileNameController.text);
//                 });
//
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       if (!_isInSelectionMode) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _saveAllNotes();
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Notepad"),
//         actions: [
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             if (_fileNames.isNotEmpty)
//               ..._fileNames.asMap().map((index, fileName) {
//                 return MapEntry(
//                   index,
//                   GestureDetector(
//                     onTap: () {
//                       _openFileDetails(index);
//                     },
//                     onLongPress: () {
//                       _toggleSelectionMode();
//                       setState(() {
//                         _selectedFiles[index] = !_selectedFiles[index];
//                       });
//                     },
//                     child: Container(
//                       padding: EdgeInsets.all(8),
//                       margin: EdgeInsets.symmetric(vertical: 6),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   'File: $fileName',
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                               if (_isInSelectionMode)
//                                 IconButton(
//                                   icon: Icon(
//                                     _selectedFiles[index]
//                                         ? Icons.check_circle
//                                         : Icons.radio_button_unchecked,
//                                     color: _selectedFiles[index]
//                                         ? Colors.blue
//                                         : null,
//                                   ),
//                                   onPressed: () => _toggleSelection(index),
//                                 ),
//                               PopupMenuButton<String>(
//                                 onSelected: (value) {
//                                   if (value == 'Edit') {
//                                     _showEditFileNameDialog(index);
//                                   }
//                                 },
//                                 itemBuilder: (BuildContext context) => [
//                                   PopupMenuItem(
//                                     value: 'Edit',
//                                     child: Row(
//                                       children: [
//                                         Icon(Icons.edit),
//                                         SizedBox(width: 10),
//                                         Text('Edit'),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                                 child: Icon(Icons.settings),
//                               ),
//                             ],
//                           ),
//                           Container(
//                             height: 60,
//                             color: Colors.grey[200],
//                             padding: EdgeInsets.symmetric(horizontal: 10),
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               _noteControllers[index].text.isNotEmpty
//                                   ? _noteControllers[index]
//                                   .text
//                                   .split("\n")
//                                   .take(2)
//                                   .join("\n") // Show only first 2 lines
//                                   : ' ',
//                               style: TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.w600),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }).values.toList(),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatelessWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(fileName), // Display the file name in the AppBar
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: TextField(
//           controller: noteController,
//           maxLines: 10,
//           decoration: InputDecoration(
//             labelText: 'Edit your note',
//             border: OutlineInputBorder(),
//           ),
//           onChanged: (text) {
//             // Optionally save changes here
//           },
//         ),
//       ),
//     );
//   }
// }
//
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//   }
//
//   Future<void> _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     setState(() {
//       _fileNames = savedFileNames;
//       _noteControllers = savedFileContents
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(savedFileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(savedFileNames.length, (_) => false);
//     });
//
//     // Add listener to update preview instantly
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {}); // Update the UI on text change
//       });
//     }
//   }
//
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//     _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     _fileNames.add(newFileName);
//                     TextEditingController newController =
//                     TextEditingController();
//                     newController.addListener(() {
//                       setState(() {}); // Instant preview update
//                     });
//
//                     _noteControllers.add(newController);
//                     _focusNodes.add(FocusNode());
//                     _selectedFiles.add(false);
//                   }
//                 });
//
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openFileDetails(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _fileNames[index],
//           noteController: _noteControllers[index],
//         ),
//       ),
//     );
//   }
//
//   // void _openFileDetails(int index) {
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => FileDetailScreen(
//   //         fileName: _fileNames[index],
//   //         noteController: _noteControllers[index],
//   //         index: index,  // Pass index of the file being edited
//   //       ),
//   //     ),
//   //   ).then((updatedFile) {
//   //     if (updatedFile != null) {
//   //       setState(() {
//   //         _fileNames[index] = updatedFile['name'];
//   //         _noteControllers[index].text = updatedFile['content'];
//   //       });
//   //       _saveAllNotes();
//   //     }
//   //   });
//   // }
//
//   // void _toggleSelection(int index) {
//   //   setState(() {
//   //     _selectedFiles[index] = !_selectedFiles[index];
//   //   });
//   // }
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//
//       // Check if any file is still selected
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//
//   Future<void> _deleteSelectedFiles() async {
//     setState(() {
//       for (int i = _selectedFiles.length - 1; i >= 0; i--) {
//         if (_selectedFiles[i]) {
//           _fileNames.removeAt(i);
//           _noteControllers.removeAt(i);
//           _focusNodes.removeAt(i);
//           _selectedFiles.removeAt(i);
//         }
//       }
//       _isInSelectionMode = false;
//     });
//
//     _saveAllNotes();
//   }
//
//   void _updateFileName(int index, String newName) {
//     setState(() {
//       _fileNames[index] = newName;
//     });
//     _saveAllNotes();
//   }
//
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//     TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _updateFileName(index, _fileNameController.text);
//                 });
//
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       if (!_isInSelectionMode) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _saveAllNotes();
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Notepad"),
//         actions: [
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             if (_fileNames.isNotEmpty)
//               ..._fileNames.asMap().map((index, fileName) {
//                 // Check if index is valid for all lists
//                 if (index < _noteControllers.length && index < _selectedFiles.length) {
//                   return MapEntry(
//                     index,
//                     GestureDetector(
//                       onTap: () {
//                         _openFileDetails(index);
//                       },
//                       onLongPress: () {
//                         _toggleSelectionMode();
//                         setState(() {
//                           _selectedFiles[index] = !_selectedFiles[index];
//                         });
//                       },
//                       child: AnimatedContainer(
//                         duration: Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                         padding: EdgeInsets.all(12),
//                         margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//                         decoration: BoxDecoration(
//                           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//                           border: Border.all(
//                             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//                             width: 2,
//                           ),
//                           borderRadius: BorderRadius.circular(15),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 8,
//                               offset: Offset(2, 4),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Row(
//                                     children: [
//                                       Text(
//                                         '📄',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                       SizedBox(width: 10),
//                                       Text(
//                                         '$fileName',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 if (_isInSelectionMode)
//                                   IconButton(
//                                     icon: AnimatedSwitcher(
//                                       duration: Duration(milliseconds: 300),
//                                       child: _selectedFiles[index]
//                                           ? Icon(Icons.check_circle, color: Colors.blue, key: ValueKey(1))
//                                           : Icon(Icons.radio_button_unchecked, color: Colors.grey, key: ValueKey(2)),
//                                     ),
//                                     onPressed: () => _toggleSelection(index),
//                                   ),
//                                 PopupMenuButton<String>(
//                                   onSelected: (value) {
//                                     if (value == 'Edit') {
//                                       _showEditFileNameDialog(index);
//                                     }
//                                   },
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   itemBuilder: (BuildContext context) => [
//                                     PopupMenuItem(
//                                       value: 'Edit',
//                                       child: Row(
//                                         children: [
//                                           Icon(Icons.edit, color: Colors.blue),
//                                           SizedBox(width: 10),
//                                           Text('Edit'),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                   child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                                 ),
//                               ],
//                             ),
//                             Container(
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[100],
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                               child: Text(
//                                 _noteControllers[index].text.isNotEmpty
//                                     ? _noteControllers[index]
//                                     .text
//                                     .split("\n")
//                                     .take(2)
//                                     .join("\n")
//                                     : 'No content...',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey.shade800,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 } else {
//                   // If the index is out of range, return an empty container or handle it however you'd like
//                   return MapEntry(index, Container());
//                 }
//               }).values.toList(),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
//
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   // List to store controllers for each new file's content
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = []; // List to store new file names
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData(); // Call this in didChangeDependencies to reload data when screen is revisited
//   }
//
//   // Load data from SharedPreferences when the screen is opened
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files (if any) specific to this file
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     newFileControllers.clear(); // Clear the old list to prevent duplicates
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController = TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//       }
//     }
//
//     setState(() {}); // Trigger a rebuild after loading data
//   }
//
//   // Save data to SharedPreferences when text changes
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Save the original note
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     // Save new files
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     // Save file names list specific to this file context
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   // Show create file dialog and save new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Add the new file name to the list specific to this file
//                     fileNames.add(newFileName);
//
//                     // Create a new controller for the new file's content
//                     TextEditingController newFileController = TextEditingController();
//                     newFileControllers.add(newFileController);
//                   }
//                 });
//
//                 // Save all data to SharedPreferences, specific to this file
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileName), // Display the original file name in the AppBar
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // The original file's note (TextField for the initial file)
//                 TextField(
//                   controller: widget.noteController,
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     labelText: 'Edit your note',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (text) {
//                     // Save changes as they are made
//                     _saveData();
//                   },
//                 ),
//                 // Dynamically created new file content TextFields below the original one
//                 ...List.generate(fileNames.length, (index) {
//                   // Check if the number of controllers is less than the fileNames length
//                   // This will prevent the index error by making sure we don't access invalid indexes
//                   if (index < newFileControllers.length) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Display file name as a label
//                           Text(
//                             'File: ${fileNames[index]}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           // TextField for new file content
//                           TextField(
//                             controller: newFileControllers[index], // Each new file gets its own controller
//                             maxLines: null,
//                             keyboardType: TextInputType.multiline,
//                             decoration: InputDecoration(
//                               // labelText: 'New File Content',
//                               border: OutlineInputBorder(),
//                             ),
//                             onChanged: (text) {
//                               // Save changes as they are made
//                               _saveData();
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return SizedBox.shrink(); // Return an empty widget if something goes wrong
//                   }
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
//
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//   }
//
//   Future<void> _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     setState(() {
//       _fileNames = savedFileNames;
//       _noteControllers = savedFileContents
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(savedFileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(savedFileNames.length, (_) => false);
//     });
//
//     // Add listener to update preview instantly
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {}); // Update the UI on text change
//       });
//     }
//   }
//
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//     _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 String newFileName = _fileNameController.text.trim(); // Get the file name entered
//
//                 if (newFileName.isNotEmpty) {
//                   setState(() {
//                     _fileNames.add(newFileName); // Add the entered file name
//                     TextEditingController newController = TextEditingController();
//                     newController.addListener(() {
//                       setState(() {}); // Instant preview update
//                     });
//
//                     _noteControllers.add(newController); // Add a new controller for the new file
//                     _focusNodes.add(FocusNode()); // Add a new focus node for the new file
//                     _selectedFiles.add(false); // Initially not selected
//                   });
//
//                   _saveAllNotes(); // Save the new file list and content
//                   Navigator.of(context).pop(); // Close the dialog
//                 }
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openFileDetails(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _fileNames[index],
//           noteController: _noteControllers[index],
//         ),
//       ),
//     );
//   }
//
//   // void _openFileDetails(int index) {
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => FileDetailScreen(
//   //         fileName: _fileNames[index],
//   //         noteController: _noteControllers[index],
//   //         index: index,  // Pass index of the file being edited
//   //       ),
//   //     ),
//   //   ).then((updatedFile) {
//   //     if (updatedFile != null) {
//   //       setState(() {
//   //         _fileNames[index] = updatedFile['name'];
//   //         _noteControllers[index].text = updatedFile['content'];
//   //       });
//   //       _saveAllNotes();
//   //     }
//   //   });
//   // }
//
//   // void _toggleSelection(int index) {
//   //   setState(() {
//   //     _selectedFiles[index] = !_selectedFiles[index];
//   //   });
//   // }
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//
//       // Check if any file is still selected
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//
//   Future<void> _deleteSelectedFiles() async {
//     setState(() {
//       for (int i = _selectedFiles.length - 1; i >= 0; i--) {
//         if (_selectedFiles[i]) {
//           _fileNames.removeAt(i);
//           _noteControllers.removeAt(i);
//           _focusNodes.removeAt(i);
//           _selectedFiles.removeAt(i);
//         }
//       }
//       _isInSelectionMode = false;
//     });
//
//     _saveAllNotes();
//   }
//
//   void _updateFileName(int index, String newName) {
//     setState(() {
//       _fileNames[index] = newName;
//     });
//     _saveAllNotes();
//   }
//
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//     TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _updateFileName(index, _fileNameController.text);
//                 });
//
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       if (!_isInSelectionMode) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _saveAllNotes();
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Notepad"),
//         actions: [
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             if (_fileNames.isNotEmpty)
//               ..._fileNames.asMap().map((index, fileName) {
//                 // Check if index is valid for all lists
//                 if (index < _noteControllers.length && index < _selectedFiles.length) {
//                   return MapEntry(
//                     index,
//                     GestureDetector(
//                       onTap: () {
//                         _openFileDetails(index);
//                       },
//                       onLongPress: () {
//                         _toggleSelectionMode();
//                         setState(() {
//                           _selectedFiles[index] = !_selectedFiles[index];
//                         });
//                       },
//                       child: AnimatedContainer(
//                         duration: Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                         padding: EdgeInsets.all(12),
//                         margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//                         decoration: BoxDecoration(
//                           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//                           border: Border.all(
//                             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//                             width: 2,
//                           ),
//                           borderRadius: BorderRadius.circular(15),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 8,
//                               offset: Offset(2, 4),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Row(
//                                     children: [
//                                       Text(
//                                         '📄',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                       SizedBox(width: 10),
//                                       Text(
//                                         '$fileName',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 if (_isInSelectionMode)
//                                   IconButton(
//                                     icon: AnimatedSwitcher(
//                                       duration: Duration(milliseconds: 300),
//                                       child: _selectedFiles[index]
//                                           ? Icon(Icons.check_circle, color: Colors.blue, key: ValueKey(1))
//                                           : Icon(Icons.radio_button_unchecked, color: Colors.grey, key: ValueKey(2)),
//                                     ),
//                                     onPressed: () => _toggleSelection(index),
//                                   ),
//                                 PopupMenuButton<String>(
//                                   onSelected: (value) {
//                                     if (value == 'Edit') {
//                                       _showEditFileNameDialog(index);
//                                     }
//                                   },
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   itemBuilder: (BuildContext context) => [
//                                     PopupMenuItem(
//                                       value: 'Edit',
//                                       child: Row(
//                                         children: [
//                                           Icon(Icons.edit, color: Colors.blue),
//                                           SizedBox(width: 10),
//                                           Text('Edit'),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                   child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                                 ),
//                               ],
//                             ),
//                             Container(
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[100],
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                               child: Text(
//                                 _noteControllers[index].text.isNotEmpty
//                                     ? _noteControllers[index]
//                                     .text
//                                     .split("\n")
//                                     .take(2)
//                                     .join("\n")
//                                     : 'No content...',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey.shade800,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 } else {
//                   // If the index is out of range, return an empty container or handle it however you'd like
//                   return MapEntry(index, Container());
//                 }
//               }).values.toList(),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
//
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   // List to store controllers for each new file's content
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = []; // List to store new file names
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData(); // Call this in didChangeDependencies to reload data when screen is revisited
//   }
//
//   // Load data from SharedPreferences when the screen is opened
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files (if any) specific to this file
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     newFileControllers.clear(); // Clear the old list to prevent duplicates
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController = TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//       }
//     }
//
//     setState(() {}); // Trigger a rebuild after loading data
//   }
//
//   // Save data to SharedPreferences when text changes
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Save the original note
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     // Save new files
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     // Save file names list specific to this file context
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   // Show create file dialog and save new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Add the new file name to the list specific to this file
//                     fileNames.add(newFileName);
//
//                     // Create a new controller for the new file's content
//                     TextEditingController newFileController = TextEditingController();
//                     newFileControllers.add(newFileController);
//                   }
//                 });
//
//                 // Save all data to SharedPreferences, specific to this file
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileName), // Display the original file name in the AppBar
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // The original file's note (TextField for the initial file)
//                 TextField(
//                   controller: widget.noteController,
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     labelText: 'Edit your note',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (text) {
//                     // Save changes as they are made
//                     _saveData();
//                   },
//                 ),
//                 // Dynamically created new file content TextFields below the original one
//                 ...List.generate(fileNames.length, (index) {
//                   // Check if the number of controllers is less than the fileNames length
//                   // This will prevent the index error by making sure we don't access invalid indexes
//                   if (index < newFileControllers.length) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Display file name as a label
//                           Text(
//                             'File: ${fileNames[index]}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           // TextField for new file content
//                           TextField(
//                             controller: newFileControllers[index], // Each new file gets its own controller
//                             maxLines: null,
//                             keyboardType: TextInputType.multiline,
//                             decoration: InputDecoration(
//                               // labelText: 'New File Content',
//                               border: OutlineInputBorder(),
//                             ),
//                             onChanged: (text) {
//                               // Save changes as they are made
//                               _saveData();
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return SizedBox.shrink(); // Return an empty widget if something goes wrong
//                   }
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
//
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//   }
//
//   Future<void> _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     setState(() {
//       _fileNames = savedFileNames;
//       _noteControllers = savedFileContents
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(savedFileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(savedFileNames.length, (_) => false);
//     });
//
//     // Add listener to update preview instantly
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {}); // Update the UI on text change
//       });
//     }
//   }
//
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//     _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     _fileNames.add(newFileName);
//                     TextEditingController newController =
//                     TextEditingController();
//                     newController.addListener(() {
//                       setState(() {}); // Instant preview update
//                     });
//
//                     _noteControllers.add(newController);
//                     _focusNodes.add(FocusNode());
//                     _selectedFiles.add(false);
//                   }
//                 });
//
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openFileDetails(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _fileNames[index],
//           noteController: _noteControllers[index],
//         ),
//       ),
//     );
//   }
//
//   // void _openFileDetails(int index) {
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => FileDetailScreen(
//   //         fileName: _fileNames[index],
//   //         noteController: _noteControllers[index],
//   //         index: index,  // Pass index of the file being edited
//   //       ),
//   //     ),
//   //   ).then((updatedFile) {
//   //     if (updatedFile != null) {
//   //       setState(() {
//   //         _fileNames[index] = updatedFile['name'];
//   //         _noteControllers[index].text = updatedFile['content'];
//   //       });
//   //       _saveAllNotes();
//   //     }
//   //   });
//   // }
//
//   // void _toggleSelection(int index) {
//   //   setState(() {
//   //     _selectedFiles[index] = !_selectedFiles[index];
//   //   });
//   // }
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//
//       // Check if any file is still selected
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//
//   Future<void> _deleteSelectedFiles() async {
//     setState(() {
//       for (int i = _selectedFiles.length - 1; i >= 0; i--) {
//         if (_selectedFiles[i]) {
//           _fileNames.removeAt(i);
//           _noteControllers.removeAt(i);
//           _focusNodes.removeAt(i);
//           _selectedFiles.removeAt(i);
//         }
//       }
//       _isInSelectionMode = false;
//     });
//
//     _saveAllNotes();
//   }
//
//   void _updateFileName(int index, String newName) {
//     setState(() {
//       _fileNames[index] = newName;
//     });
//     _saveAllNotes();
//   }
//
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//     TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _updateFileName(index, _fileNameController.text);
//                 });
//
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       if (!_isInSelectionMode) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _saveAllNotes();
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Notepad"),
//         actions: [
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             if (_fileNames.isNotEmpty)
//               ..._fileNames.asMap().map((index, fileName) {
//                 // Check if index is valid for all lists
//                 if (index < _noteControllers.length && index < _selectedFiles.length) {
//                   return MapEntry(
//                     index,
//                     GestureDetector(
//                       onTap: () {
//                         _openFileDetails(index);
//                       },
//                       onLongPress: () {
//                         _toggleSelectionMode();
//                         setState(() {
//                           _selectedFiles[index] = !_selectedFiles[index];
//                         });
//                       },
//                       child: AnimatedContainer(
//                         duration: Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                         padding: EdgeInsets.all(12),
//                         margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//                         decoration: BoxDecoration(
//                           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//                           border: Border.all(
//                             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//                             width: 2,
//                           ),
//                           borderRadius: BorderRadius.circular(15),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 8,
//                               offset: Offset(2, 4),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Row(
//                                     children: [
//                                       Text(
//                                         '📄',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                       SizedBox(width: 10),
//                                       Text(
//                                         '$fileName',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 if (_isInSelectionMode)
//                                   IconButton(
//                                     icon: AnimatedSwitcher(
//                                       duration: Duration(milliseconds: 300),
//                                       child: _selectedFiles[index]
//                                           ? Icon(Icons.check_circle, color: Colors.blue, key: ValueKey(1))
//                                           : Icon(Icons.radio_button_unchecked, color: Colors.grey, key: ValueKey(2)),
//                                     ),
//                                     onPressed: () => _toggleSelection(index),
//                                   ),
//                                 PopupMenuButton<String>(
//                                   onSelected: (value) {
//                                     if (value == 'Edit') {
//                                       _showEditFileNameDialog(index);
//                                     }
//                                   },
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   itemBuilder: (BuildContext context) => [
//                                     PopupMenuItem(
//                                       value: 'Edit',
//                                       child: Row(
//                                         children: [
//                                           Icon(Icons.edit, color: Colors.blue),
//                                           SizedBox(width: 10),
//                                           Text('Edit'),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                   child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                                 ),
//                               ],
//                             ),
//                             Container(
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[100],
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                               child: Text(
//                                 _noteControllers[index].text.isNotEmpty
//                                     ? _noteControllers[index]
//                                     .text
//                                     .split("\n")
//                                     .take(2)
//                                     .join("\n")
//                                     : 'No content...',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey.shade800,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 } else {
//                   // If the index is out of range, return an empty container or handle it however you'd like
//                   return MapEntry(index, Container());
//                 }
//               }).values.toList(),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
//
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   // List to store controllers for each new file's content
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = []; // List to store new file names
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData(); // Call this in didChangeDependencies to reload data when screen is revisited
//   }
//
//   // Load data from SharedPreferences when the screen is opened
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files (if any) specific to this file
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     newFileControllers.clear(); // Clear the old list to prevent duplicates
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController = TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//       }
//     }
//
//     setState(() {}); // Trigger a rebuild after loading data
//   }
//
//   // Save data to SharedPreferences when text changes
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Save the original note
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     // Save new files
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     // Save file names list specific to this file context
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   // Show create file dialog and save new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Add the new file name to the list specific to this file
//                     fileNames.add(newFileName);
//
//                     // Create a new controller for the new file's content
//                     TextEditingController newFileController = TextEditingController();
//                     newFileControllers.add(newFileController);
//                   }
//                 });
//
//                 // Save all data to SharedPreferences, specific to this file
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileName), // Display the original file name in the AppBar
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // The original file's note (TextField for the initial file)
//                 TextField(
//                   controller: widget.noteController,
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     labelText: 'Edit your note',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (text) {
//                     // Save changes as they are made
//                     _saveData();
//                   },
//                 ),
//                 // Dynamically created new file content TextFields below the original one
//                 ...List.generate(fileNames.length, (index) {
//                   // Check if the number of controllers is less than the fileNames length
//                   // This will prevent the index error by making sure we don't access invalid indexes
//                   if (index < newFileControllers.length) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Display file name as a label
//                           Text(
//                             'File: ${fileNames[index]}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           // TextField for new file content
//                           TextField(
//                             controller: newFileControllers[index], // Each new file gets its own controller
//                             maxLines: null,
//                             keyboardType: TextInputType.multiline,
//                             decoration: InputDecoration(
//                               // labelText: 'New File Content',
//                               border: OutlineInputBorder(),
//                             ),
//                             onChanged: (text) {
//                               // Save changes as they are made
//                               _saveData();
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return SizedBox.shrink(); // Return an empty widget if something goes wrong
//                   }
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
///perfect
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//   }
//   Future<void> _deleteSelectedFiles() async {
//     setState(() {
//       List<int> toRemove = [];
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         if (_selectedFiles[i]) {
//           toRemove.add(i);
//         }
//       }
//
//       for (int i = toRemove.length - 1; i >= 0; i--) {
//         _fileNames.removeAt(toRemove[i]);
//         _noteControllers.removeAt(toRemove[i]);
//         _focusNodes.removeAt(toRemove[i]);
//         _selectedFiles.removeAt(toRemove[i]);
//       }
//
//       _isInSelectionMode = false;
//     });
//
//     _saveAllNotes();
//   }
//
//   Future<void> _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     // Ensure both lists have the same length
//     int minLength = savedFileNames.length < savedFileContents.length ? savedFileNames.length : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents.take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//     });
//
//     // Add listener to update preview instantly
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {}); // Update the UI on text change
//       });
//     }
//   }
//
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//     _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     _fileNames.add(newFileName);
//                     TextEditingController newController =
//                     TextEditingController();
//                     newController.addListener(() {
//                       setState(() {}); // Instant preview update
//                     });
//
//                     _noteControllers.add(newController);
//                     _focusNodes.add(FocusNode());
//                     _selectedFiles.add(false);
//                   }
//                 });
//
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openFileDetails(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _fileNames[index],
//           noteController: _noteControllers[index],
//         ),
//       ),
//     );
//   }
//
//   // void _toggleSelection(int index) {
//   //   setState(() {
//   //     _selectedFiles[index] = !_selectedFiles[index];
//   //   });
//   // }
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//
//       // Check if any file is still selected
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//
//   // Future<void> _deleteSelectedFiles() async {
//   //   setState(() {
//   //     for (int i = _selectedFiles.length - 1; i >= 0; i--) {
//   //       if (_selectedFiles[i]) {
//   //         _fileNames.removeAt(i);
//   //         _noteControllers.removeAt(i);
//   //         _focusNodes.removeAt(i);
//   //         _selectedFiles.removeAt(i);
//   //       }
//   //     }
//   //     _isInSelectionMode = false;
//   //   });
//   //
//   //   _saveAllNotes();
//   // }
//
//   void _updateFileName(int index, String newName) {
//     setState(() {
//       _fileNames[index] = newName;
//     });
//     _saveAllNotes();
//   }
//
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//     TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _updateFileName(index, _fileNameController.text);
//                 });
//
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       if (!_isInSelectionMode) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _saveAllNotes();
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Notepad"),
//         actions: [
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView.builder(
//           itemCount: _fileNames.length,
//           itemBuilder: (context, index) {
//             return GestureDetector(
//               onTap: () => _openFileDetails(index),
//               onLongPress: () {
//                 _toggleSelectionMode();
//                 setState(() {
//                   _selectedFiles[index] = !_selectedFiles[index];
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//                 padding: EdgeInsets.all(12),
//                 margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//                   border: Border.all(
//                     color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//                     width: 2,
//                   ),
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 8,
//                       offset: Offset(2, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             '📄 ${_fileNames[index]}',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ),
//                         if (_isInSelectionMode)
//                           IconButton(
//                             icon: _selectedFiles[index]
//                                 ? Icon(Icons.check_circle, color: Colors.blue)
//                                 : Icon(Icons.radio_button_unchecked, color: Colors.grey),
//                             onPressed: () => _toggleSelection(index),
//                           ),
//                         PopupMenuButton<String>(
//                           onSelected: (value) {
//                             if (value == 'Edit') {
//                               _showEditFileNameDialog(index);
//                             }
//                           },
//                           itemBuilder: (BuildContext context) => [
//                             PopupMenuItem(
//                               value: 'Edit',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.edit, color: Colors.blue),
//                                   SizedBox(width: 10),
//                                   Text('Edit'),
//                                 ],
//                               ),
//                             ),
//                           ],
//                           child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                         ),
//                       ],
//                     ),
//                     Container(
//                       height: 60,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       child: Text(
//                         index < _noteControllers.length && _noteControllers[index].text.isNotEmpty
//                             ? _noteControllers[index].text.split("\n").take(2).join("\n")
//                             : 'No content...',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.grey.shade800,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatelessWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(fileName), // Display the file name in the AppBar
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: TextField(
//           controller: noteController,
//           maxLines: 10,
//           decoration: InputDecoration(
//             labelText: 'Edit your note',
//             border: OutlineInputBorder(),
//           ),
//           onChanged: (text) {
//             // Optionally save changes here
//           },
//         ),
//       ),
//     );
//   }
// }
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//   }
//   Future<void> _deleteSelectedFiles() async {
//     setState(() {
//       List<int> toRemove = [];
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         if (_selectedFiles[i]) {
//           toRemove.add(i);
//         }
//       }
//
//       for (int i = toRemove.length - 1; i >= 0; i--) {
//         _fileNames.removeAt(toRemove[i]);
//         _noteControllers.removeAt(toRemove[i]);
//         _focusNodes.removeAt(toRemove[i]);
//         _selectedFiles.removeAt(toRemove[i]);
//       }
//
//       _isInSelectionMode = false;
//     });
//
//     _saveAllNotes();
//   }
//
//   Future<void> _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     // Ensure both lists have the same length
//     int minLength = savedFileNames.length < savedFileContents.length ? savedFileNames.length : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents.take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//     });
//
//     // Add listener to update preview instantly
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {}); // Update the UI on text change
//       });
//     }
//   }
//
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//     _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     _fileNames.add(newFileName);
//                     TextEditingController newController =
//                     TextEditingController();
//                     newController.addListener(() {
//                       setState(() {}); // Instant preview update
//                     });
//
//                     _noteControllers.add(newController);
//                     _focusNodes.add(FocusNode());
//                     _selectedFiles.add(false);
//                   }
//                 });
//
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openFileDetails(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _fileNames[index],
//           noteController: _noteControllers[index],
//         ),
//       ),
//     );
//   }
//
//   // void _toggleSelection(int index) {
//   //   setState(() {
//   //     _selectedFiles[index] = !_selectedFiles[index];
//   //   });
//   // }
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//
//       // Check if any file is still selected
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//
//   // Future<void> _deleteSelectedFiles() async {
//   //   setState(() {
//   //     for (int i = _selectedFiles.length - 1; i >= 0; i--) {
//   //       if (_selectedFiles[i]) {
//   //         _fileNames.removeAt(i);
//   //         _noteControllers.removeAt(i);
//   //         _focusNodes.removeAt(i);
//   //         _selectedFiles.removeAt(i);
//   //       }
//   //     }
//   //     _isInSelectionMode = false;
//   //   });
//   //
//   //   _saveAllNotes();
//   // }
//
//   void _updateFileName(int index, String newName) {
//     setState(() {
//       _fileNames[index] = newName;
//     });
//     _saveAllNotes();
//   }
//
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//     TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _updateFileName(index, _fileNameController.text);
//                 });
//
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       if (!_isInSelectionMode) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _saveAllNotes();
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Notepad"),
//         actions: [
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView.builder(
//           itemCount: _fileNames.length,
//           itemBuilder: (context, index) {
//             return GestureDetector(
//               onTap: () => _openFileDetails(index),
//               onLongPress: () {
//                 _toggleSelectionMode();
//                 setState(() {
//                   _selectedFiles[index] = !_selectedFiles[index];
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//                 padding: EdgeInsets.all(12),
//                 margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//                   border: Border.all(
//                     color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//                     width: 2,
//                   ),
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 8,
//                       offset: Offset(2, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             '📄 ${_fileNames[index]}',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ),
//                         if (_isInSelectionMode)
//                           IconButton(
//                             icon: _selectedFiles[index]
//                                 ? Icon(Icons.check_circle, color: Colors.blue)
//                                 : Icon(Icons.radio_button_unchecked, color: Colors.grey),
//                             onPressed: () => _toggleSelection(index),
//                           ),
//                         PopupMenuButton<String>(
//                           onSelected: (value) {
//                             if (value == 'Edit') {
//                               _showEditFileNameDialog(index);
//                             }
//                           },
//                           itemBuilder: (BuildContext context) => [
//                             PopupMenuItem(
//                               value: 'Edit',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.edit, color: Colors.blue),
//                                   SizedBox(width: 10),
//                                   Text('Edit'),
//                                 ],
//                               ),
//                             ),
//                           ],
//                           child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                         ),
//                       ],
//                     ),
//                     Container(
//                       height: 60,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       child: Text(
//                         index < _noteControllers.length && _noteControllers[index].text.isNotEmpty
//                             ? _noteControllers[index].text.split("\n").take(2).join("\n")
//                             : 'No content...',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.grey.shade800,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   // List to store controllers for each new file's content
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = []; // List to store new file names
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData(); // Call this in didChangeDependencies to reload data when screen is revisited
//   }
//
//   // Load data from SharedPreferences when the screen is opened
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files (if any) specific to this file
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     newFileControllers.clear(); // Clear the old list to prevent duplicates
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController = TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//       }
//     }
//
//     setState(() {}); // Trigger a rebuild after loading data
//   }
//
//   // Save data to SharedPreferences when text changes
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Save the original note
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     // Save new files
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     // Save file names list specific to this file context
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   // Show create file dialog and save new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Add the new file name to the list specific to this file
//                     fileNames.add(newFileName);
//
//                     // Create a new controller for the new file's content
//                     TextEditingController newFileController = TextEditingController();
//                     newFileControllers.add(newFileController);
//                   }
//                 });
//
//                 // Save all data to SharedPreferences, specific to this file
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileName), // Display the original file name in the AppBar
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // The original file's note (TextField for the initial file)
//                 TextField(
//                   controller: widget.noteController,
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     labelText: 'Edit your note',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (text) {
//                     // Save changes as they are made
//                     _saveData();
//                   },
//                 ),
//                 // Dynamically created new file content TextFields below the original one
//                 ...List.generate(fileNames.length, (index) {
//                   // Check if the number of controllers is less than the fileNames length
//                   // This will prevent the index error by making sure we don't access invalid indexes
//                   if (index < newFileControllers.length) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Display file name as a label
//                           Text(
//                             'File: ${fileNames[index]}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           // TextField for new file content
//                           TextField(
//                             controller: newFileControllers[index], // Each new file gets its own controller
//                             maxLines: null,
//                             keyboardType: TextInputType.multiline,
//                             decoration: InputDecoration(
//                               // labelText: 'New File Content',
//                               border: OutlineInputBorder(),
//                             ),
//                             onChanged: (text) {
//                               // Save changes as they are made
//                               _saveData();
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return SizedBox.shrink(); // Return an empty widget if something goes wrong
//                   }
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
///c
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//   bool _isGridView = false;
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   void _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     int minLength = savedFileNames.length < savedFileContents.length ? savedFileNames.length : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents.take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//       _filteredFileNames = List.from(_fileNames);
//       _filteredNoteControllers = List.from(_noteControllers);
//     });
//
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {});
//       });
//     }
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = List.from(_fileNames);
//         _filteredNoteControllers = List.from(_noteControllers);
//       } else {
//         _filteredFileNames = _fileNames.where((fileName) => fileName.toLowerCase().contains(query.toLowerCase())).toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = _fileNames.indexOf(fileName);
//           return _noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   Future<void> _deleteSelectedFiles() async {
//     setState(() {
//       List<int> toRemove = [];
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         if (_selectedFiles[i]) {
//           toRemove.add(i);
//         }
//       }
//
//       for (int i = toRemove.length - 1; i >= 0; i--) {
//         _fileNames.removeAt(toRemove[i]);
//         _noteControllers.removeAt(toRemove[i]);
//         _focusNodes.removeAt(toRemove[i]);
//         _selectedFiles.removeAt(toRemove[i]);
//       }
//
//       _isInSelectionMode = false;
//     });
//
//     _saveAllNotes();
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     _fileNames.add(newFileName);
//                     TextEditingController newController = TextEditingController();
//                     newController.addListener(() {
//                       setState(() {});
//                     });
//
//                     _noteControllers.add(newController);
//                     _focusNodes.add(FocusNode());
//                     _selectedFiles.add(false);
//                   }
//                 });
//
//                 _filterFiles(_searchController.text); // Re-filter after adding a new file
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//     _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController = TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _fileNames[index] = _fileNameController.text;
//                 });
//
//                 _filterFiles(_searchController.text); // Re-filter after editing the file name
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openFileDetails(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _filteredFileNames[index],
//           noteController: _filteredNoteControllers[index],
//         ),
//       ),
//     ).then((_) {
//       // Clear search query after returning from file details
//       setState(() {
//         _searchController.clear();
//         _filterFiles(""); // Reset filtered list
//       });
//     });
//   }
//
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       if (!_isInSelectionMode) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//   String _searchQuery = "";
//   void _toggleView() {
//     setState(() {
//       _isGridView = !_isGridView;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Notepad"),
//         actions: [
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: IconButton(
//                 icon: Icon(Icons.search),
//                 onPressed: () async {
//                   final selectedFile = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => SearchScreen(
//                         fileNames: _fileNames,
//                         noteControllers: _noteControllers,
//                       ),
//                     ),
//                   );
//
//                   if (selectedFile != null) {
//                     int index = _fileNames.indexOf(selectedFile);
//                     _openFileDetails(index);
//                   }
//                 },
//               ),
//
//             ),
//           ),
//           IconButton(
//             icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
//             onPressed: _toggleView,
//             tooltip: 'Toggle View',
//           ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _isGridView ? _buildGridView() : _buildListView(),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
//
//   Widget _buildListView() {
//     return ListView.builder(
//       itemCount: _filteredFileNames.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(index);
//       },
//     );
//   }
//
//   Widget _buildGridView() {
//     List<int> sortedIndexes = List.generate(_fileNames.length, (index) => index);
//     if (_searchQuery.isNotEmpty) {
//       sortedIndexes.sort((a, b) {
//         bool aMatches = _fileNames[a].toLowerCase().contains(_searchQuery.toLowerCase());
//         bool bMatches = _fileNames[b].toLowerCase().contains(_searchQuery.toLowerCase());
//         return (bMatches ? 1 : 0) - (aMatches ? 1 : 0);
//       });
//     }
//
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 2.5,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onTap: () => _openFileDetails(index),
//       onLongPress: () {
//         _toggleSelectionMode();
//         setState(() {
//           _selectedFiles[index] = !_selectedFiles[index];
//         });
//       },
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       '📄 ${_filteredFileNames[index]}',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                   if (_isInSelectionMode)
//                     IconButton(
//                       icon: _selectedFiles[index]
//                           ? Icon(Icons.check_circle, color: Colors.blue)
//                           : Icon(Icons.radio_button_unchecked, color: Colors.grey),
//                       onPressed: () => _toggleSelection(index),
//                     ),
//                   PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'Edit') {
//                         _showEditFileNameDialog(index);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => [
//                       PopupMenuItem(
//                         value: 'Edit',
//                         child: Row(
//                           children: [
//                             Icon(Icons.edit, color: Colors.blue),
//                             SizedBox(width: 10),
//                             Text('Edit'),
//                           ],
//                         ),
//                       ),
//                     ],
//                     child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                   ),
//                 ],
//               ),
//               Container(
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: Text(
//                   index < _filteredNoteControllers.length && _filteredNoteControllers[index].text.isNotEmpty
//                       ? _filteredNoteControllers[index].text.split("\n").take(2).join("\n")
//                       : 'No content...',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey.shade800,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 2,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SearchScreen extends StatefulWidget {
//   final List<String> fileNames;
//   final List<TextEditingController> noteControllers;
//
//   SearchScreen({required this.fileNames, required this.noteControllers});
//
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//       } else {
//         _filteredFileNames = widget.fileNames
//             .where((fileName) => fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = widget.fileNames.indexOf(fileName);
//           return widget.noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           controller: _searchController,
//           decoration: InputDecoration(
//             hintText: "Search files...",
//             border: InputBorder.none,
//           ),
//         ),
//       ),
//       body: _filteredFileNames.isEmpty
//           ? Center(
//         child: Text(
//           "Search for files...",
//           style: TextStyle(fontSize: 18, color: Colors.grey),
//         ),
//       )
//           : ListView.builder(
//         itemCount: _filteredFileNames.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(_filteredFileNames[index]),
//             subtitle: Text(
//               _filteredNoteControllers[index].text.isNotEmpty
//                   ? _filteredNoteControllers[index].text.split("\n").take(2).join("\n")
//                   : "No content...",
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             onTap: () {
//               Navigator.pop(context, _filteredFileNames[index]);
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   // List to store controllers for each new file's content
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = []; // List to store new file names
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData(); // Call this in didChangeDependencies to reload data when screen is revisited
//   }
//
//   // Load data from SharedPreferences when the screen is opened
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files (if any) specific to this file
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     newFileControllers.clear(); // Clear the old list to prevent duplicates
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController = TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//       }
//     }
//
//     setState(() {}); // Trigger a rebuild after loading data
//   }
//
//   // Save data to SharedPreferences when text changes
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Save the original note
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     // Save new files
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     // Save file names list specific to this file context
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   // Show create file dialog and save new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Add the new file name to the list specific to this file
//                     fileNames.add(newFileName);
//
//                     // Create a new controller for the new file's content
//                     TextEditingController newFileController = TextEditingController();
//                     newFileControllers.add(newFileController);
//                   }
//                 });
//
//                 // Save all data to SharedPreferences, specific to this file
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileName), // Display the original file name in the AppBar
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // The original file's note (TextField for the initial file)
//                 TextField(
//                   controller: widget.noteController,
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     labelText: 'Edit your note',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (text) {
//                     // Save changes as they are made
//                     _saveData();
//                   },
//                 ),
//                 // Dynamically created new file content TextFields below the original one
//                 ...List.generate(fileNames.length, (index) {
//                   // Check if the number of controllers is less than the fileNames length
//                   // This will prevent the index error by making sure we don't access invalid indexes
//                   if (index < newFileControllers.length) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Display file name as a label
//                           Text(
//                             'File: ${fileNames[index]}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           // TextField for new file content
//                           TextField(
//                             controller: newFileControllers[index], // Each new file gets its own controller
//                             maxLines: null,
//                             keyboardType: TextInputType.multiline,
//                             decoration: InputDecoration(
//                               // labelText: 'New File Content',
//                               border: OutlineInputBorder(),
//                             ),
//                             onChanged: (text) {
//                               // Save changes as they are made
//                               _saveData();
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return SizedBox.shrink(); // Return an empty widget if something goes wrong
//                   }
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
//
//
//
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//   bool _isGridView = false;
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   void _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     int minLength = savedFileNames.length < savedFileContents.length ? savedFileNames.length : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents.take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//       _filteredFileNames = List.from(_fileNames);
//       _filteredNoteControllers = List.from(_noteControllers);
//     });
//
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {});
//       });
//     }
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = List.from(_fileNames);
//         _filteredNoteControllers = List.from(_noteControllers);
//       } else {
//         _filteredFileNames = _fileNames.where((fileName) => fileName.toLowerCase().contains(query.toLowerCase())).toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = _fileNames.indexOf(fileName);
//           return _noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   Future<void> _deleteSelectedFiles() async {
//     setState(() {
//       List<int> toRemove = [];
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         if (_selectedFiles[i]) {
//           toRemove.add(i);
//         }
//       }
//
//       for (int i = toRemove.length - 1; i >= 0; i--) {
//         _fileNames.removeAt(toRemove[i]);
//         _noteControllers.removeAt(toRemove[i]);
//         _focusNodes.removeAt(toRemove[i]);
//         _selectedFiles.removeAt(toRemove[i]);
//       }
//
//       _isInSelectionMode = false;
//     });
//
//     _saveAllNotes();
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     _fileNames.insert(0, newFileName);
//                     TextEditingController newController = TextEditingController();
//                     newController.addListener(() {
//                       setState(() {});
//                     });
//
//                     _noteControllers.insert(0, newController);
//                     _focusNodes.insert(0, FocusNode());
//                     _selectedFiles.insert(0, false);
//                   }
//                 });
//
//                 _filterFiles(_searchController.text); // Re-filter after adding a new file
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//     _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController = TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _fileNames[index] = _fileNameController.text;
//                 });
//
//                 _filterFiles(_searchController.text); // Re-filter after editing the file name
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openFileDetails(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _filteredFileNames[index],
//           noteController: _filteredNoteControllers[index],
//         ),
//       ),
//     ).then((_) {
//       // Clear search query after returning from file details
//       setState(() {
//         _searchController.clear();
//         _filterFiles(""); // Reset filtered list
//       });
//     });
//   }
//
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       if (!_isInSelectionMode) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   String _getTrimmedText(String text) {
//     const maxLength = 13; // Maximum characters before truncating
//     if (text.length > maxLength) {
//       return text.substring(0, maxLength) + '...'; // Append ellipsis if text is too long
//     } else {
//       return text; // Return full text if it's within limit
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//   String _searchQuery = "";
//   void _toggleView() {
//     setState(() {
//       _isGridView = !_isGridView;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 4,
//         shadowColor: Colors.black26,
//         title: Text(
//           "Notepad",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.blueAccent, size: 28),
//             onPressed: () async {
//               final selectedFile = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchScreen(
//                     fileNames: _fileNames,
//                     noteControllers: _noteControllers,
//                   ),
//                 ),
//               );
//
//               if (selectedFile != null) {
//                 int index = _fileNames.indexOf(selectedFile);
//                 _openFileDetails(index);
//               }
//             },
//             tooltip: "Search Notes",
//           ),
//           IconButton(
//             icon: Icon(
//               _isGridView ? Icons.view_list : Icons.grid_view,
//               color: Colors.blueAccent,
//               size: 28,
//             ),
//             onPressed: _toggleView,
//             tooltip: 'Toggle View',
//           ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//           SizedBox(width: 10), // Extra spacing for better UI
//         ],
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _isGridView ? _buildGridView() : _buildListView(),
//       ),
//       floatingActionButton:FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         backgroundColor: Colors.blueAccent,
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: AnimatedSwitcher(
//           duration: Duration(milliseconds: 400),
//           transitionBuilder: (child, animation) => ScaleTransition(
//             scale: animation,
//             child: child,
//           ),
//           child: Icon(
//             Icons.add,
//             key: ValueKey<int>(1),
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//
//
//     );
//   }
//
//   Widget _buildListView() {
//     return ListView.builder(
//       itemCount: _filteredFileNames.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(index);
//       },
//     );
//   }
//
//   Widget _buildGridView() {
//     List<int> sortedIndexes = List.generate(_fileNames.length, (index) => index);
//     if (_searchQuery.isNotEmpty) {
//       sortedIndexes.sort((a, b) {
//         bool aMatches = _fileNames[a].toLowerCase().contains(_searchQuery.toLowerCase());
//         bool bMatches = _fileNames[b].toLowerCase().contains(_searchQuery.toLowerCase());
//         return (bMatches ? 1 : 0) - (aMatches ? 1 : 0);
//       });
//     }
//
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 2.5,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onTap: () => _openFileDetails(index),
//       onLongPress: () {
//         _toggleSelectionMode();
//         setState(() {
//           _selectedFiles[index] = !_selectedFiles[index];
//         });
//       },
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Icon(Icons.description, color: Colors.blueAccent),
//                         SizedBox(width: 5,),
//                         Text(
//                           '${_filteredFileNames[index]}',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (_isInSelectionMode)
//                     IconButton(
//                       icon: _selectedFiles[index]
//                           ? Icon(Icons.check_circle, color: Colors.blue)
//                           : Icon(Icons.radio_button_unchecked, color: Colors.grey),
//                       onPressed: () => _toggleSelection(index),
//                     ),
//                   PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'Edit') {
//                         _showEditFileNameDialog(index);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => [
//                       PopupMenuItem(
//                         value: 'Edit',
//                         child: Row(
//                           children: [
//                             Icon(Icons.edit, color: Colors.blue),
//                             SizedBox(width: 10),
//                             Text('Edit'),
//                           ],
//                         ),
//                       ),
//                     ],
//                     child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                   ),
//                 ],
//               ),
//               Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 11 * 8.0), // Set the max width based on character width (approximately 8px per character)
//                   child: Text(
//                     index < _filteredNoteControllers.length && _filteredNoteControllers[index].text.isNotEmpty
//                         ? _filteredNoteControllers[index].text // Show actual content if present
//                         : 'No content...', // Show 'No content...' if the file is empty
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade800,
//                     ),
//                     overflow: TextOverflow.ellipsis, // Display ellipsis if text overflows
//                     maxLines: 1, // Display only one line
//                   ),
//                 ),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SearchScreen extends StatefulWidget {
//   final List<String> fileNames;
//   final List<TextEditingController> noteControllers;
//
//   SearchScreen({required this.fileNames, required this.noteControllers});
//
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//       } else {
//         _filteredFileNames = widget.fileNames
//             .where((fileName) => fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = widget.fileNames.indexOf(fileName);
//           return widget.noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 6,
//         title: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: "Search files...",
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               border: InputBorder.none,
//               icon: Icon(Icons.search, color: Colors.blueAccent),
//             ),
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//         ),
//       ),
//       body: _filteredFileNames.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.search_off, color: Colors.grey[400], size: 60),
//             SizedBox(height: 16),
//             Text(
//               "No files found. Try searching...",
//               style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       )
//           : ListView.builder(
//         itemCount: _filteredFileNames.length,
//         itemBuilder: (context, index) {
//           return InkWell(
//             onTap: () {
//               Navigator.pop(context, _filteredFileNames[index]);
//             },
//             child: AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               padding: EdgeInsets.all(16),
//               margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.description, color: Colors.blueAccent),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _filteredFileNames[index],
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           _filteredNoteControllers[index].text.isNotEmpty
//                               ? _filteredNoteControllers[index].text.split("\n").take(2).join("\n")
//                               : "No content...",
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 20),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   // List to store controllers for each new file's content
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = []; // List to store new file names
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData(); // Call this in didChangeDependencies to reload data when screen is revisited
//   }
//
//   // Load data from SharedPreferences when the screen is opened
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files (if any) specific to this file
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     newFileControllers.clear(); // Clear the old list to prevent duplicates
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController = TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//       }
//     }
//
//     setState(() {}); // Trigger a rebuild after loading data
//   }
//
//   // Save data to SharedPreferences when text changes
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Save the original note
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     // Save new files
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     // Save file names list specific to this file context
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   // Show create file dialog and save new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Add the new file name to the list specific to this file
//                     fileNames.add(newFileName);
//
//                     // Create a new controller for the new file's content
//                     TextEditingController newFileController = TextEditingController();
//                     newFileControllers.add(newFileController);
//                   }
//                 });
//
//                 // Save all data to SharedPreferences, specific to this file
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileName), // Display the original file name in the AppBar
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // The original file's note (TextField for the initial file)
//                 TextField(
//                   controller: widget.noteController,
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     labelText: 'Edit your note',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (text) {
//                     // Save changes as they are made
//                     _saveData();
//                   },
//                 ),
//                 // Dynamically created new file content TextFields below the original one
//                 ...List.generate(fileNames.length, (index) {
//                   // Check if the number of controllers is less than the fileNames length
//                   // This will prevent the index error by making sure we don't access invalid indexes
//                   if (index < newFileControllers.length) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Display file name as a label
//                           Text(
//                             'File: ${fileNames[index]}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           // TextField for new file content
//                           TextField(
//                             controller: newFileControllers[index], // Each new file gets its own controller
//                             maxLines: null,
//                             keyboardType: TextInputType.multiline,
//                             decoration: InputDecoration(
//                               // labelText: 'New File Content',
//                               border: OutlineInputBorder(),
//                             ),
//                             onChanged: (text) {
//                               // Save changes as they are made
//                               _saveData();
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return SizedBox.shrink(); // Return an empty widget if something goes wrong
//                   }
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
//
//
//
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//   bool _isGridView = false;
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   void _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     int minLength = savedFileNames.length < savedFileContents.length ? savedFileNames.length : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents.take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//       _filteredFileNames = List.from(_fileNames);
//       _filteredNoteControllers = List.from(_noteControllers);
//     });
//
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {});
//       });
//     }
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = List.from(_fileNames);
//         _filteredNoteControllers = List.from(_noteControllers);
//       } else {
//         _filteredFileNames = _fileNames.where((fileName) => fileName.toLowerCase().contains(query.toLowerCase())).toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = _fileNames.indexOf(fileName);
//           return _noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//
//   Future<void> _deleteSelectedFiles() async {
//     setState(() {
//       List<int> toRemove = [];
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         if (_selectedFiles[i]) {
//           toRemove.add(i);
//         }
//       }
//
//       for (int i = toRemove.length - 1; i >= 0; i--) {
//         _fileNames.removeAt(toRemove[i]);
//         _noteControllers.removeAt(toRemove[i]);
//         _focusNodes.removeAt(toRemove[i]);
//         _selectedFiles.removeAt(toRemove[i]);
//       }
//
//       _isInSelectionMode = false;
//     });
//
//     _saveAllNotes();
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     _fileNames.insert(0, newFileName);
//                     TextEditingController newController = TextEditingController();
//                     newController.addListener(() {
//                       setState(() {});
//                     });
//
//                     _noteControllers.insert(0, newController);
//                     _focusNodes.insert(0, FocusNode());
//                     _selectedFiles.insert(0, false);
//                   }
//                 });
//
//                 _filterFiles(_searchController.text); // Re-filter after adding a new file
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//     _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController = TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _fileNames[index] = _fileNameController.text;
//                 });
//
//                 _filterFiles(_searchController.text); // Re-filter after editing the file name
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openFileDetails(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _filteredFileNames[index],
//           noteController: _filteredNoteControllers[index],
//         ),
//       ),
//     ).then((_) {
//       // Clear search query after returning from file details
//       setState(() {
//         _searchController.clear();
//         _filterFiles(""); // Reset filtered list
//       });
//     });
//   }
//
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       if (!_isInSelectionMode) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//   String _searchQuery = "";
//   void _toggleView() {
//     setState(() {
//       _isGridView = !_isGridView;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 4,
//         shadowColor: Colors.black26,
//         title: Text(
//           "Notepad",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.blueAccent, size: 28),
//             onPressed: () async {
//               final selectedFile = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchScreen(
//                     fileNames: _fileNames,
//                     noteControllers: _noteControllers,
//                   ),
//                 ),
//               );
//
//               if (selectedFile != null) {
//                 int index = _fileNames.indexOf(selectedFile);
//                 _openFileDetails(index);
//               }
//             },
//             tooltip: "Search Notes",
//           ),
//           IconButton(
//             icon: Icon(
//               _isGridView ? Icons.view_list : Icons.grid_view,
//               color: Colors.blueAccent,
//               size: 28,
//             ),
//             onPressed: _toggleView,
//             tooltip: 'Toggle View',
//           ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//           SizedBox(width: 10), // Extra spacing for better UI
//         ],
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _isGridView ? _buildGridView() : _buildListView(),
//       ),
//       floatingActionButton:FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         backgroundColor: Colors.blueAccent,
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: AnimatedSwitcher(
//           duration: Duration(milliseconds: 400),
//           transitionBuilder: (child, animation) => ScaleTransition(
//             scale: animation,
//             child: child,
//           ),
//           child: Icon(
//             Icons.add,
//             key: ValueKey<int>(1),
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//
//
//     );
//   }
//
//   Widget _buildListView() {
//     return ListView.builder(
//       itemCount: _filteredFileNames.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(index);
//       },
//     );
//   }
//
//   Widget _buildGridView() {
//     List<int> sortedIndexes = List.generate(_fileNames.length, (index) => index);
//     if (_searchQuery.isNotEmpty) {
//       sortedIndexes.sort((a, b) {
//         bool aMatches = _fileNames[a].toLowerCase().contains(_searchQuery.toLowerCase());
//         bool bMatches = _fileNames[b].toLowerCase().contains(_searchQuery.toLowerCase());
//         return (bMatches ? 1 : 0) - (aMatches ? 1 : 0);
//       });
//     }
//
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 2.5,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//
//   Widget _buildFileItem(int index) {
//     if (_filteredFileNames.isEmpty || _filteredNoteControllers.isEmpty || index >= _filteredFileNames.length || index >= _filteredNoteControllers.length) {
//       return SizedBox(); // Return an empty widget if the lists are empty or index is out of range
//     }
//     return GestureDetector(
//       onTap: () => _openFileDetails(index),
//       onLongPress: () {
//         _toggleSelectionMode();
//         setState(() {
//           _selectedFiles[index] = !_selectedFiles[index];
//         });
//       },
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Icon(Icons.description, color: Colors.blueAccent),
//                         SizedBox(width: 5),
//                         Text(
//                           _filteredFileNames[index],
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (_isInSelectionMode)
//                     IconButton(
//                       icon: _selectedFiles[index]
//                           ? Icon(Icons.check_circle, color: Colors.blue)
//                           : Icon(Icons.radio_button_unchecked, color: Colors.grey),
//                       onPressed: () => _toggleSelection(index),
//                     ),
//                   PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'Edit') {
//                         _showEditFileNameDialog(index);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => [
//                       PopupMenuItem(
//                         value: 'Edit',
//                         child: Row(
//                           children: [
//                             Icon(Icons.edit, color: Colors.blue),
//                             SizedBox(width: 10),
//                             Text('Edit'),
//                           ],
//                         ),
//                       ),
//                     ],
//                     child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                   ),
//                 ],
//               ),
//               Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 11 * 8.0), // Set the max width based on character width (approximately 8px per character)
//                   child: Text(
//                     _filteredNoteControllers[index].text.isNotEmpty
//                         ? _filteredNoteControllers[index].text
//                         : 'Add new content...', // Show 'No content...' if the file is empty
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade800,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
// }
//
// class SearchScreen extends StatefulWidget {
//   final List<String> fileNames;
//   final List<TextEditingController> noteControllers;
//
//   SearchScreen({required this.fileNames, required this.noteControllers});
//
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//       } else {
//         _filteredFileNames = widget.fileNames
//             .where((fileName) => fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = widget.fileNames.indexOf(fileName);
//           return widget.noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 6,
//         title: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: "Search files...",
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               border: InputBorder.none,
//               icon: Icon(Icons.search, color: Colors.blueAccent),
//             ),
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//         ),
//       ),
//       body: _filteredFileNames.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.search_off, color: Colors.grey[400], size: 60),
//             SizedBox(height: 16),
//             Text(
//               "No files found. Try searching...",
//               style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       )
//           : ListView.builder(
//         itemCount: _filteredFileNames.length,
//         itemBuilder: (context, index) {
//           return InkWell(
//             onTap: () {
//               Navigator.pop(context, _filteredFileNames[index]);
//             },
//             child: AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               padding: EdgeInsets.all(16),
//               margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.description, color: Colors.blueAccent),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _filteredFileNames[index],
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           _filteredNoteControllers[index].text.isNotEmpty
//                               ? _filteredNoteControllers[index].text.split("\n").take(2).join("\n")
//                               : "No content...",
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 20),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   // List to store controllers for each new file's content
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = []; // List to store new file names
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData(); // Call this in didChangeDependencies to reload data when screen is revisited
//   }
//
//   // Load data from SharedPreferences when the screen is opened
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files (if any) specific to this file
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     newFileControllers.clear(); // Clear the old list to prevent duplicates
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController = TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//       }
//     }
//
//     setState(() {}); // Trigger a rebuild after loading data
//   }
//
//   // Save data to SharedPreferences when text changes
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Save the original note
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     // Save new files
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     // Save file names list specific to this file context
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   // Show create file dialog and save new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Add the new file name to the list specific to this file
//                     fileNames.add(newFileName);
//
//                     // Create a new controller for the new file's content
//                     TextEditingController newFileController = TextEditingController();
//                     newFileControllers.add(newFileController);
//                   }
//                 });
//
//                 // Save all data to SharedPreferences, specific to this file
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileName), // Display the original file name in the AppBar
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // The original file's note (TextField for the initial file)
//                 TextField(
//                   controller: widget.noteController,
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     labelText: 'Edit your note',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (text) {
//                     // Save changes as they are made
//                     _saveData();
//                   },
//                 ),
//                 // Dynamically created new file content TextFields below the original one
//                 ...List.generate(fileNames.length, (index) {
//                   // Check if the number of controllers is less than the fileNames length
//                   // This will prevent the index error by making sure we don't access invalid indexes
//                   if (index < newFileControllers.length) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Display file name as a label
//                           Text(
//                             'File: ${fileNames[index]}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           // TextField for new file content
//                           TextField(
//                             controller: newFileControllers[index], // Each new file gets its own controller
//                             maxLines: null,
//                             keyboardType: TextInputType.multiline,
//                             decoration: InputDecoration(
//                               // labelText: 'New File Content',
//                               border: OutlineInputBorder(),
//                             ),
//                             onChanged: (text) {
//                               // Save changes as they are made
//                               _saveData();
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return SizedBox.shrink(); // Return an empty widget if something goes wrong
//                   }
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//   bool _isGridView = false;
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   // Load the notes from SharedPreferences
//   void _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     int minLength = savedFileNames.length < savedFileContents.length
//         ? savedFileNames.length
//         : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents
//           .take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//       _filteredFileNames = List.from(_fileNames);
//       _filteredNoteControllers = List.from(_noteControllers);
//     });
//
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {});
//       });
//     }
//   }
//
//   // Filter files based on search query
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = List.from(_fileNames);
//         _filteredNoteControllers = List.from(_noteControllers);
//       } else {
//         _filteredFileNames = _fileNames
//             .where((fileName) =>
//             fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = _fileNames.indexOf(fileName);
//           return _noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   // Delete selected files
//   Future<void> _deleteSelectedFiles() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     List<String> newFileNames = [];
//     List<String> newFileContents = [];
//
//     setState(() {
//       for (int i = 0; i < _fileNames.length; i++) {
//         if (!_selectedFiles[i]) {
//           newFileNames.add(_fileNames[i]);
//           newFileContents.add(_noteControllers[i].text);
//         }
//       }
//
//       _fileNames = List.from(newFileNames);
//       _noteControllers = newFileContents.map((content) => TextEditingController(text: content)).toList();
//       _focusNodes = List.generate(_fileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(_fileNames.length, (_) => false);
//
//       _isInSelectionMode = false;
//     });
//
//     // अपडेटेड डेटा को SharedPreferences में सेव करें
//     await prefs.setStringList('fileNames', newFileNames);
//     await prefs.setStringList('fileContents', newFileContents);
//   }
//
//
//   // Show dialog to create a new file
// // Show dialog to create a new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 String newFileName = _fileNameController.text.trim();
//
//                 // Check if file name is empty
//                 if (newFileName.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("File name cannot be empty!"))
//                   );
//                   return;
//                 }
//
//                 // Convert file names to lowercase for case-insensitive comparison
//                 bool fileExists = _fileNames.any((file) => file.toLowerCase() == newFileName.toLowerCase());
//
//                 if (fileExists) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("A file with this name already exists!"))
//                   );
//                   return;
//                 }
//
//                 setState(() {
//                   _fileNames.insert(0, newFileName);
//                   TextEditingController newController = TextEditingController();
//                   newController.addListener(() {
//                     setState(() {});
//                   });
//
//                   _noteControllers.insert(0, newController);
//                   _focusNodes.insert(0, FocusNode());
//                   _selectedFiles.insert(0, false);
//                 });
//
//                 _filterFiles(_searchController.text); // Re-filter after adding a new file
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   // Toggle selection of files
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//   // Save all notes to SharedPreferences
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//     _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   // Show dialog to edit file name
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//     TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _fileNames[index] = _fileNameController.text;
//                 });
//
//                 _filterFiles(_searchController.text); // Re-filter after editing the file name
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Open file details screen
//   void _openFileDetails(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _filteredFileNames[index],
//           noteController: _filteredNoteControllers[index],
//         ),
//       ),
//     ).then((_) {
//       // Clear search query after returning from file details
//       setState(() {
//         _searchController.clear();
//         _filterFiles(""); // Reset filtered list
//       });
//     });
//   }
//
//   // Toggle selection mode
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       if (!_isInSelectionMode) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   // Toggle between grid and list view
//   void _toggleView() {
//     setState(() {
//       _isGridView = !_isGridView;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 4,
//         shadowColor: Colors.black26,
//         title: Text(
//           "Notepad",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.blueAccent, size: 28),
//             onPressed: () async {
//               final selectedFile = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchScreen(
//                     fileNames: _fileNames,
//                     noteControllers: _noteControllers,
//                   ),
//                 ),
//               );
//
//               if (selectedFile != null) {
//                 int index = _fileNames.indexOf(selectedFile);
//                 _openFileDetails(index);
//               }
//             },
//             tooltip: "Search Notes",
//           ),
//           IconButton(
//             icon: Icon(
//               _isGridView ? Icons.view_list : Icons.grid_view,
//               color: Colors.blueAccent,
//               size: 28,
//             ),
//             onPressed: _toggleView,
//             tooltip: 'Toggle View',
//           ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//           SizedBox(width: 10), // Extra spacing for better UI
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _isGridView ? _buildGridView() : _buildListView(),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         backgroundColor: Colors.blueAccent,
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: AnimatedSwitcher(
//           duration: Duration(milliseconds: 400),
//           transitionBuilder: (child, animation) => ScaleTransition(
//             scale: animation,
//             child: child,
//           ),
//           child: Icon(
//             Icons.add,
//             key: ValueKey<int>(1),
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Build ListView
//   Widget _buildListView() {
//     List<int> sortedIndexes = List.generate(_fileNames.length, (index) => index);
//
//     return ListView.builder(
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//   // Build GridView
//   Widget _buildGridView() {
//     List<int> sortedIndexes = List.generate(_fileNames.length, (index) => index);
//
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 2.5,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//   // Build each file item in the list/grid
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onTap: () => _openFileDetails(index),
//       onLongPress: () {
//         _toggleSelectionMode();
//         setState(() {
//           _selectedFiles[index] = !_selectedFiles[index];
//         });
//       },
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Icon(Icons.description, color: Colors.blueAccent),
//                         SizedBox(width: 5),
//                         Text(
//                           '${_filteredFileNames[index]}',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (_isInSelectionMode)
//                     IconButton(
//                       icon: _selectedFiles[index]
//                           ? Icon(Icons.check_circle, color: Colors.blue)
//                           : Icon(Icons.radio_button_unchecked, color: Colors.grey),
//                       onPressed: () => _toggleSelection(index),
//                     ),
//                   PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'Edit') {
//                         _showEditFileNameDialog(index);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => [
//                       PopupMenuItem(
//                         value: 'Edit',
//                         child: Row(
//                           children: [
//                             Icon(Icons.edit, color: Colors.blue),
//                             SizedBox(width: 10),
//                             Text('Edit'),
//                           ],
//                         ),
//                       ),
//                     ],
//                     child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                   ),
//                 ],
//               ),
//               Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 11 * 8.0),
//                   child: Text(
//                     index < _filteredNoteControllers.length &&
//                         _filteredNoteControllers[index].text.isNotEmpty
//                         ? _filteredNoteControllers[index].text
//                         : 'Add content...',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade800,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SearchScreen extends StatefulWidget {
//   final List<String> fileNames;
//   final List<TextEditingController> noteControllers;
//
//   SearchScreen({required this.fileNames, required this.noteControllers});
//
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//       } else {
//         _filteredFileNames = widget.fileNames
//             .where((fileName) => fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = widget.fileNames.indexOf(fileName);
//           return widget.noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 6,
//         title: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: "Search files...",
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               border: InputBorder.none,
//               icon: Icon(Icons.search, color: Colors.blueAccent),
//             ),
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//         ),
//       ),
//       body: _filteredFileNames.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.search_off, color: Colors.grey[400], size: 60),
//             SizedBox(height: 16),
//             Text(
//               "No files found. Try searching...",
//               style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       )
//           : ListView.builder(
//         itemCount: _filteredFileNames.length,
//         itemBuilder: (context, index) {
//           return InkWell(
//             onTap: () {
//               Navigator.pop(context, _filteredFileNames[index]);
//             },
//             child: AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               padding: EdgeInsets.all(16),
//               margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.description, color: Colors.blueAccent),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _filteredFileNames[index],
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           _filteredNoteControllers[index].text.isNotEmpty
//                               ? _filteredNoteControllers[index].text.split("\n").take(2).join("\n")
//                               : "No content...",
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 20),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   // List to store controllers for each new file's content
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = []; // List to store new file names
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData(); // Call this in didChangeDependencies to reload data when screen is revisited
//   }
//
//   // Load data from SharedPreferences when the screen is opened
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files (if any) specific to this file
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     newFileControllers.clear(); // Clear the old list to prevent duplicates
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController = TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//       }
//     }
//
//     setState(() {}); // Trigger a rebuild after loading data
//   }
//
//   // Save data to SharedPreferences when text changes
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Save the original note
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     // Save new files
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     // Save file names list specific to this file context
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   // Show create file dialog and save new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Add the new file name to the list specific to this file
//                     fileNames.add(newFileName);
//
//                     // Create a new controller for the new file's content
//                     TextEditingController newFileController = TextEditingController();
//                     newFileControllers.add(newFileController);
//                   }
//                 });
//
//                 // Save all data to SharedPreferences, specific to this file
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileName), // Display the original file name in the AppBar
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // The original file's note (TextField for the initial file)
//                 TextField(
//                   controller: widget.noteController,
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     labelText: 'Edit your note',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (text) {
//                     // Save changes as they are made
//                     _saveData();
//                   },
//                 ),
//                 // Dynamically created new file content TextFields below the original one
//                 ...List.generate(fileNames.length, (index) {
//                   // Check if the number of controllers is less than the fileNames length
//                   // This will prevent the index error by making sure we don't access invalid indexes
//                   if (index < newFileControllers.length) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Display file name as a label
//                           Text(
//                             'File: ${fileNames[index]}',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           // TextField for new file content
//                           TextField(
//                             controller: newFileControllers[index], // Each new file gets its own controller
//                             maxLines: null,
//                             keyboardType: TextInputType.multiline,
//                             decoration: InputDecoration(
//                               // labelText: 'New File Content',
//                               border: OutlineInputBorder(),
//                             ),
//                             onChanged: (text) {
//                               // Save changes as they are made
//                               _saveData();
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return SizedBox.shrink(); // Return an empty widget if something goes wrong
//                   }
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
//
//
//
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//   bool _isGridView = false;
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   // Load the notes from SharedPreferences
//   void _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     int minLength = savedFileNames.length < savedFileContents.length
//         ? savedFileNames.length
//         : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents
//           .take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//       _filteredFileNames = List.from(_fileNames);
//       _filteredNoteControllers = List.from(_noteControllers);
//     });
//
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {});
//       });
//     }
//   }
//
//   // Filter files based on search query
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = List.from(_fileNames);
//         _filteredNoteControllers = List.from(_noteControllers);
//       } else {
//         _filteredFileNames = _fileNames
//             .where((fileName) =>
//             fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = _fileNames.indexOf(fileName);
//           return _noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   // Delete selected files
//   Future<void> _deleteSelectedFiles() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     List<String> newFileNames = [];
//     List<String> newFileContents = [];
//
//     setState(() {
//       for (int i = 0; i < _fileNames.length; i++) {
//         if (!_selectedFiles[i]) {
//           newFileNames.add(_fileNames[i]);
//           newFileContents.add(_noteControllers[i].text);
//         }
//       }
//
//       _fileNames = List.from(newFileNames);
//       _noteControllers = newFileContents.map((content) => TextEditingController(text: content)).toList();
//       _focusNodes = List.generate(_fileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(_fileNames.length, (_) => false);
//
//       _isInSelectionMode = false;
//     });
//
//     // अपडेटेड डेटा को SharedPreferences में सेव करें
//     await prefs.setStringList('fileNames', newFileNames);
//     await prefs.setStringList('fileContents', newFileContents);
//   }
//
//
//   // Show dialog to create a new file
// // Show dialog to create a new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 String newFileName = _fileNameController.text.trim();
//
//                 // Check if file name is empty
//                 if (newFileName.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("File name cannot be empty!"))
//                   );
//                   return;
//                 }
//
//                 // Convert file names to lowercase for case-insensitive comparison
//                 bool fileExists = _fileNames.any((file) => file.toLowerCase() == newFileName.toLowerCase());
//
//                 if (fileExists) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("A file with this name already exists!"))
//                   );
//                   return;
//                 }
//
//                 setState(() {
//                   _fileNames.insert(0, newFileName);
//                   TextEditingController newController = TextEditingController();
//                   newController.addListener(() {
//                     setState(() {});
//                   });
//
//                   _noteControllers.insert(0, newController);
//                   _focusNodes.insert(0, FocusNode());
//                   _selectedFiles.insert(0, false);
//                 });
//
//                 _filterFiles(_searchController.text); // Re-filter after adding a new file
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   // Toggle selection of files
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//   // Save all notes to SharedPreferences
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//     _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   // Show dialog to edit file name
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//     TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _fileNames[index] = _fileNameController.text;
//                 });
//
//                 _filterFiles(_searchController.text); // Re-filter after editing the file name
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Open file details screen
//   void _openFileDetails(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _filteredFileNames[index],
//           noteController: _filteredNoteControllers[index],
//         ),
//       ),
//     ).then((_) {
//       // Clear search query after returning from file details
//       setState(() {
//         _searchController.clear();
//         _filterFiles(""); // Reset filtered list
//       });
//     });
//   }
//
//   void _selectAllFiles() {
//     setState(() {
//       bool allSelected = _selectedFiles.every((selected) => selected);
//       if (allSelected) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//         _isInSelectionMode = false; // अगर सभी अनसेलेक्ट हैं तो मोड बंद करें
//       } else {
//         _selectedFiles = List.generate(_fileNames.length, (_) => true);
//         _isInSelectionMode = true;
//       }
//     });
//   }
//
//
//   // Toggle selection mode
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       if (!_isInSelectionMode) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   // Toggle between grid and list view
//   void _toggleView() {
//     setState(() {
//       _isGridView = !_isGridView;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 4,
//         shadowColor: Colors.black26,
//         title: Text(
//           "Notepad",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.blueAccent, size: 28),
//             onPressed: () async {
//               final selectedFile = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchScreen(
//                     fileNames: _fileNames,
//                     noteControllers: _noteControllers,
//                   ),
//                 ),
//               );
//
//               if (selectedFile != null) {
//                 int index = _fileNames.indexOf(selectedFile);
//                 _openFileDetails(index);
//               }
//             },
//             tooltip: "Search Notes",
//           ),
//           IconButton(
//             icon: Icon(
//               _isGridView ? Icons.view_list : Icons.grid_view,
//               color: Colors.blueAccent,
//               size: 28,
//             ),
//             onPressed: _toggleView,
//             tooltip: 'Toggle View',
//           ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.select_all, color: Colors.orange, size: 28),
//               onPressed: _selectAllFiles,
//               tooltip: 'Select All',
//             ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//           SizedBox(width: 10), // Extra spacing for better UI
//         ],
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _isGridView ? _buildGridView() : _buildListView(),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         backgroundColor: Colors.blueAccent,
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: AnimatedSwitcher(
//           duration: Duration(milliseconds: 400),
//           transitionBuilder: (child, animation) => ScaleTransition(
//             scale: animation,
//             child: child,
//           ),
//           child: Icon(
//             Icons.add,
//             key: ValueKey<int>(1),
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Build ListView
//   Widget _buildListView() {
//     List<int> sortedIndexes = List.generate(_fileNames.length, (index) => index);
//
//     return ListView.builder(
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//   // Build GridView
//   Widget _buildGridView() {
//     List<int> sortedIndexes = List.generate(_fileNames.length, (index) => index);
//
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 2.5,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//   // Build each file item in the list/grid
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onTap: () => _openFileDetails(index),
//       onLongPress: () {
//         _toggleSelectionMode();
//         setState(() {
//           _selectedFiles[index] = !_selectedFiles[index];
//         });
//       },
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Icon(Icons.description, color: Colors.blueAccent),
//                         SizedBox(width: 5),
//                         Text(
//                           '${_filteredFileNames[index]}',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (_isInSelectionMode)
//                     IconButton(
//                       icon: _selectedFiles[index]
//                           ? Icon(Icons.check_circle, color: Colors.blue)
//                           : Icon(Icons.radio_button_unchecked, color: Colors.grey),
//                       onPressed: () => _toggleSelection(index),
//                     ),
//                   PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'Edit') {
//                         _showEditFileNameDialog(index);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => [
//                       PopupMenuItem(
//                         value: 'Edit',
//                         child: Row(
//                           children: [
//                             Icon(Icons.edit, color: Colors.blue),
//                             SizedBox(width: 10),
//                             Text('Edit'),
//                           ],
//                         ),
//                       ),
//                     ],
//                     child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                   ),
//                 ],
//               ),
//               Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 11 * 8.0),
//                   child: Text(
//                     index < _filteredNoteControllers.length &&
//                         _filteredNoteControllers[index].text.isNotEmpty
//                         ? _filteredNoteControllers[index].text
//                         : 'Add content...',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade800,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SearchScreen extends StatefulWidget {
//   final List<String> fileNames;
//   final List<TextEditingController> noteControllers;
//
//   SearchScreen({required this.fileNames, required this.noteControllers});
//
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//       } else {
//         _filteredFileNames = widget.fileNames
//             .where((fileName) => fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = widget.fileNames.indexOf(fileName);
//           return widget.noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 6,
//         title: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: "Search files...",
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               border: InputBorder.none,
//               icon: Icon(Icons.search, color: Colors.blueAccent),
//             ),
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//         ),
//       ),
//       body: _filteredFileNames.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.search_off, color: Colors.grey[400], size: 60),
//             SizedBox(height: 16),
//             Text(
//               "No files found. Try searching...",
//               style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       )
//           : ListView.builder(
//         itemCount: _filteredFileNames.length,
//         itemBuilder: (context, index) {
//           return InkWell(
//             onTap: () {
//               Navigator.pop(context, _filteredFileNames[index]);
//             },
//             child: AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               padding: EdgeInsets.all(16),
//               margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.description, color: Colors.blueAccent),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _filteredFileNames[index],
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           _filteredNoteControllers[index].text.isNotEmpty
//                               ? _filteredNoteControllers[index].text.split("\n").take(2).join("\n")
//                               : "No content...",
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 20),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   // List to store controllers for each new file's content
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = []; // List to store new file names
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData(); // Call this in didChangeDependencies to reload data when screen is revisited
//   }
//
//   // Load data from SharedPreferences when the screen is opened
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files (if any) specific to this file
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     newFileControllers.clear(); // Clear the old list to prevent duplicates
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController = TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//       }
//     }
//
//     setState(() {}); // Trigger a rebuild after loading data
//   }
//
//   // Save data to SharedPreferences when text changes
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Save the original note
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     // Save new files
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     // Save file names list specific to this file context
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   // Show create file dialog and save new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Add the new file name to the list specific to this file
//                     fileNames.add(newFileName);
//
//                     // Create a new controller for the new file's content
//                     TextEditingController newFileController = TextEditingController();
//                     newFileControllers.add(newFileController);
//                   }
//                 });
//
//                 // Save all data to SharedPreferences, specific to this file
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Delete file method
//   Future<void> _deleteFile(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Remove file from SharedPreferences
//     await prefs.remove(fileNames[index]);
//
//     // Remove the file from the list and controller
//     setState(() {
//       fileNames.removeAt(index);
//       newFileControllers.removeAt(index);
//     });
//
//     // Update file names list in SharedPreferences
//     await prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   // Show delete confirmation dialog
//   void _showDeleteConfirmationDialog(int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Delete File"),
//           content: Text("Are you sure you want to delete '${fileNames[index]}'?"),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Cancel"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text("Delete", style: TextStyle(color: Colors.red)),
//               onPressed: () {
//                 _deleteFile(index);  // Call delete function
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Edit file name method
//   Future<void> _editFileName(int index) async {
//     TextEditingController _fileNameController = TextEditingController(text: fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Update the file name in the list
//                     fileNames[index] = newFileName;
//                   }
//                 });
//
//                 // Save updated data to SharedPreferences
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Build file item with delete and edit options
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onLongPress: () {
//         _showDeleteConfirmationDialog(index);  // Long press for delete confirmation
//       },
//       child: Card(
//         elevation: 3,
//         margin: EdgeInsets.symmetric(vertical: 8),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     fileNames[index],
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.edit, color: Colors.orange), // Edit button
//                         onPressed: () {
//                           _editFileName(index); // Show dialog to edit file name
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               TextField(
//                 controller: newFileControllers[index],
//                 maxLines: null,
//                 keyboardType: TextInputType.multiline,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   hintText: 'Enter content...',
//                 ),
//                 onChanged: (text) {
//                   _saveData();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileName), // Display the original file name in the AppBar
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // The original file's note (TextField for the initial file)
//                 TextField(
//                   controller: widget.noteController,
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     labelText: 'Edit your note',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (text) {
//                     _saveData();
//                   },
//                 ),
//                 // Dynamically created new file content TextFields below the original one
//                 ...List.generate(fileNames.length, (index) {
//                   return _buildFileItem(index);  // Use the method for each file
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
//
//
//
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//   bool _isGridView = false;
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   // Load the notes from SharedPreferences
//   void _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     int minLength = savedFileNames.length < savedFileContents.length
//         ? savedFileNames.length
//         : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents
//           .take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//       _filteredFileNames = List.from(_fileNames);
//       _filteredNoteControllers = List.from(_noteControllers);
//     });
//
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {});
//       });
//     }
//   }
//
//   // Filter files based on search query
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = List.from(_fileNames);
//         _filteredNoteControllers = List.from(_noteControllers);
//       } else {
//         _filteredFileNames = _fileNames
//             .where((fileName) =>
//             fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = _fileNames.indexOf(fileName);
//           return _noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   // Delete selected files
//   Future<void> _deleteSelectedFiles() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     List<String> newFileNames = [];
//     List<String> newFileContents = [];
//
//     setState(() {
//       for (int i = 0; i < _fileNames.length; i++) {
//         if (!_selectedFiles[i]) {
//           newFileNames.add(_fileNames[i]);
//           newFileContents.add(_noteControllers[i].text);
//         }
//       }
//
//       _fileNames = List.from(newFileNames);
//       _noteControllers = newFileContents.map((content) => TextEditingController(text: content)).toList();
//       _focusNodes = List.generate(_fileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(_fileNames.length, (_) => false);
//
//       _isInSelectionMode = false;
//     });
//
//     // अपडेटेड डेटा को SharedPreferences में सेव करें
//     await prefs.setStringList('fileNames', newFileNames);
//     await prefs.setStringList('fileContents', newFileContents);
//   }
//
//
//   // Show dialog to create a new file
// // Show dialog to create a new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 String newFileName = _fileNameController.text.trim();
//
//                 // Check if file name is empty
//                 if (newFileName.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("File name cannot be empty!"))
//                   );
//                   return;
//                 }
//
//                 // Convert file names to lowercase for case-insensitive comparison
//                 bool fileExists = _fileNames.any((file) => file.toLowerCase() == newFileName.toLowerCase());
//
//                 if (fileExists) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("A file with this name already exists!"))
//                   );
//                   return;
//                 }
//
//                 setState(() {
//                   _fileNames.insert(0, newFileName);
//                   TextEditingController newController = TextEditingController();
//                   newController.addListener(() {
//                     setState(() {});
//                   });
//
//                   _noteControllers.insert(0, newController);
//                   _focusNodes.insert(0, FocusNode());
//                   _selectedFiles.insert(0, false);
//                 });
//
//                 _filterFiles(_searchController.text); // Re-filter after adding a new file
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   // Toggle selection of files
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//   // Save all notes to SharedPreferences
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//     _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   // Show dialog to edit file name
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//     TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _fileNames[index] = _fileNameController.text;
//                 });
//
//                 _filterFiles(_searchController.text); // Re-filter after editing the file name
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Open file details screen
//   void _openFileDetails(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _filteredFileNames[index],
//           noteController: _filteredNoteControllers[index],
//         ),
//       ),
//     ).then((_) {
//       // Clear search query after returning from file details
//       setState(() {
//         _searchController.clear();
//         _filterFiles(""); // Reset filtered list
//       });
//     });
//   }
//
//   void _selectAllFiles() {
//     setState(() {
//       bool allSelected = _selectedFiles.every((selected) => selected);
//       if (allSelected) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//         _isInSelectionMode = false; // अगर सभी अनसेलेक्ट हैं तो मोड बंद करें
//       } else {
//         _selectedFiles = List.generate(_fileNames.length, (_) => true);
//         _isInSelectionMode = true;
//       }
//     });
//   }
//
//
//   // Toggle selection mode
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       if (!_isInSelectionMode) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   // Toggle between grid and list view
//   void _toggleView() {
//     setState(() {
//       _isGridView = !_isGridView;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 4,
//         shadowColor: Colors.black26,
//         title: Text(
//           "Notepad",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.blueAccent, size: 28),
//             onPressed: () async {
//               final selectedFile = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchScreen(
//                     fileNames: _fileNames,
//                     noteControllers: _noteControllers,
//                   ),
//                 ),
//               );
//
//               if (selectedFile != null) {
//                 int index = _fileNames.indexOf(selectedFile);
//                 _openFileDetails(index);
//               }
//             },
//             tooltip: "Search Notes",
//           ),
//           IconButton(
//             icon: Icon(
//               _isGridView ? Icons.view_list : Icons.grid_view,
//               color: Colors.blueAccent,
//               size: 28,
//             ),
//             onPressed: _toggleView,
//             tooltip: 'Toggle View',
//           ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.select_all, color: Colors.orange, size: 28),
//               onPressed: _selectAllFiles,
//               tooltip: 'Select All',
//             ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//           SizedBox(width: 10), // Extra spacing for better UI
//         ],
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _isGridView ? _buildGridView() : _buildListView(),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         backgroundColor: Colors.blueAccent,
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: AnimatedSwitcher(
//           duration: Duration(milliseconds: 400),
//           transitionBuilder: (child, animation) => ScaleTransition(
//             scale: animation,
//             child: child,
//           ),
//           child: Icon(
//             Icons.add,
//             key: ValueKey<int>(1),
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Build ListView
//   Widget _buildListView() {
//     List<int> sortedIndexes = List.generate(_fileNames.length, (index) => index);
//
//     return ListView.builder(
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//   // Build GridView
//   Widget _buildGridView() {
//     List<int> sortedIndexes = List.generate(_fileNames.length, (index) => index);
//
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 2.5,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//   // Build each file item in the list/grid
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onTap: () => _openFileDetails(index),
//       onLongPress: () {
//         _toggleSelectionMode();
//         setState(() {
//           _selectedFiles[index] = !_selectedFiles[index];
//         });
//       },
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Icon(Icons.description, color: Colors.blueAccent),
//                         SizedBox(width: 5),
//                         Text(
//                           '${_filteredFileNames[index]}',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (_isInSelectionMode)
//                     IconButton(
//                       icon: _selectedFiles[index]
//                           ? Icon(Icons.check_circle, color: Colors.blue)
//                           : Icon(Icons.radio_button_unchecked, color: Colors.grey),
//                       onPressed: () => _toggleSelection(index),
//                     ),
//                   PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'Edit') {
//                         _showEditFileNameDialog(index);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => [
//                       PopupMenuItem(
//                         value: 'Edit',
//                         child: Row(
//                           children: [
//                             Icon(Icons.edit, color: Colors.blue),
//                             SizedBox(width: 10),
//                             Text('Edit'),
//                           ],
//                         ),
//                       ),
//                     ],
//                     child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                   ),
//                 ],
//               ),
//               Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 11 * 8.0),
//                   child: Text(
//                     index < _filteredNoteControllers.length &&
//                         _filteredNoteControllers[index].text.isNotEmpty
//                         ? _filteredNoteControllers[index].text
//                         : 'Add content...',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade800,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SearchScreen extends StatefulWidget {
//   final List<String> fileNames;
//   final List<TextEditingController> noteControllers;
//
//   SearchScreen({required this.fileNames, required this.noteControllers});
//
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//       } else {
//         _filteredFileNames = widget.fileNames
//             .where((fileName) => fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = widget.fileNames.indexOf(fileName);
//           return widget.noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 6,
//         title: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: "Search files...",
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               border: InputBorder.none,
//               icon: Icon(Icons.search, color: Colors.blueAccent),
//             ),
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//         ),
//       ),
//       body: _filteredFileNames.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.search_off, color: Colors.grey[400], size: 60),
//             SizedBox(height: 16),
//             Text(
//               "No files found. Try searching...",
//               style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       )
//           : ListView.builder(
//         itemCount: _filteredFileNames.length,
//         itemBuilder: (context, index) {
//           return InkWell(
//             onTap: () {
//               Navigator.pop(context, _filteredFileNames[index]);
//             },
//             child: AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               padding: EdgeInsets.all(16),
//               margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.description, color: Colors.blueAccent),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _filteredFileNames[index],
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           _filteredNoteControllers[index].text.isNotEmpty
//                               ? _filteredNoteControllers[index].text.split("\n").take(2).join("\n")
//                               : "No content...",
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 20),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   // List to store controllers for each new file's content
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = []; // List to store new file names
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData(); // Call this in didChangeDependencies to reload data when screen is revisited
//   }
//
//   // Load data from SharedPreferences when the screen is opened
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files (if any) specific to this file
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     newFileControllers.clear(); // Clear the old list to prevent duplicates
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController = TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//       }
//     }
//
//     setState(() {}); // Trigger a rebuild after loading data
//   }
//
//   // Save data to SharedPreferences when text changes
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Save the original note
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     // Save new files
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     // Save file names list specific to this file context
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   // Show create file dialog and save new file
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Enter File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Add the new file name to the list specific to this file
//                     fileNames.add(newFileName);
//
//                     // Create a new controller for the new file's content
//                     TextEditingController newFileController = TextEditingController();
//                     newFileControllers.add(newFileController);
//                   }
//                 });
//
//                 // Save all data to SharedPreferences, specific to this file
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Delete file method
//   Future<void> _deleteFile(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Remove file from SharedPreferences
//     await prefs.remove(fileNames[index]);
//
//     // Remove the file from the list and controller
//     setState(() {
//       fileNames.removeAt(index);
//       newFileControllers.removeAt(index);
//     });
//
//     // Update file names list in SharedPreferences
//     await prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   // Show delete confirmation dialog
//   void _showDeleteConfirmationDialog(int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Delete File"),
//           content: Text("Are you sure you want to delete '${fileNames[index]}'?"),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Cancel"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text("Delete", style: TextStyle(color: Colors.red)),
//               onPressed: () {
//                 _deleteFile(index);  // Call delete function
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Edit file name method
//   Future<void> _editFileName(int index) async {
//     TextEditingController _fileNameController = TextEditingController(text: fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Update the file name in the list
//                     fileNames[index] = newFileName;
//                   }
//                 });
//
//                 // Save updated data to SharedPreferences
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Build file item with delete and edit options
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onLongPress: () {
//         _showDeleteConfirmationDialog(index);  // Long press for delete confirmation
//       },
//       child: Card(
//         elevation: 3,
//         margin: EdgeInsets.symmetric(vertical: 8),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     fileNames[index],
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.edit, color: Colors.orange), // Edit button
//                         onPressed: () {
//                           _editFileName(index); // Show dialog to edit file name
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               TextField(
//                 controller: newFileControllers[index],
//                 maxLines: null,
//                 keyboardType: TextInputType.multiline,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   hintText: 'Enter content...',
//                 ),
//                 onChanged: (text) {
//                   _saveData();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileName), // Display the original file name in the AppBar
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // The original file's note (TextField for the initial file)
//                 TextField(
//                   controller: widget.noteController,
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     labelText: 'Edit your note',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (text) {
//                     _saveData();
//                   },
//                 ),
//                 // Dynamically created new file content TextFields below the original one
//                 ...List.generate(fileNames.length, (index) {
//                   return _buildFileItem(index);  // Use the method for each file
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
//
//
//
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//   bool _isGridView = false;
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   // Load the notes from SharedPreferences
//   void _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     int minLength = savedFileNames.length < savedFileContents.length
//         ? savedFileNames.length
//         : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents
//           .take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//       _filteredFileNames = List.from(_fileNames);
//       _filteredNoteControllers = List.from(_noteControllers);
//     });
//
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {});
//       });
//     }
//   }
//
//
//   // Delete selected files
//   Future<void> _deleteSelectedFiles() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     List<String> newFileNames = [];
//     List<String> newFileContents = [];
//
//     setState(() {
//       for (int i = 0; i < _fileNames.length; i++) {
//         if (!_selectedFiles[i]) {
//           newFileNames.add(_fileNames[i]);
//           newFileContents.add(_noteControllers[i].text);
//         }
//       }
//
//       _fileNames = List.from(newFileNames);
//       _noteControllers = newFileContents
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(_fileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(_fileNames.length, (_) => false);
//
//       _isInSelectionMode = false;
//     });
//
//     // अपडेटेड डेटा को SharedPreferences में सेव करें
//     await prefs.setStringList('fileNames', newFileNames);
//     await prefs.setStringList('fileContents', newFileContents);
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//     String _errorMessage = ''; // Variable to store error message
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder( // Use StatefulBuilder to allow for state changes inside the dialog
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15), // Rounded corners for the dialog
//               ),
//               elevation: 10, // Add shadow for better depth
//               title: Text(
//                 "Enter File Name",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent, // Better title styling
//                 ),
//               ),
//               content: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min, // Make sure content adjusts to fit
//                   children: [
//                     TextField(
//                       controller: _fileNameController,
//                       decoration: InputDecoration(
//                         hintText: "Enter new file name",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12), // Rounded corners
//                           borderSide: BorderSide(color: Colors.blueAccent), // Border color
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.blueAccent),
//                         ),
//                         contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//                       ),
//                       autofocus: true, // Autofocus for quick typing
//                       maxLength: 10, // Limit the file name to 20 characters
//                       // maxLengthEnforced: true, // Enforce the maximum length
//                     ),
//                     SizedBox(height: 10), // Add spacing between TextField and error message
//
//                     // Show error message if present
//                     if (_errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 10.0), // Space between error and button
//                         child: Text(
//                           _errorMessage,
//                           style: TextStyle(
//                             color: Colors.redAccent,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextButton(
//                     style: TextButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12), // Rounded button
//                       ),
//                       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button padding
//                     ),
//                     onPressed: () {
//                       String newFileName = _fileNameController.text.trim();
//
//                       // Check if file name is empty
//                       if (newFileName.isEmpty) {
//                         setState(() {
//                           _errorMessage = "File name cannot be empty!"; // Set error message
//                         });
//                         return;
//                       }
//
//                       // Convert file names to lowercase for case-insensitive comparison
//                       bool fileExists = _fileNames.any(
//                               (file) => file.toLowerCase() == newFileName.toLowerCase());
//
//                       if (fileExists) {
//                         setState(() {
//                           _errorMessage = "A file with this name already exists!"; // Set error message
//                         });
//                         return;
//                       }
//
//                       setState(() {
//                         _errorMessage = ''; // Clear error message if no error
//                         _fileNames.insert(0, newFileName);
//                         TextEditingController newController = TextEditingController();
//                         newController.addListener(() {
//                           setState(() {});
//                         });
//
//                         _noteControllers.insert(0, newController);
//                         _focusNodes.insert(0, FocusNode());
//                         _selectedFiles.insert(0, false);
//                       });
//
//                       _filterFiles(_searchController.text); // Re-filter after adding a new file
//                       _saveAllNotes();
//                       Navigator.of(context).pop();
//                     },
//                     child: Text(
//                       'Create',
//                       style: TextStyle(color: Colors.white, fontSize: 16), // Button text style
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // Toggle selection of files
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//   // Save all notes to SharedPreferences
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//         _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   // Show dialog to edit file name
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//         TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _fileNames[index] = _fileNameController.text;
//                 });
//
//                 _filterFiles(_searchController
//                     .text); // Re-filter after editing the file name
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openFileDetails(int index) {
//     print("Opening file at index: $index");
//     print("Filtered file names: $_filteredFileNames");
//     print("Filtered note controllers length: ${_filteredNoteControllers.length}");
//
//     if (index < 0 || index >= _filteredFileNames.length) {
//       print("Error: Invalid index $index!");
//       return;
//     }
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _filteredFileNames[index],
//           noteController: _filteredNoteControllers[index],
//         ),
//       ),
//     ).then((_) {
//       setState(() {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//         _isInSelectionMode = false;
//         _searchController.clear();
//         _filterFiles(""); // Reset filtered list
//       });
//     });
//   }
//
//
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = List.from(_fileNames);
//         _filteredNoteControllers = List.from(_noteControllers);
//       } else {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//
//         for (int i = 0; i < _fileNames.length; i++) {
//           if (_fileNames[i].toLowerCase().contains(query.toLowerCase())) {
//             _filteredFileNames.add(_fileNames[i]);
//             _filteredNoteControllers.add(_noteControllers[i]);
//           }
//         }
//       }
//
//       // अगर फ़िल्टर के बाद कोई फ़ाइल नहीं बची तो सेलेक्शन मोड बंद कर दें।
//       if (_filteredFileNames.isEmpty) {
//         _isInSelectionMode = false;
//       }
//
//       // हमेशा चयनित फ़ाइलें रीसेट करें
//       _selectedFiles = List.generate(_fileNames.length, (_) => false);
//     });
//   }
//
//   void _selectAllFiles() {
//     setState(() {
//       bool allSelected = _selectedFiles.every((selected) => selected);
//       if (allSelected) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//         _isInSelectionMode = false;
//       } else {
//         _selectedFiles = List.generate(_fileNames.length, (_) => true);
//         _isInSelectionMode = true;
//       }
//     });
//   }
//
// // Toggle selection mode
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       // Keep the selection mode active after the second long press if any files are selected
//       if (!_isInSelectionMode && !_selectedFiles.contains(true)) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   // Toggle between grid and list view
//   void _toggleView() {
//     setState(() {
//       _isGridView = !_isGridView;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 4,
//         shadowColor: Colors.black26,
//         title: Text(
//           "Notepad",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.blueAccent, size: 28),
//             onPressed: () async {
//               final selectedFile = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchScreen(
//                     fileNames: _fileNames,
//                     noteControllers: _noteControllers,
//                   ),
//                 ),
//               );
//
//               if (selectedFile != null) {
//                 int index = _fileNames.indexOf(selectedFile);
//                 _openFileDetails(index);
//               }
//             },
//             tooltip: "Search Notes",
//           ),
//           IconButton(
//             icon: Icon(
//               _isGridView ? Icons.view_list : Icons.grid_view,
//               color: Colors.blueAccent,
//               size: 28,
//             ),
//             onPressed: _toggleView,
//             tooltip: 'Toggle View',
//           ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.select_all, color: Colors.orange, size: 28),
//               onPressed: _selectAllFiles,
//               tooltip: 'Select All',
//             ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//           SizedBox(width: 10), // Extra spacing for better UI
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           // Deselect all files when the user taps outside
//           if (_isInSelectionMode) {
//             setState(() {
//               _selectedFiles = List.generate(_fileNames.length, (_) => false);
//               _isInSelectionMode = false;
//             });
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: _isGridView ? _buildGridView() : _buildListView(),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         backgroundColor: Colors.blueAccent,
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: AnimatedSwitcher(
//           duration: Duration(milliseconds: 400),
//           transitionBuilder: (child, animation) => ScaleTransition(
//             scale: animation,
//             child: child,
//           ),
//           child: Icon(
//             Icons.add,
//             key: ValueKey<int>(1),
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Build ListView
//   Widget _buildListView() {
//     List<int> sortedIndexes =
//     List.generate(_fileNames.length, (index) => index);
//
//     return ListView.builder(
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 11.0), // Increase bottom padding
//           child: _buildFileItem(sortedIndexes[index]),
//         );
//       },
//     );
//   }
//
//
//   // Build GridView
//   Widget _buildGridView() {
//     List<int> sortedIndexes =
//         List.generate(_fileNames.length, (index) => index);
//
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 2.5,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//   // Build each file item in the list/grid
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onLongPress: () {
//         if (!_isInSelectionMode) {
//           _toggleSelectionMode(); // Enable selection mode
//           _toggleSelection(index); // Select the first file
//         }
//       },
//       onTap: () {
//         if (_isInSelectionMode) {
//           _toggleSelection(index); // Allow single tap selection after long press
//         } else {
//           _openFileDetails(index); // Open file if not in selection mode
//         }
//       },
//
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(11),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.description, color: Colors.blueAccent),
//                   SizedBox(width: 5),
//                   Expanded(
//                     child: Text(
//                       '${_filteredFileNames[index]}',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'Edit') {
//                         _showEditFileNameDialog(index);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => [
//                       PopupMenuItem(
//                         value: 'Edit',
//                         child: Row(
//                           children: [
//                             Icon(Icons.edit, color: Colors.blue),
//                             SizedBox(width: 10),
//                             Text('Edit'),
//                           ],
//                         ),
//                       ),
//                     ],
//                     child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                   ),
//                 ],
//               ),
//               Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 11 * 8.0),
//                   child: Text(
//                     index < _filteredNoteControllers.length &&
//                         _filteredNoteControllers[index].text.isNotEmpty
//                         ? _filteredNoteControllers[index].text
//                         : 'Add title...',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade800,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
// }
//
// class SearchScreen extends StatefulWidget {
//   final List<String> fileNames;
//   final List<TextEditingController> noteControllers;
//
//   SearchScreen({required this.fileNames, required this.noteControllers});
//
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//       } else {
//         _filteredFileNames = widget.fileNames
//             .where((fileName) =>
//                 fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = widget.fileNames.indexOf(fileName);
//           return widget.noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 6,
//         title: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: "Search files...",
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               border: InputBorder.none,
//               icon: Icon(Icons.search, color: Colors.blueAccent),
//             ),
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//         ),
//       ),
//       body: _filteredFileNames.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.search_off, color: Colors.grey[400], size: 60),
//                   SizedBox(height: 16),
//                   Text(
//                     "No files found. Try searching...",
//                     style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               itemCount: _filteredFileNames.length,
//               itemBuilder: (context, index) {
//                 return InkWell(
//                   onTap: () {
//                     Navigator.pop(context, _filteredFileNames[index]);
//                   },
//                   child: AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     padding: EdgeInsets.all(16),
//                     margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.description, color: Colors.blueAccent),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 _filteredFileNames[index],
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 _filteredNoteControllers[index].text.isNotEmpty
//                                     ? _filteredNoteControllers[index]
//                                         .text
//                                         .split("\n")
//                                         .take(2)
//                                         .join("\n")
//                                     : "Add title...",
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(Icons.arrow_forward_ios,
//                             color: Colors.grey[600], size: 20),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = [];
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     newFileControllers.clear();
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController =
//         TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//       }
//     }
//
//     setState(() {});
//   }
//
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//     String _errorMessage = '';
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 10,
//               title: Text(
//                 "Enter File Name",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent,
//                 ),
//               ),
//               content: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: _fileNameController,
//                       decoration: InputDecoration(
//                         hintText: "Enter new file name",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.blueAccent),
//                         ),
//                       ),
//                       autofocus: true,
//                       maxLength: 10,
//                     ),
//                     SizedBox(height: 10),
//                     if (_errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 10.0),
//                         child: Text(
//                           _errorMessage,
//                           style: TextStyle(
//                             color: Colors.redAccent,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage = "File name cannot be empty!";
//                       });
//                       return;
//                     }
//
//                     bool fileExists = fileNames.any(
//                             (file) => file.toLowerCase() == newFileName.toLowerCase());
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage = "A file with this name already exists!";
//                       });
//                       return;
//                     }
//
//                     setState(() {
//                       _errorMessage = '';
//                       fileNames.insert(0, newFileName);
//                       TextEditingController newController = TextEditingController();
//                       newFileControllers.insert(0, newController);
//                     });
//
//                     // Save data and reload to reflect changes
//                     _saveData();
//                     _loadData(); // Reload data to ensure the UI is updated
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     'Create',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> _deleteFile(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(fileNames[index]);
//
//     setState(() {
//       fileNames.removeAt(index);
//       newFileControllers.removeAt(index);
//     });
//
//     await prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   void _showDeleteConfirmationDialog(int index) {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//       return AlertDialog(
//               title: Text("Delete File"),
//         content: Text("Are you sure you want to delete '${fileNames[index]}'?"),
//         actions: <Widget>[
//           TextButton(
//             child: Text("Cancel"),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: Text("Delete", style: TextStyle(color: Colors.red)),
//             onPressed: () {
//               _deleteFile(index);
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//         },
//     );
//   }
//
//   Future<void> _editFileName(int index) async {
//     TextEditingController _fileNameController =
//     TextEditingController(text: fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     // Update the file name in the list
//                     fileNames[index] = newFileName;
//                   }
//                 });
//
//                 // Save updated data to SharedPreferences
//                 _saveData();
//
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onLongPress: () {
//         _showDeleteConfirmationDialog(index);
//       },
//       child: Column(
//         children: [
//           SizedBox(height: 11),
//           Container(
//             padding: EdgeInsets.all(11),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//               border: Border.all(color: Colors.grey.shade300, width: 1.5),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Row(
//                         children: [
//                           Text(
//                             fileNames[index],
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20,
//                               color: Colors.black87,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.edit, color: Colors.orange, size: 19),
//                             onPressed: () {
//                               _editFileName(index);
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 6),
//                 TextField(
//                   controller: newFileControllers[index],
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     border: InputBorder.none,
//                     hintText: 'Write your notes...',
//                     hintStyle: TextStyle(color: Colors.black54),
//                   ),
//                   onChanged: (text) {
//                     _saveData();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileName),
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: widget.noteController,
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     labelText: 'Your note’s title...',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (text) {
//                     _saveData();
//                   },
//                 ),
//                 ...List.generate(fileNames.length, (index) {
//                   return _buildFileItem(index);
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         backgroundColor: Colors.blueAccent,
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Icon(
//           Icons.add,
//           size: 30,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//   bool _isGridView = false;
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   // Load the notes from SharedPreferences
//   void _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     int minLength = savedFileNames.length < savedFileContents.length
//         ? savedFileNames.length
//         : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents
//           .take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//       _filteredFileNames = List.from(_fileNames);
//       _filteredNoteControllers = List.from(_noteControllers);
//     });
//
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {});
//       });
//     }
//   }
//
//   // Delete selected files
//   Future<void> _deleteSelectedFiles() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     List<String> newFileNames = [];
//     List<String> newFileContents = [];
//
//     setState(() {
//       for (int i = 0; i < _fileNames.length; i++) {
//         if (!_selectedFiles[i]) {
//           newFileNames.add(_fileNames[i]);
//           newFileContents.add(_noteControllers[i].text);
//         }
//       }
//
//       _fileNames = List.from(newFileNames);
//       _noteControllers = newFileContents
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(_fileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(_fileNames.length, (_) => false);
//
//       _isInSelectionMode = false;
//     });
//
//     // अपडेटेड डेटा को SharedPreferences में सेव करें
//     await prefs.setStringList('fileNames', newFileNames);
//     await prefs.setStringList('fileContents', newFileContents);
//   }

//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//     String _errorMessage = ''; // Variable to store error message
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           // Use StatefulBuilder to allow for state changes inside the dialog
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(15), // Rounded corners for the dialog
//               ),
//               elevation: 10, // Add shadow for better depth
//               title: Text(
//                 "Enter File Name",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent, // Better title styling
//                 ),
//               ),
//               content: Column(
//                 mainAxisSize:
//                     MainAxisSize.min, // Make sure content adjusts to fit
//                 children: [
//                   TextField(
//                     controller: _fileNameController,
//                     decoration: InputDecoration(
//                       hintText: "Enter new file name",
//                       border: OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(12), // Rounded corners
//                         borderSide: BorderSide(
//                             color: Colors.blueAccent), // Border color
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.blueAccent),
//                       ),
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//                     ),
//                     autofocus: true, // Autofocus for quick typing
//                     maxLength: 10, // Limit the file name to 20 characters
//                     // maxLengthEnforced: true, // Enforce the maximum length
//                   ),
//                   SizedBox(
//                       height:
//                           10), // Add spacing between TextField and error message
//
//                   // Show error message if present
//                   if (_errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           bottom: 10.0), // Space between error and button
//                       child: Text(
//                         _errorMessage,
//                         style: TextStyle(
//                           color: Colors.redAccent,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12), // Rounded button
//                     ),
//                     padding: EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 12), // Button padding
//                   ),
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     // Check if file name is empty
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage =
//                             "File name cannot be empty!"; // Set error message
//                       });
//                       return;
//                     }
//
//                     // Convert file names to lowercase for case-insensitive comparison
//                     bool fileExists = _fileNames.any((file) =>
//                         file.toLowerCase() == newFileName.toLowerCase());
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage =
//                             "A file with this name already exists!"; // Set error message
//                       });
//                       return;
//                     }
//
//                     setState(() {
//                       _errorMessage = ''; // Clear error message if no error
//                       _fileNames.insert(0, newFileName);
//                       TextEditingController newController =
//                           TextEditingController();
//                       newController.addListener(() {
//                         setState(() {});
//                       });
//
//                       _noteControllers.insert(0, newController);
//                       _focusNodes.insert(0, FocusNode());
//                       _selectedFiles.insert(0, false);
//                     });
//
//                     _filterFiles(_searchController
//                         .text); // Re-filter after adding a new file
//                     _saveAllNotes();
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     'Create',
//                     style: TextStyle(
//                         color: Colors.white, fontSize: 16), // Button text style
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // Toggle selection of files
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//   // Save all notes to SharedPreferences
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//         _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   // Show dialog to edit file name
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//         TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _fileNames[index] = _fileNameController.text;
//                 });
//
//                 _filterFiles(_searchController
//                     .text); // Re-filter after editing the file name
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openFileDetails(int index) {
//     print("Opening file at index: $index");
//     print("Filtered file names: $_filteredFileNames");
//     print(
//         "Filtered note controllers length: ${_filteredNoteControllers.length}");
//
//     if (index < 0 || index >= _filteredFileNames.length) {
//       print("Error: Invalid index $index!");
//       return;
//     }
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _filteredFileNames[index],
//           noteController: _filteredNoteControllers[index],
//         ),
//       ),
//     ).then((_) {
//       setState(() {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//         _isInSelectionMode = false;
//         _searchController.clear();
//         _filterFiles(""); // Reset filtered list
//       });
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = List.from(_fileNames);
//         _filteredNoteControllers = List.from(_noteControllers);
//       } else {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//
//         for (int i = 0; i < _fileNames.length; i++) {
//           if (_fileNames[i].toLowerCase().contains(query.toLowerCase())) {
//             _filteredFileNames.add(_fileNames[i]);
//             _filteredNoteControllers.add(_noteControllers[i]);
//           }
//         }
//       }
//
//       // अगर फ़िल्टर के बाद कोई फ़ाइल नहीं बची तो सेलेक्शन मोड बंद कर दें।
//       if (_filteredFileNames.isEmpty) {
//         _isInSelectionMode = false;
//       }
//
//       // हमेशा चयनित फ़ाइलें रीसेट करें
//       _selectedFiles = List.generate(_fileNames.length, (_) => false);
//     });
//   }
//
//   void _selectAllFiles() {
//     setState(() {
//       bool allSelected = _selectedFiles.every((selected) => selected);
//       if (allSelected) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//         _isInSelectionMode = false;
//       } else {
//         _selectedFiles = List.generate(_fileNames.length, (_) => true);
//         _isInSelectionMode = true;
//       }
//     });
//   }
//
// // Toggle selection mode
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       // Keep the selection mode active after the second long press if any files are selected
//       if (!_isInSelectionMode && !_selectedFiles.contains(true)) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   // Toggle between grid and list view
//   void _toggleView() {
//     setState(() {
//       _isGridView = !_isGridView;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 4,
//         shadowColor: Colors.black26,
//         title: Text(
//           "Notepad",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.blueAccent, size: 28),
//             onPressed: () async {
//               final selectedFile = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchScreen(
//                     fileNames: _fileNames,
//                     noteControllers: _noteControllers,
//                   ),
//                 ),
//               );
//
//               if (selectedFile != null) {
//                 int index = _fileNames.indexOf(selectedFile);
//                 _openFileDetails(index);
//               }
//             },
//             tooltip: "Search Notes",
//           ),
//           IconButton(
//             icon: Icon(
//               _isGridView ? Icons.view_list : Icons.grid_view,
//               color: Colors.blueAccent,
//               size: 28,
//             ),
//             onPressed: _toggleView,
//             tooltip: 'Toggle View',
//           ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.select_all, color: Colors.orange, size: 28),
//               onPressed: _selectAllFiles,
//               tooltip: 'Select All',
//             ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//           SizedBox(width: 10), // Extra spacing for better UI
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           // Deselect all files when the user taps outside
//           if (_isInSelectionMode) {
//             setState(() {
//               _selectedFiles = List.generate(_fileNames.length, (_) => false);
//               _isInSelectionMode = false;
//             });
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: _isGridView ? _buildGridView() : _buildListView(),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         backgroundColor: Colors.blueAccent,
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: AnimatedSwitcher(
//           duration: Duration(milliseconds: 400),
//           transitionBuilder: (child, animation) => ScaleTransition(
//             scale: animation,
//             child: child,
//           ),
//           child: Icon(
//             Icons.add,
//             key: ValueKey<int>(1),
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Build ListView
//   Widget _buildListView() {
//     List<int> sortedIndexes =
//         List.generate(_fileNames.length, (index) => index);
//
//     return ListView.builder(
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding:
//               const EdgeInsets.only(bottom: 11.0), // Increase bottom padding
//           child: _buildFileItem(sortedIndexes[index]),
//         );
//       },
//     );
//   }
//
//   // Build GridView
//   Widget _buildGridView() {
//     List<int> sortedIndexes =
//         List.generate(_fileNames.length, (index) => index);
//
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 2.5,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//   // Build each file item in the list/grid
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onLongPress: () {
//         if (!_isInSelectionMode) {
//           _toggleSelectionMode(); // Enable selection mode
//           _toggleSelection(index); // Select the first file
//         }
//       },
//       onTap: () {
//         if (_isInSelectionMode) {
//           _toggleSelection(
//               index); // Allow single tap selection after long press
//         } else {
//           _openFileDetails(index); // Open file if not in selection mode
//         }
//       },
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(11),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.description, color: Colors.blueAccent),
//                   SizedBox(width: 5),
//                   Expanded(
//                     child: Text(
//                       '${_filteredFileNames[index]}',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'Edit') {
//                         _showEditFileNameDialog(index);
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => [
//                       PopupMenuItem(
//                         value: 'Edit',
//                         child: Row(
//                           children: [
//                             Icon(Icons.edit, color: Colors.blue),
//                             SizedBox(width: 10),
//                             Text('Edit'),
//                           ],
//                         ),
//                       ),
//                     ],
//                     child: Icon(Icons.more_vert, color: Colors.grey.shade700),
//                   ),
//                 ],
//               ),
//               Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 11 * 8.0),
//                   child: Text(
//                     index < _filteredNoteControllers.length &&
//                             _filteredNoteControllers[index].text.isNotEmpty
//                         ? _filteredNoteControllers[index].text
//                         : 'Add title...',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade800,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SearchScreen extends StatefulWidget {
//   final List<String> fileNames;
//   final List<TextEditingController> noteControllers;
//
//   SearchScreen({required this.fileNames, required this.noteControllers});
//
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//   FocusNode _searchFocusNode = FocusNode(); // FocusNode
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//
//     // Automatically focus on the search field when the screen is loaded
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_searchFocusNode);
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//       } else {
//         _filteredFileNames = widget.fileNames
//             .where((fileName) =>
//                 fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = widget.fileNames.indexOf(fileName);
//           return widget.noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 6,
//         title: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: _searchController,
//             focusNode: _searchFocusNode, // Set the focus node here
//             decoration: InputDecoration(
//               hintText: "Search files...",
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               border: InputBorder.none,
//               icon: Icon(Icons.search, color: Colors.blueAccent),
//             ),
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//         ),
//       ),
//       body: _filteredFileNames.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.search_off, color: Colors.grey[400], size: 60),
//                   SizedBox(height: 16),
//                   Text(
//                     "No files found. Try searching...",
//                     style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               itemCount: _filteredFileNames.length,
//               itemBuilder: (context, index) {
//                 return InkWell(
//                   onTap: () {
//                     Navigator.pop(context, _filteredFileNames[index]);
//                   },
//                   child: AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     padding: EdgeInsets.all(16),
//                     margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.description, color: Colors.blueAccent),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 _filteredFileNames[index],
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 _filteredNoteControllers[index].text.isNotEmpty
//                                     ? _filteredNoteControllers[index]
//                                         .text
//                                         .split("\n")
//                                         .take(1)
//                                         .join("\n")
//                                     : "Add title...",
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 16,
//                                   color: Colors.grey.shade800,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(Icons.arrow_forward_ios,
//                             color: Colors.grey[600], size: 20),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = [];
//   List<FocusNode> focusNodes = [];
//   List<bool> _selectedFiles = []; // To track the selection of files
//   bool _isInSelectionMode = false; // Flag to track if we are in selection mode
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     _selectedFiles = List.generate(
//         fileNames.length, (_) => false); // Initialize selection list
//     newFileControllers.clear();
//     focusNodes.clear(); // Clear focus nodes
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController =
//             TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//
//         FocusNode newFocusNode = FocusNode();
//         focusNodes.add(newFocusNode); // Add a FocusNode for the new file
//       }
//     }
//
//     setState(() {});
//   }
//
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   Future<void> _deleteSelectedFiles() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     List<String> newFileNames = [];
//     List<String> newFileContents = [];
//
//     setState(() {
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         if (!_selectedFiles[i]) {
//           newFileNames.add(fileNames[i]);
//           newFileContents.add(newFileControllers[i].text);
//         }
//       }
//
//       fileNames = List.from(newFileNames);
//       newFileControllers = newFileContents
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       focusNodes = List.generate(fileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(fileNames.length, (_) => false);
//       _isInSelectionMode = false;
//     });
//
//     // Update the data in SharedPreferences
//     await prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//     for (int i = 0; i < newFileControllers.length; i++) {
//       await prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//   }
//
//   void _selectAllFiles() {
//     setState(() {
//       // Select all files
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         _selectedFiles[i] = true;
//       }
//     });
//   }
//
//   void _deselectAllFiles() {
//     setState(() {
//       // Deselect all files and disable selection mode
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         _selectedFiles[i] = false;
//       }
//       _isInSelectionMode = false; // Disable selection mode
//     });
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//     String _errorMessage = '';
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 10,
//               title: Text(
//                 "Enter File Name",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent,
//                 ),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: _fileNameController,
//                     decoration: InputDecoration(
//                       hintText: "Enter new file name",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.blueAccent),
//                       ),
//                     ),
//                     autofocus: true,
//                     maxLength: 10,
//                   ),
//                   SizedBox(height: 10),
//                   if (_errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 10.0),
//                       child: Text(
//                         _errorMessage,
//                         style: TextStyle(
//                           color: Colors.redAccent,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage = "File name cannot be empty!";
//                       });
//                       return;
//                     }
//
//                     bool fileExists = fileNames.any((file) =>
//                         file.toLowerCase() == newFileName.toLowerCase());
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage = "A file with this name already exists!";
//                       });
//                       return;
//                     }
//
//                     setState(() {
//                       _errorMessage = '';
//                       fileNames.insert(0, newFileName);
//                       TextEditingController newController =
//                           TextEditingController();
//                       newFileControllers.insert(0, newController);
//                       FocusNode newFocusNode = FocusNode();
//                       focusNodes.insert(0, newFocusNode);
//                       _selectedFiles.insert(
//                           0, false); // Initialize selection state
//                     });
//
//                     // Save data and reload to reflect changes
//                     _saveData();
//                     _loadData(); // Reload data to ensure the UI is updated
//
//                     // Use Future.delayed to ensure the widget tree is stable
//                     Future.delayed(Duration(milliseconds: 200), () {
//                       if (focusNodes.isNotEmpty) {
//                         FocusScope.of(context).requestFocus(focusNodes[0]);
//                       }
//                     });
//
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     'Create',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> _editFileName(int index) async {
//     TextEditingController _fileNameController =
//         TextEditingController(text: fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     fileNames[index] = newFileName;
//                   }
//                 });
//
//                 _saveData();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onLongPress: () {
//         // Sirf tabhi chale jab selection mode inactive ho
//         if (!_isInSelectionMode) {
//           setState(() {
//             _isInSelectionMode = true; // Selection mode enable
//             _selectedFiles[index] = true; // Pehli file automatically select
//           });
//         }
//       },
//       onTap: () {
//         // Sirf tabhi chale jab selection mode active ho
//         if (_isInSelectionMode) {
//           setState(() {
//             _selectedFiles[index] = !_selectedFiles[index]; // Toggle selection
//
//             // Agar sari files unselect ho gayi, to selection mode off karna hai
//             bool anyFileSelected = _selectedFiles.contains(true);
//             if (!anyFileSelected) {
//               _isInSelectionMode = false; // Selection mode disable
//             }
//           });
//         }
//       },
//
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(11),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Row(
//                     children: [
//                       Text(
//                         fileNames[index],
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                           color: Colors.black87,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.edit, color: Colors.orange, size: 19),
//                         onPressed: () {
//                           _editFileName(index);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 6),
//             TextField(
//               controller: newFileControllers[index],
//               focusNode: focusNodes[index], // Set the FocusNode here
//               maxLines: null,
//               keyboardType: TextInputType.multiline,
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 hintText: 'Write your notes...',
//                 hintStyle: TextStyle(color: Colors.black54),
//               ),
//               onChanged: (text) {
//                 _saveData();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (_isInSelectionMode) {
//           setState(() {
//             _isInSelectionMode = false;
//             _selectedFiles =
//                 List.generate(fileNames.length, (_) => false); // Deselect all
//           });
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white, // Background color
//           elevation: 4, // Shadow elevation
//           shadowColor: Colors.black26, // Shadow color
//           title: Row(
//             children: [
//               Text(
//                 widget.fileName,
//                 style: TextStyle(
//                   color: Colors.blue, // Title color
//                   fontWeight: FontWeight.bold, // Bold font
//                   fontSize: 22, // Increased font size
//                 ),
//               ),
//               Text("  -", style: TextStyle(color: Colors.blue)),
//             ],
//           ),
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios,
//                 color: Colors.blue), // Back button color
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           actions: [
//             // Select/Deselect All button - toggles between selecting and deselecting all files
//             if (_isInSelectionMode)
//               IconButton(
//                 icon: Icon(
//                   _selectedFiles.every((selected) => selected) // Check if all are selected
//                       ? Icons.clear_all // Show Deselect All when all files are selected
//                       : Icons.select_all, // Show Select All when not all files are selected
//                   color: Colors.orange,
//                   size: 28,
//                 ),
//                 onPressed: () {
//                   if (_selectedFiles.every((selected) => selected)) {
//                     _deselectAllFiles(); // Unselect all files
//                   } else {
//                     _selectAllFiles(); // Select all files
//                   }
//                 },
//                 tooltip: _selectedFiles.every((selected) => selected)
//                     ? 'Deselect All' // Tooltip when all files are selected
//                     : 'Select All', // Tooltip when not all files are selected
//               ),
//             // Delete button - only shows if some files are selected
//             if (_isInSelectionMode && _selectedFiles.any((selected) => selected))
//               IconButton(
//                 icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//                 onPressed: _deleteSelectedFiles,
//                 tooltip: 'Delete Selected Files',
//               ),
//             SizedBox(width: 10), // Extra spacing for better UI
//           ],
//
//         ),
//         body: Stack(
//           children: [
//             // GestureDetector for empty space
//             GestureDetector(
//               behavior: HitTestBehavior
//                   .translucent, // Only detects taps on empty areas
//               onTap: () {
//                 widget.noteController.selection = TextSelection.fromPosition(
//                   TextPosition(offset: widget.noteController.text.length),
//                 );
//                 FocusScope.of(context)
//                     .requestFocus(FocusNode()); // Move cursor to TextField
//               },
//               child: Container(), // Ensures GestureDetector covers the background
//             ),
//
//             // Main ListView Content
//             ListView(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       TextField(
//                         controller: widget.noteController,
//                         maxLines: null,
//                         keyboardType: TextInputType.multiline,
//                         decoration: InputDecoration(
//                           labelText: 'Your note’s title...',
//                           border: OutlineInputBorder(),
//                         ),
//
//                         onChanged: (text) {
//                           _saveData();
//                         },
//                       ),
//                       ...List.generate(fileNames.length, (index) {
//                         return _buildFileItem(
//                             index); // Long press functionality will remain unchanged
//                       }),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: _showCreateFileDialog,
//           backgroundColor: Colors.blueAccent,
//           elevation: 10,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           child: Icon(
//             Icons.add,
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//   bool _isGridView = false;
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   // Load the notes from SharedPreferences
//   void _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     int minLength = savedFileNames.length < savedFileContents.length
//         ? savedFileNames.length
//         : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents
//           .take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//       _filteredFileNames = List.from(_fileNames);
//       _filteredNoteControllers = List.from(_noteControllers);
//     });
//
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {});
//       });
//     }
//   }
//
//   // Delete selected files
//   Future<void> _deleteSelectedFiles() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     List<String> newFileNames = [];
//     List<String> newFileContents = [];
//
//     setState(() {
//       for (int i = 0; i < _fileNames.length; i++) {
//         if (!_selectedFiles[i]) {
//           newFileNames.add(_fileNames[i]);
//           newFileContents.add(_noteControllers[i].text);
//         }
//       }
//
//       _fileNames = List.from(newFileNames);
//       _noteControllers = newFileContents
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(_fileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(_fileNames.length, (_) => false);
//
//       _isInSelectionMode = false;
//     });
//
//     // अपडेटेड डेटा को SharedPreferences में सेव करें
//     await prefs.setStringList('fileNames', newFileNames);
//     await prefs.setStringList('fileContents', newFileContents);
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//     String _errorMessage = ''; // Variable to store error message
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           // Use StatefulBuilder to allow for state changes inside the dialog
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(15), // Rounded corners for the dialog
//               ),
//               elevation: 10, // Add shadow for better depth
//               title: Text(
//                 "Enter File Name",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent, // Better title styling
//                 ),
//               ),
//               content: Column(
//                 mainAxisSize:
//                     MainAxisSize.min, // Make sure content adjusts to fit
//                 children: [
//                   TextField(
//                     controller: _fileNameController,
//                     decoration: InputDecoration(
//                       hintText: "Enter new file name",
//                       border: OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(12), // Rounded corners
//                         borderSide: BorderSide(
//                             color: Colors.blueAccent), // Border color
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.blueAccent),
//                       ),
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//                     ),
//                     autofocus: true, // Autofocus for quick typing
//                     maxLength: 10, // Limit the file name to 20 characters
//                     // maxLengthEnforced: true, // Enforce the maximum length
//                   ),
//                   SizedBox(
//                       height:
//                           10), // Add spacing between TextField and error message
//
//                   // Show error message if present
//                   if (_errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           bottom: 10.0), // Space between error and button
//                       child: Text(
//                         _errorMessage,
//                         style: TextStyle(
//                           color: Colors.redAccent,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12), // Rounded button
//                     ),
//                     padding: EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 12), // Button padding
//                   ),
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     // Check if file name is empty
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage =
//                             "File name cannot be empty!"; // Set error message
//                       });
//                       return;
//                     }
//
//                     // Convert file names to lowercase for case-insensitive comparison
//                     bool fileExists = _fileNames.any((file) =>
//                         file.toLowerCase() == newFileName.toLowerCase());
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage =
//                             "A file with this name already exists!"; // Set error message
//                       });
//                       return;
//                     }
//
//                     setState(() {
//                       _errorMessage = ''; // Clear error message if no error
//                       _fileNames.insert(0, newFileName);
//                       TextEditingController newController =
//                           TextEditingController();
//                       newController.addListener(() {
//                         setState(() {});
//                       });
//
//                       _noteControllers.insert(0, newController);
//                       _focusNodes.insert(0, FocusNode());
//                       _selectedFiles.insert(0, false);
//                     });
//
//                     _filterFiles(_searchController
//                         .text); // Re-filter after adding a new file
//                     _saveAllNotes();
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     'Create',
//                     style: TextStyle(
//                         color: Colors.white, fontSize: 16), // Button text style
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // Toggle selection of files
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//   // Save all notes to SharedPreferences
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//         _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   // Show dialog to edit file name
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//         TextEditingController(text: _fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Edit file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _fileNames[index] = _fileNameController.text;
//                 });
//
//                 _filterFiles(_searchController
//                     .text); // Re-filter after editing the file name
//                 _saveAllNotes();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openFileDetails(int index) {
//     print("Opening file at index: $index");
//     print("Filtered file names: $_filteredFileNames");
//     print(
//         "Filtered note controllers length: ${_filteredNoteControllers.length}");
//
//     if (index < 0 || index >= _filteredFileNames.length) {
//       print("Error: Invalid index $index!");
//       return;
//     }
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _filteredFileNames[index],
//           noteController: _filteredNoteControllers[index],
//         ),
//       ),
//     ).then((_) {
//       setState(() {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//         _isInSelectionMode = false;
//         _searchController.clear();
//         _filterFiles(""); // Reset filtered list
//       });
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = List.from(_fileNames);
//         _filteredNoteControllers = List.from(_noteControllers);
//       } else {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//
//         for (int i = 0; i < _fileNames.length; i++) {
//           if (_fileNames[i].toLowerCase().contains(query.toLowerCase())) {
//             _filteredFileNames.add(_fileNames[i]);
//             _filteredNoteControllers.add(_noteControllers[i]);
//           }
//         }
//       }
//
//       // अगर फ़िल्टर के बाद कोई फ़ाइल नहीं बची तो सेलेक्शन मोड बंद कर दें।
//       if (_filteredFileNames.isEmpty) {
//         _isInSelectionMode = false;
//       }
//
//       // हमेशा चयनित फ़ाइलें रीसेट करें
//       _selectedFiles = List.generate(_fileNames.length, (_) => false);
//     });
//   }
//
//   void _selectAllFiles() {
//     setState(() {
//       bool allSelected = _selectedFiles.every((selected) => selected);
//       if (allSelected) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//         _isInSelectionMode = false;
//       } else {
//         _selectedFiles = List.generate(_fileNames.length, (_) => true);
//         _isInSelectionMode = true;
//       }
//     });
//   }
//
// // Toggle selection mode
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       // Keep the selection mode active after the second long press if any files are selected
//       if (!_isInSelectionMode && !_selectedFiles.contains(true)) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   // Toggle between grid and list view
//   void _toggleView() {
//     setState(() {
//       _isGridView = !_isGridView;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 4,
//         shadowColor: Colors.black26,
//         title: Text(
//           "Notepad",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.blueAccent, size: 28),
//             onPressed: () async {
//               final selectedFile = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchScreen(
//                     fileNames: _fileNames,
//                     noteControllers: _noteControllers,
//                   ),
//                 ),
//               );
//
//               if (selectedFile != null) {
//                 int index = _fileNames.indexOf(selectedFile);
//                 _openFileDetails(index);
//               }
//             },
//             tooltip: "Search Notes",
//           ),
//           IconButton(
//             icon: Icon(
//               _isGridView ? Icons.view_list : Icons.grid_view,
//               color: Colors.blueAccent,
//               size: 28,
//             ),
//             onPressed: _toggleView,
//             tooltip: 'Toggle View',
//           ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.select_all, color: Colors.orange, size: 28),
//               onPressed: _selectAllFiles,
//               tooltip: 'Select All',
//             ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//           SizedBox(width: 10), // Extra spacing for better UI
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           // Deselect all files when the user taps outside
//           if (_isInSelectionMode) {
//             setState(() {
//               _selectedFiles = List.generate(_fileNames.length, (_) => false);
//               _isInSelectionMode = false;
//             });
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: _isGridView ? _buildGridView() : _buildListView(),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         backgroundColor: Colors.blueAccent,
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: AnimatedSwitcher(
//           duration: Duration(milliseconds: 400),
//           transitionBuilder: (child, animation) => ScaleTransition(
//             scale: animation,
//             child: child,
//           ),
//           child: Icon(
//             Icons.add,
//             key: ValueKey<int>(1),
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Build ListView
//   Widget _buildListView() {
//     List<int> sortedIndexes =
//         List.generate(_fileNames.length, (index) => index);
//
//     return ListView.builder(
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding:
//               const EdgeInsets.only(bottom: 11.0), // Increase bottom padding
//           child: _buildFileItem(sortedIndexes[index]),
//         );
//       },
//     );
//   }
//
//   // Build GridView
//   Widget _buildGridView() {
//     List<int> sortedIndexes =
//         List.generate(_fileNames.length, (index) => index);
//
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 2.5,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//   // Build each file item in the list/grid
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onLongPress: () {
//         if (!_isInSelectionMode) {
//           _toggleSelectionMode(); // Enable selection mode
//           _toggleSelection(index); // Select the first file
//         }
//       },
//       onTap: () {
//         if (_isInSelectionMode) {
//           _toggleSelection(
//               index); // Allow single tap selection after long press
//         } else {
//           _openFileDetails(index); // Open file if not in selection mode
//         }
//       },
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(11),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.description, color: Color(0xFFFFA500)),
//                   SizedBox(width: 5),
//                   Expanded(
//                     child: Text(
//                       '${_filteredFileNames[index]}',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.edit, color: Colors.orange, size: 19),
//                     onPressed: () {
//                       _showEditFileNameDialog(index); // Trigger the same function when this button is pressed
//                     },
//                   )
//
//                 ],
//               ),
//               Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 11 * 8.0),
//                   child: Text(
//                     index < _filteredNoteControllers.length &&
//                             _filteredNoteControllers[index].text.isNotEmpty
//                         ? _filteredNoteControllers[index].text
//                         : 'Add title...',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade800,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SearchScreen extends StatefulWidget {
//   final List<String> fileNames;
//   final List<TextEditingController> noteControllers;
//
//   SearchScreen({required this.fileNames, required this.noteControllers});
//
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//   FocusNode _searchFocusNode = FocusNode(); // FocusNode
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//
//     // Automatically focus on the search field when the screen is loaded
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_searchFocusNode);
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//       } else {
//         _filteredFileNames = widget.fileNames
//             .where((fileName) =>
//                 fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = widget.fileNames.indexOf(fileName);
//           return widget.noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 6,
//         title: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: _searchController,
//             focusNode: _searchFocusNode, // Set the focus node here
//             decoration: InputDecoration(
//               hintText: "Search files...",
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               border: InputBorder.none,
//               icon: Icon(Icons.search, color: Colors.blueAccent),
//             ),
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//         ),
//       ),
//       body: _filteredFileNames.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.search_off, color: Colors.grey[400], size: 60),
//                   SizedBox(height: 16),
//                   Text(
//                     "No files found. Try searching...",
//                     style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               itemCount: _filteredFileNames.length,
//               itemBuilder: (context, index) {
//                 return InkWell(
//                   onTap: () {
//                     Navigator.pop(context, _filteredFileNames[index]);
//                   },
//                   child: AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     padding: EdgeInsets.all(16),
//                     margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.description, color: Colors.blueAccent),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 _filteredFileNames[index],
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 _filteredNoteControllers[index].text.isNotEmpty
//                                     ? _filteredNoteControllers[index]
//                                         .text
//                                         .split("\n")
//                                         .take(1)
//                                         .join("\n")
//                                     : "Add title...",
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 16,
//                                   color: Colors.grey.shade800,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(Icons.arrow_forward_ios,
//                             color: Colors.grey[600], size: 20),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = [];
//   List<FocusNode> focusNodes = [];
//   List<bool> _selectedFiles = []; // To track the selection of files
//   bool _isInSelectionMode = false; // Flag to track if we are in selection mode
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     _selectedFiles = List.generate(
//         fileNames.length, (_) => false); // Initialize selection list
//     newFileControllers.clear();
//     focusNodes.clear(); // Clear focus nodes
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController =
//             TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//
//         FocusNode newFocusNode = FocusNode();
//         focusNodes.add(newFocusNode); // Add a FocusNode for the new file
//       }
//     }
//
//     setState(() {});
//   }
//
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   Future<void> _deleteSelectedFiles() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     List<String> newFileNames = [];
//     List<String> newFileContents = [];
//
//     setState(() {
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         if (!_selectedFiles[i]) {
//           newFileNames.add(fileNames[i]);
//           newFileContents.add(newFileControllers[i].text);
//         }
//       }
//
//       fileNames = List.from(newFileNames);
//       newFileControllers = newFileContents
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       focusNodes = List.generate(fileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(fileNames.length, (_) => false);
//       _isInSelectionMode = false;
//     });
//
//     // Update the data in SharedPreferences
//     await prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//     for (int i = 0; i < newFileControllers.length; i++) {
//       await prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//   }
//
//   void _selectAllFiles() {
//     setState(() {
//       // Select all files
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         _selectedFiles[i] = true;
//       }
//     });
//   }
//
//   void _deselectAllFiles() {
//     setState(() {
//       // Deselect all files and disable selection mode
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         _selectedFiles[i] = false;
//       }
//       _isInSelectionMode = false; // Disable selection mode
//     });
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//     String _errorMessage = '';
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 10,
//               title: Text(
//                 "Enter File Name",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent,
//                 ),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: _fileNameController,
//                     decoration: InputDecoration(
//                       hintText: "Enter new file name",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.blueAccent),
//                       ),
//                     ),
//                     autofocus: true,
//                     maxLength: 10,
//                   ),
//                   SizedBox(height: 10),
//                   if (_errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 10.0),
//                       child: Text(
//                         _errorMessage,
//                         style: TextStyle(
//                           color: Colors.redAccent,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage = "File name cannot be empty!";
//                       });
//                       return;
//                     }
//
//                     bool fileExists = fileNames.any((file) =>
//                         file.toLowerCase() == newFileName.toLowerCase());
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage = "A file with this name already exists!";
//                       });
//                       return;
//                     }
//
//                     setState(() {
//                       _errorMessage = '';
//                       fileNames.insert(0, newFileName);
//                       TextEditingController newController =
//                           TextEditingController();
//                       newFileControllers.insert(0, newController);
//                       FocusNode newFocusNode = FocusNode();
//                       focusNodes.insert(0, newFocusNode);
//                       _selectedFiles.insert(
//                           0, false); // Initialize selection state
//                     });
//
//                     // Save data and reload to reflect changes
//                     _saveData();
//                     _loadData(); // Reload data to ensure the UI is updated
//
//                     // Use Future.delayed to ensure the widget tree is stable
//                     Future.delayed(Duration(milliseconds: 200), () {
//                       if (focusNodes.isNotEmpty) {
//                         FocusScope.of(context).requestFocus(focusNodes[0]);
//                       }
//                     });
//
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     'Create',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> _editFileName(int index) async {
//     TextEditingController _fileNameController =
//         TextEditingController(text: fileNames[index]);
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit File Name"),
//           content: TextField(
//             controller: _fileNameController,
//             decoration: InputDecoration(hintText: "Enter new file name"),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   String newFileName = _fileNameController.text.trim();
//                   if (newFileName.isNotEmpty) {
//                     fileNames[index] = newFileName;
//                   }
//                 });
//
//                 _saveData();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onLongPress: () {
//         // Sirf tabhi chale jab selection mode inactive ho
//         if (!_isInSelectionMode) {
//           setState(() {
//             _isInSelectionMode = true; // Selection mode enable
//             _selectedFiles[index] = true; // Pehli file automatically select
//           });
//         }
//       },
//       onTap: () {
//         // Sirf tabhi chale jab selection mode active ho
//         if (_isInSelectionMode) {
//           setState(() {
//             _selectedFiles[index] = !_selectedFiles[index]; // Toggle selection
//
//             // Agar sari files unselect ho gayi, to selection mode off karna hai
//             bool anyFileSelected = _selectedFiles.contains(true);
//             if (!anyFileSelected) {
//               _isInSelectionMode = false; // Selection mode disable
//             }
//           });
//         }
//       },
//
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(11),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Row(
//                     children: [
//                       Text(
//                         fileNames[index],
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                           color: Colors.black87,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.edit, color: Colors.orange, size: 19),
//                         onPressed: () {
//                           _editFileName(index);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 6),
//             TextField(
//               controller: newFileControllers[index],
//               focusNode: focusNodes[index], // Set the FocusNode here
//               maxLines: null,
//               keyboardType: TextInputType.multiline,
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 hintText: 'Write your notes...',
//                 hintStyle: TextStyle(color: Colors.black54),
//               ),
//               onChanged: (text) {
//                 _saveData();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (_isInSelectionMode) {
//           setState(() {
//             _isInSelectionMode = false;
//             _selectedFiles =
//                 List.generate(fileNames.length, (_) => false); // Deselect all
//           });
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white, // Background color
//           elevation: 4, // Shadow elevation
//           shadowColor: Colors.black26, // Shadow color
//           title: Row(
//             children: [
//               Text(
//                 widget.fileName,
//                 style: TextStyle(
//                   color: Colors.blue, // Title color
//                   fontWeight: FontWeight.bold, // Bold font
//                   fontSize: 22, // Increased font size
//                 ),
//               ),
//               Text("  -", style: TextStyle(color: Colors.blue)),
//             ],
//           ),
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios,
//                 color: Colors.blue), // Back button color
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           actions: [
//             // Select/Deselect All button - toggles between selecting and deselecting all files
//             if (_isInSelectionMode)
//               IconButton(
//                 icon: Icon(
//                   _selectedFiles.every((selected) => selected) // Check if all are selected
//                       ? Icons.clear_all // Show Deselect All when all files are selected
//                       : Icons.select_all, // Show Select All when not all files are selected
//                   color: Colors.orange,
//                   size: 28,
//                 ),
//                 onPressed: () {
//                   if (_selectedFiles.every((selected) => selected)) {
//                     _deselectAllFiles(); // Unselect all files
//                   } else {
//                     _selectAllFiles(); // Select all files
//                   }
//                 },
//                 tooltip: _selectedFiles.every((selected) => selected)
//                     ? 'Deselect All' // Tooltip when all files are selected
//                     : 'Select All', // Tooltip when not all files are selected
//               ),
//             // Delete button - only shows if some files are selected
//             if (_isInSelectionMode && _selectedFiles.any((selected) => selected))
//               IconButton(
//                 icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//                 onPressed: _deleteSelectedFiles,
//                 tooltip: 'Delete Selected Files',
//               ),
//             SizedBox(width: 10), // Extra spacing for better UI
//           ],
//
//         ),
//         body: Stack(
//           children: [
//             // GestureDetector for empty space
//             GestureDetector(
//               behavior: HitTestBehavior
//                   .translucent, // Only detects taps on empty areas
//               onTap: () {
//                 widget.noteController.selection = TextSelection.fromPosition(
//                   TextPosition(offset: widget.noteController.text.length),
//                 );
//                 FocusScope.of(context)
//                     .requestFocus(FocusNode()); // Move cursor to TextField
//               },
//               child: Container(), // Ensures GestureDetector covers the background
//             ),
//
//             // Main ListView Content
//             ListView(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       TextField(
//                         controller: widget.noteController,
//                         maxLines: null,
//                         keyboardType: TextInputType.multiline,
//                         decoration: InputDecoration(
//                           labelText: 'Your note’s title...',
//                           border: OutlineInputBorder(),
//                         ),
//
//                         onChanged: (text) {
//                           _saveData();
//                         },
//                       ),
//                       ...List.generate(fileNames.length, (index) {
//                         return _buildFileItem(
//                             index); // Long press functionality will remain unchanged
//                       }),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: _showCreateFileDialog,
//           backgroundColor: Colors.blueAccent,
//           elevation: 10,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           child: Icon(
//             Icons.add,
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//   bool _isGridView = false;
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   // Load the notes from SharedPreferences
//   void _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     int minLength = savedFileNames.length < savedFileContents.length
//         ? savedFileNames.length
//         : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents
//           .take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//       _filteredFileNames = List.from(_fileNames);
//       _filteredNoteControllers = List.from(_noteControllers);
//     });
//
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {});
//       });
//     }
//   }
//
//   // Delete selected files
//   Future<void> _deleteSelectedFiles() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     List<String> newFileNames = [];
//     List<String> newFileContents = [];
//
//     setState(() {
//       for (int i = 0; i < _fileNames.length; i++) {
//         if (!_selectedFiles[i]) {
//           newFileNames.add(_fileNames[i]);
//           newFileContents.add(_noteControllers[i].text);
//         }
//       }
//
//       _fileNames = List.from(newFileNames);
//       _noteControllers = newFileContents
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(_fileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(_fileNames.length, (_) => false);
//
//       _isInSelectionMode = false;
//     });
//
//     // अपडेटेड डेटा को SharedPreferences में सेव करें
//     await prefs.setStringList('fileNames', newFileNames);
//     await prefs.setStringList('fileContents', newFileContents);
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//     String _errorMessage = ''; // Variable to store error message
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           // Use StatefulBuilder to allow for state changes inside the dialog
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(15), // Rounded corners for the dialog
//               ),
//               elevation: 10, // Add shadow for better depth
//               title: Text(
//                 "Enter File Name",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black, // Better title styling
//                 ),
//               ),
//               content: Column(
//                 mainAxisSize:
//                     MainAxisSize.min, // Make sure content adjusts to fit
//                 children: [
//                   TextField(
//                     controller: _fileNameController,
//                     decoration: InputDecoration(
//                       hintText: "Create a new file",
//                       border: OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(12), // Rounded corners
//                         borderSide: BorderSide(
//                             color: Colors.orangeAccent), // Border color
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.orange),
//                       ),
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//                     ),
//                     autofocus: true, // Autofocus for quick typing
//                     maxLength: 10, // Limit the file name to 20 characters
//                     // maxLengthEnforced: true, // Enforce the maximum length
//                   ),
//                   SizedBox(
//                       height:
//                           10), // Add spacing between TextField and error message
//
//                   // Show error message if present
//                   if (_errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           bottom: 10.0), // Space between error and button
//                       child: Text(
//                         _errorMessage,
//                         style: TextStyle(
//                           color: Colors.redAccent,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12), // Rounded button
//                     ),
//                     padding: EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 12), // Button padding
//                   ),
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     // Check if file name is empty
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage =
//                             "File name cannot be empty!"; // Set error message
//                       });
//                       return;
//                     }
//
//                     // Convert file names to lowercase for case-insensitive comparison
//                     bool fileExists = _fileNames.any((file) =>
//                         file.toLowerCase() == newFileName.toLowerCase());
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage =
//                             "A file with this name already exists!"; // Set error message
//                       });
//                       return;
//                     }
//
//                     setState(() {
//                       _errorMessage = ''; // Clear error message if no error
//                       _fileNames.insert(0, newFileName);
//                       TextEditingController newController =
//                           TextEditingController();
//                       newController.addListener(() {
//                         setState(() {});
//                       });
//
//                       _noteControllers.insert(0, newController);
//                       _focusNodes.insert(0, FocusNode());
//                       _selectedFiles.insert(0, false);
//                     });
//
//                     _filterFiles(_searchController
//                         .text); // Re-filter after adding a new file
//                     _saveAllNotes();
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     'Create',
//                     style: TextStyle(
//                         color: Colors.white, fontSize: 16), // Button text style
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // Toggle selection of files
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//   // Save all notes to SharedPreferences
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//         _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   // Show dialog to edit file name
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//     TextEditingController(text: _fileNames[index]);
//
//     // FocusNode to handle the cursor placement
//     FocusNode _focusNode = FocusNode();
//
//     String _errorMessage = ''; // Variable to store error message
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           // Use StatefulBuilder to allow for state changes inside the dialog
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15), // Rounded corners
//               ),
//               backgroundColor: Colors.white, // Dialog background color
//               title: Text(
//                 "Edit File Name",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               content: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: _fileNameController,
//                       focusNode: _focusNode, // Set the focus node here
//                       decoration: InputDecoration(
//                         hintText: "Enter new file name",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.orangeAccent),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.orange),
//                         ),
//                         contentPadding:
//                         EdgeInsets.symmetric(horizontal: 12, vertical: 15),
//                       ),
//                       autofocus: true, // Automatically focus when the dialog appears
//                     ),
//                     SizedBox(height: 10),
//                     // Show error message if present
//                     if (_errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 10.0),
//                         child: Text(
//                           _errorMessage,
//                           style: TextStyle(
//                             color: Colors.redAccent,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     // Check if the file name is empty
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage = "File name cannot be empty.";
//                       });
//                       return;
//                     }
//
//                     // Check if the file name already exists
//                     bool fileExists = _fileNames.any((file) =>
//                     file.toLowerCase() == newFileName.toLowerCase() &&
//                         file != _fileNames[index]);
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage = "A file with this name already exists.";
//                       });
//                       return;
//                     }
//
//                     // If no error, update the file name
//                     setState(() {
//                       _fileNames[index] = newFileName;
//                       _errorMessage = ''; // Clear error message
//                     });
//
//                     _filterFiles(_searchController.text); // Re-filter after editing the file name
//                     _saveAllNotes();
//                     Navigator.of(context).pop();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.orange, // Button color
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       'Save',
//                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     ).then((_) {
//       // Set the cursor in the text field after the dialog is shown
//       Future.delayed(Duration(milliseconds: 100), () {
//         _focusNode.requestFocus();
//       });
//     });
//   }
//
//
//   void _openFileDetails(int index) {
//     print("Opening file at index: $index");
//     print("Filtered file names: $_filteredFileNames");
//     print(
//         "Filtered note controllers length: ${_filteredNoteControllers.length}");
//
//     if (index < 0 || index >= _filteredFileNames.length) {
//       print("Error: Invalid index $index!");
//       return;
//     }
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _filteredFileNames[index],
//           noteController: _filteredNoteControllers[index],
//         ),
//       ),
//     ).then((_) {
//       setState(() {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//         _isInSelectionMode = false;
//         _searchController.clear();
//         _filterFiles(""); // Reset filtered list
//       });
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = List.from(_fileNames);
//         _filteredNoteControllers = List.from(_noteControllers);
//       } else {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//
//         for (int i = 0; i < _fileNames.length; i++) {
//           if (_fileNames[i].toLowerCase().contains(query.toLowerCase())) {
//             _filteredFileNames.add(_fileNames[i]);
//             _filteredNoteControllers.add(_noteControllers[i]);
//           }
//         }
//       }
//
//       // अगर फ़िल्टर के बाद कोई फ़ाइल नहीं बची तो सेलेक्शन मोड बंद कर दें।
//       if (_filteredFileNames.isEmpty) {
//         _isInSelectionMode = false;
//       }
//
//       // हमेशा चयनित फ़ाइलें रीसेट करें
//       _selectedFiles = List.generate(_fileNames.length, (_) => false);
//     });
//   }
//
//   void _selectAllFiles() {
//     setState(() {
//       bool allSelected = _selectedFiles.every((selected) => selected);
//       if (allSelected) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//         _isInSelectionMode = false;
//       } else {
//         _selectedFiles = List.generate(_fileNames.length, (_) => true);
//         _isInSelectionMode = true;
//       }
//     });
//   }
//
// // Toggle selection mode
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       // Keep the selection mode active after the second long press if any files are selected
//       if (!_isInSelectionMode && !_selectedFiles.contains(true)) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   // Toggle between grid and list view
//   void _toggleView() {
//     setState(() {
//       _isGridView = !_isGridView;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white60,
//         elevation: 4,
//         shadowColor: Colors.white60,
//         title: Text(
//           "My notes",
//           style: TextStyle(
//             color:  (Colors.black),
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.black45, size: 28),
//             onPressed: () async {
//               final selectedFile = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchScreen(
//                     fileNames: _fileNames,
//                     noteControllers: _noteControllers,
//                   ),
//                 ),
//               );
//
//               if (selectedFile != null) {
//                 int index = _fileNames.indexOf(selectedFile);
//                 _openFileDetails(index);
//               }
//             },
//             tooltip: "Search Notes",
//           ),
//           IconButton(
//             icon: Icon(
//               _isGridView ? Icons.view_list : Icons.grid_view,
//               color: Colors.orange,
//               size: 28,
//             ),
//             onPressed: _toggleView,
//             tooltip: 'Toggle View',
//           ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.select_all, color: Colors.orange, size: 28),
//               onPressed: _selectAllFiles,
//               tooltip: 'Select All',
//             ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//               onPressed: _deleteSelectedFiles,
//               tooltip: 'Delete Selected Files',
//             ),
//           SizedBox(width: 10), // Extra spacing for better UI
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           // Deselect all files when the user taps outside
//           if (_isInSelectionMode) {
//             setState(() {
//               _selectedFiles = List.generate(_fileNames.length, (_) => false);
//               _isInSelectionMode = false;
//             });
//           }
//         },
//         child: Container(
//           decoration: BoxDecoration(color: Colors.white60),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: _fileNames.isEmpty ? _buildEmptyState() : (_isGridView ? _buildGridView() : _buildListView()),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         backgroundColor: Colors.orange,
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: AnimatedSwitcher(
//           duration: Duration(milliseconds: 400),
//           transitionBuilder: (child, animation) => ScaleTransition(
//             scale: animation,
//             child: child,
//           ),
//           child: Icon(
//             Icons.add,
//             key: ValueKey<int>(1),
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Build ListView
//   Widget _buildListView() {
//     List<int> sortedIndexes =
//         List.generate(_fileNames.length, (index) => index);
//
//     return ListView.builder(
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding:
//               const EdgeInsets.only(bottom: 11.0), // Increase bottom padding
//           child: _buildFileItem(sortedIndexes[index]),
//         );
//       },
//     );
//   }
//
//   // Build GridView
//   Widget _buildGridView() {
//     List<int> sortedIndexes =
//         List.generate(_fileNames.length, (index) => index);
//
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 2.5,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.note_add, size: 80, color: Colors.grey),
//           SizedBox(height: 20),
//           Text(
//             "No files found.",
//             style: TextStyle(fontSize: 24, color: Colors.grey),
//           ),
//           SizedBox(height: 10),
//           Text(
//             "Tap the '+' button to create a new file.",
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Build each file item in the list/grid
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onLongPress: () {
//         if (!_isInSelectionMode) {
//           _toggleSelectionMode(); // Enable selection mode
//           _toggleSelection(index); // Select the first file
//         }
//       },
//       onTap: () {
//         if (_isInSelectionMode) {
//           _toggleSelection(
//               index); // Allow single tap selection after long press
//         } else {
//           _openFileDetails(index); // Open file if not in selection mode
//         }
//       },
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(11),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.description, color: Color(0xFFFFA500)),
//                   SizedBox(width: 5),
//                   Expanded(
//                     child: Text(
//                       '${_filteredFileNames[index]}',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.edit, color: Colors.orange, size: 19),
//                     onPressed: () {
//                       _showEditFileNameDialog(index); // Trigger the same function when this button is pressed
//                     },
//                   )
//
//                 ],
//               ),
//               Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 11 * 8.0),
//                   child: Text(
//                     index < _filteredNoteControllers.length &&
//                             _filteredNoteControllers[index].text.isNotEmpty
//                         ? _filteredNoteControllers[index].text
//                         : 'Add title...',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade800,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SearchScreen extends StatefulWidget {
//   final List<String> fileNames;
//   final List<TextEditingController> noteControllers;
//
//   SearchScreen({required this.fileNames, required this.noteControllers});
//
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//   FocusNode _searchFocusNode = FocusNode(); // FocusNode
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//
//     // Automatically focus on the search field when the screen is loaded
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_searchFocusNode);
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//       } else {
//         _filteredFileNames = widget.fileNames
//             .where((fileName) =>
//                 fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = widget.fileNames.indexOf(fileName);
//           return widget.noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 6,
//         leading: IconButton(onPressed: (){Navigator.pop(context);},
//     icon: Icon(Icons.arrow_back_ios_new_outlined,),),
//         title: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: _searchController,
//             focusNode: _searchFocusNode, // Set the focus node here
//             decoration: InputDecoration(
//               hintText: "Search files...",
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               border: InputBorder.none,
//               icon: Icon(Icons.search, color: Colors.blueAccent),
//             ),
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//         ),
//       ),
//       body: _filteredFileNames.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.search_off, color: Colors.grey[400], size: 60),
//                   SizedBox(height: 16),
//                   Text(
//                     "No files found. Try searching...",
//                     style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               itemCount: _filteredFileNames.length,
//               itemBuilder: (context, index) {
//                 return InkWell(
//                   onTap: () {
//                     Navigator.pop(context, _filteredFileNames[index]);
//                   },
//                   child: AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     padding: EdgeInsets.all(16),
//                     margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.description, color: Colors.orange),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 _filteredFileNames[index],
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 _filteredNoteControllers[index].text.isNotEmpty
//                                     ? _filteredNoteControllers[index]
//                                         .text
//                                         .split("\n")
//                                         .take(1)
//                                         .join("\n")
//                                     : "Add title...",
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 16,
//                                   color: Colors.grey.shade800,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(Icons.arrow_forward_ios,
//                             color: Colors.grey[600], size: 20),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = [];
//   List<FocusNode> focusNodes = [];
//   List<bool> _selectedFiles = []; // To track the selection of files
//   bool _isInSelectionMode = false; // Flag to track if we are in selection mode
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     _selectedFiles = List.generate(
//         fileNames.length, (_) => false); // Initialize selection list
//     newFileControllers.clear();
//     focusNodes.clear(); // Clear focus nodes
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController =
//             TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//
//         FocusNode newFocusNode = FocusNode();
//         focusNodes.add(newFocusNode); // Add a FocusNode for the new file
//       }
//     }
//
//     setState(() {});
//   }
//
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   Future<void> _deleteSelectedFiles() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     List<String> newFileNames = [];
//     List<String> newFileContents = [];
//
//     setState(() {
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         if (!_selectedFiles[i]) {
//           newFileNames.add(fileNames[i]);
//           newFileContents.add(newFileControllers[i].text);
//         }
//       }
//
//       fileNames = List.from(newFileNames);
//       newFileControllers = newFileContents
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       focusNodes = List.generate(fileNames.length, (_) => FocusNode());
//       _selectedFiles = List.generate(fileNames.length, (_) => false);
//       _isInSelectionMode = false;
//     });
//
//     // Update the data in SharedPreferences
//     await prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//     for (int i = 0; i < newFileControllers.length; i++) {
//       await prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//   }
//
//   void _selectAllFiles() {
//     setState(() {
//       // Select all files
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         _selectedFiles[i] = true;
//       }
//     });
//   }
//
//   void _deselectAllFiles() {
//     setState(() {
//       // Deselect all files and disable selection mode
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         _selectedFiles[i] = false;
//       }
//       _isInSelectionMode = false; // Disable selection mode
//     });
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//     String _errorMessage = '';
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 10,
//               title: Text(
//                 "Enter File Name",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: _fileNameController,
//                     decoration: InputDecoration(
//                       hintText: "Create a new file",
//                       border: OutlineInputBorder(
//                         borderRadius:
//                         BorderRadius.circular(12), // Rounded corners
//                         borderSide: BorderSide(
//                             color: Colors.blue), // Border color
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.blueAccent),
//                       ),
//                       contentPadding:
//                       EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//                     ),
//                     autofocus: true,
//                     maxLength: 10,
//                   ),
//                   SizedBox(height: 10),
//                   if (_errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 10.0),
//                       child: Text(
//                         _errorMessage,
//                         style: TextStyle(
//                           color: Colors.redAccent,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12), // Rounded button
//                     ),
//                     padding: EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 12), // Button padding
//                   ),
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage = "File name cannot be empty!";
//                       });
//                       return;
//                     }
//
//                     bool fileExists = fileNames.any((file) =>
//                     file.toLowerCase() == newFileName.toLowerCase());
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage = "A file with this name already exists!";
//                       });
//                       return;
//                     }
//
//                     setState(() {
//                       _errorMessage = '';
//                       fileNames.insert(0, newFileName);
//                       TextEditingController newController = TextEditingController();
//                       newFileControllers.insert(0, newController);
//                       FocusNode newFocusNode = FocusNode();
//                       focusNodes.insert(0, newFocusNode);
//                       _selectedFiles.insert(0, false); // Initialize selection state
//                     });
//
//                     // Save data and reload to reflect changes
//                     _saveData();
//                     _loadData(); // Reload data to ensure the UI is updated
//
//                     // Use Future.delayed to ensure the widget tree is stable
//                     Future.delayed(Duration(milliseconds: 200), () {
//                       if (mounted) { // Check if the widget is still mounted
//                         FocusScope.of(context).requestFocus(focusNodes[0]);
//                       }
//                     });
//
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     'Create',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> _editFileName(int index) async {
//     TextEditingController _fileNameController =
//     TextEditingController(text: fileNames[index]);
//     String _errorMessage = '';
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               backgroundColor: Colors.white,
//               title: Text(
//                 "Edit File Name",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               content: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: _fileNameController,
//                       autofocus: true, // Automatically shows cursor
//                       decoration: InputDecoration(
//                         hintText: "Enter new file name",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.orangeAccent),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.blueAccent),
//                         ),
//                         contentPadding:
//                         EdgeInsets.symmetric(horizontal: 12, vertical: 15),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     if (_errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 10.0),
//                         child: Text(
//                           _errorMessage,
//                           style: TextStyle(
//                             color: Colors.redAccent,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     // Check if the file name is empty
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage = "File name cannot be empty!";
//                       });
//                       return;
//                     }
//
//                     // Check if the file name already exists
//                     bool fileExists = fileNames.any((file) =>
//                     file.toLowerCase() == newFileName.toLowerCase() &&
//                         file != fileNames[index]);
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage = "A file with this name already exists!";
//                       });
//                       return;
//                     }
//
//                     // If no error, update the file name
//                     setState(() {
//                       _errorMessage = ''; // Clear error message
//                       fileNames[index] = newFileName;
//                     });
//
//                     _saveData();
//                     Navigator.of(context).pop();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.blue,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       'Save',
//                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onLongPress: () {
//         // Sirf tabhi chale jab selection mode inactive ho
//         if (!_isInSelectionMode) {
//           setState(() {
//             _isInSelectionMode = true; // Selection mode enable
//             _selectedFiles[index] = true; // Pehli file automatically select
//           });
//         }
//       },
//       onTap: () {
//         // Sirf tabhi chale jab selection mode active ho
//         if (_isInSelectionMode) {
//           setState(() {
//             _selectedFiles[index] = !_selectedFiles[index]; // Toggle selection
//
//             // Agar sari files unselect ho gayi, to selection mode off karna hai
//             bool anyFileSelected = _selectedFiles.contains(true);
//             if (!anyFileSelected) {
//               _isInSelectionMode = false; // Selection mode disable
//             }
//           });
//         }
//       },
//
//       child: Column(
//         children: [
//           SizedBox(height: 11,),
//           AnimatedContainer(
//             duration: Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             padding: EdgeInsets.all(11),
//             decoration: BoxDecoration(
//               color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//               border: Border.all(
//                 color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//                 width: 2,
//               ),
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 8,
//                   offset: Offset(2, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.end,
//                  children: [
//                    Icon(Icons.description, color: Colors.blue),
//                    SizedBox(width: 7,),
//                    Expanded(
//                      child:
//                          Text(
//                            fileNames[index],
//                            style: TextStyle(
//                              fontWeight: FontWeight.bold,
//                              fontSize: 20,
//                              color: Colors.black87,
//                            ),
//                            overflow: TextOverflow.ellipsis,
//                          ),
//
//
//                    ),
//                    IconButton(
//                        icon: Icon(Icons.edit, color: Colors.blue, size: 19),
//                        onPressed: () {
//                          _editFileName(index);
//                        },
//                      ),
//                  ],
//                ),
//
//                 SizedBox(height: 6),
//                 TextField(
//                   controller: newFileControllers[index],
//                   focusNode: focusNodes[index], // Set the FocusNode here
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     border: InputBorder.none,
//                     hintText: 'Write your notes...',
//                     hintStyle: TextStyle(color: Colors.black54),
//                   ),
//                   onChanged: (text) {
//                     _saveData();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (_isInSelectionMode) {
//           setState(() {
//             _isInSelectionMode = false;
//             _selectedFiles =
//                 List.generate(fileNames.length, (_) => false); // Deselect all
//           });
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white60,
//           elevation: 4,
//           shadowColor: Colors.white60,
//           title: Row(
//             children: [
//               Icon(Icons.description, color: Color(0xFFFFA500)),
//               SizedBox(width: 11,),
//               Text(
//                 widget.fileName,
//                 style: TextStyle(
//                   color: Colors.black, // Title color
//                   fontWeight: FontWeight.bold, // Bold font
//                   fontSize: 22, // Increased font size
//                 ),
//               ),
//
//             ],
//           ),
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios_new_outlined,
//                 color: Colors.black), // Back button color
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           actions: [
//             // Select/Deselect All button - toggles between selecting and deselecting all files
//             if (_isInSelectionMode)
//               IconButton(
//                 icon: Icon(
//                   _selectedFiles.every((selected) => selected) // Check if all are selected
//                       ? Icons.clear_all // Show Deselect All when all files are selected
//                       : Icons.select_all, // Show Select All when not all files are selected
//                   color: Colors.orange,
//                   size: 28,
//                 ),
//                 onPressed: () {
//                   if (_selectedFiles.every((selected) => selected)) {
//                     _deselectAllFiles(); // Unselect all files
//                   } else {
//                     _selectAllFiles(); // Select all files
//                   }
//                 },
//                 tooltip: _selectedFiles.every((selected) => selected)
//                     ? 'Deselect All' // Tooltip when all files are selected
//                     : 'Select All', // Tooltip when not all files are selected
//               ),
//             // Delete button - only shows if some files are selected
//             if (_isInSelectionMode && _selectedFiles.any((selected) => selected))
//               IconButton(
//                 icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//                 onPressed: _deleteSelectedFiles,
//                 tooltip: 'Delete Selected Files',
//               ),
//             SizedBox(width: 10), // Extra spacing for better UI
//           ],
//
//         ),
//         body: Stack(
//           children: [
//             // GestureDetector for empty space
//             GestureDetector(
//               behavior: HitTestBehavior
//                   .translucent, // Only detects taps on empty areas
//               onTap: () {
//                 widget.noteController.selection = TextSelection.fromPosition(
//                   TextPosition(offset: widget.noteController.text.length),
//                 );
//                 FocusScope.of(context)
//                     .requestFocus(FocusNode()); // Move cursor to TextField
//               },
//               child: Container(), // Ensures GestureDetector covers the background
//             ),
//
//             // Main ListView Content
//             ListView(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       TextField(
//                         controller: widget.noteController,
//                         maxLines: null,
//                         keyboardType: TextInputType.multiline,
//                         decoration: InputDecoration(
//                           labelText: 'Title...',
//                           labelStyle: TextStyle(color: Colors.blue,),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),  // Smooth rounded corners
//                             borderSide: BorderSide(color: Colors.orange, width: 2), // Stylish orange border
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.blue, width: 2), // Black border when focused
//                           ),
//                           filled: true,
//                           fillColor: Colors.white10 // Subtle background color
//                         ),
//                         style: TextStyle(fontSize: 18, color: Colors.black87), // Elegant text style
//                         onChanged: (text) {
//                           _saveData();
//                         },
//                       ),
//
//                       ...List.generate(fileNames.length, (index) {
//                         return _buildFileItem(
//                             index); // Long press functionality will remain unchanged
//                       }),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: _showCreateFileDialog,
//           backgroundColor: Colors.blue,
//           elevation: 10,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           child: Icon(
//             Icons.add,
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
///
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: NotepadScreen(),
//     );
//   }
// }
//
// class NotepadScreen extends StatefulWidget {
//   @override
//   _NotepadScreenState createState() => _NotepadScreenState();
// }
//
// class _NotepadScreenState extends State<NotepadScreen> {
//   List<TextEditingController> _noteControllers = [];
//   List<String> _fileNames = [];
//   List<FocusNode> _focusNodes = [];
//   List<bool> _selectedFiles = [];
//   bool _isInSelectionMode = false;
//   bool _isGridView = false;
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//
//   // Load the notes from SharedPreferences
//   void _loadNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> savedFileNames = prefs.getStringList('fileNames') ?? [];
//     List<String> savedFileContents = prefs.getStringList('fileContents') ?? [];
//
//     int minLength = savedFileNames.length < savedFileContents.length
//         ? savedFileNames.length
//         : savedFileContents.length;
//
//     setState(() {
//       _fileNames = savedFileNames.take(minLength).toList();
//       _noteControllers = savedFileContents
//           .take(minLength)
//           .map((content) => TextEditingController(text: content))
//           .toList();
//       _focusNodes = List.generate(minLength, (_) => FocusNode());
//       _selectedFiles = List.generate(minLength, (_) => false);
//       _filteredFileNames = List.from(_fileNames);
//       _filteredNoteControllers = List.from(_noteControllers);
//     });
//
//     for (var controller in _noteControllers) {
//       controller.addListener(() {
//         setState(() {});
//       });
//     }
//   }
//
//   // Delete selected files
//   Future<void> _deleteSelectedFiles(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Show confirmation dialog with a more attractive look
//     bool? confirmDelete = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15), // Rounded corners for a modern look
//           ),
//           title: Text(
//             'Confirm Deletion',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.red, // Color of the title to highlight the action
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete the selected files?',
//             style: TextStyle(fontSize: 16, color: Colors.black87),
//           ),
//           actions: <Widget>[
//             // Cancel button with modern design
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false); // User pressed cancel
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.grey.shade200, // Light grey background for cancel
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.cancel, color: Colors.red), // Cancel icon
//                   SizedBox(width: 8),
//                   Text(
//                     'Cancel',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Delete button with attractive red color
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true); // User confirmed deletion
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.red, // Red background for delete button
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.delete, color: Colors.white), // Delete icon
//                   SizedBox(width: 8),
//                   Text(
//                     'Delete',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white, // White text on delete button
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//
//     // If the user confirmed the deletion
//     if (confirmDelete == true) {
//       List<String> newFileNames = [];
//       List<String> newFileContents = [];
//
//       setState(() {
//         for (int i = 0; i < _fileNames.length; i++) {
//           if (!_selectedFiles[i]) {
//             newFileNames.add(_fileNames[i]);
//             newFileContents.add(_noteControllers[i].text);
//           }
//         }
//
//         _fileNames = List.from(newFileNames);
//         _noteControllers = newFileContents
//             .map((content) => TextEditingController(text: content))
//             .toList();
//         _focusNodes = List.generate(_fileNames.length, (_) => FocusNode());
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//
//         _isInSelectionMode = false;
//       });
//
//       // Save updated data to SharedPreferences
//       await prefs.setStringList('fileNames', newFileNames);
//       await prefs.setStringList('fileContents', newFileContents);
//     }
//   }
//
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//     String _errorMessage = ''; // Variable to store error message
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           // Use StatefulBuilder to allow for state changes inside the dialog
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(15), // Rounded corners for the dialog
//               ),
//               elevation: 10, // Add shadow for better depth
//               title: Text(
//                 "Enter File Name",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black, // Better title styling
//                 ),
//               ),
//               content: Column(
//                 mainAxisSize:
//                     MainAxisSize.min, // Make sure content adjusts to fit
//                 children: [
//                   TextField(
//                     controller: _fileNameController,
//                     decoration: InputDecoration(
//                       hintText: "Create a new file",
//                       border: OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(12), // Rounded corners
//                         borderSide: BorderSide(
//                             color: Colors.orangeAccent), // Border color
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.orange),
//                       ),
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//                     ),
//                     autofocus: true, // Autofocus for quick typing
//                     maxLength: 10, // Limit the file name to 20 characters
//                     // maxLengthEnforced: true, // Enforce the maximum length
//                   ),
//                   SizedBox(
//                       height:
//                           10), // Add spacing between TextField and error message
//
//                   // Show error message if present
//                   if (_errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           bottom: 10.0), // Space between error and button
//                       child: Text(
//                         _errorMessage,
//                         style: TextStyle(
//                           color: Colors.redAccent,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12), // Rounded button
//                     ),
//                     padding: EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 12), // Button padding
//                   ),
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     // Check if file name is empty
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage =
//                             "File name cannot be empty!"; // Set error message
//                       });
//                       return;
//                     }
//
//                     // Convert file names to lowercase for case-insensitive comparison
//                     bool fileExists = _fileNames.any((file) =>
//                         file.toLowerCase() == newFileName.toLowerCase());
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage =
//                             "A file with this name already exists!"; // Set error message
//                       });
//                       return;
//                     }
//
//                     setState(() {
//                       _errorMessage = ''; // Clear error message if no error
//                       _fileNames.insert(0, newFileName);
//                       TextEditingController newController =
//                           TextEditingController();
//                       newController.addListener(() {
//                         setState(() {});
//                       });
//
//                       _noteControllers.insert(0, newController);
//                       _focusNodes.insert(0, FocusNode());
//                       _selectedFiles.insert(0, false);
//                     });
//
//                     _filterFiles(_searchController
//                         .text); // Re-filter after adding a new file
//                     _saveAllNotes();
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     'Create',
//                     style: TextStyle(
//                         color: Colors.white, fontSize: 16), // Button text style
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // Toggle selection of files
//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedFiles[index] = !_selectedFiles[index];
//       _isInSelectionMode = _selectedFiles.contains(true);
//     });
//   }
//
//   // Save all notes to SharedPreferences
//   Future<void> _saveAllNotes() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> fileContents =
//         _noteControllers.map((controller) => controller.text).toList();
//
//     await prefs.setStringList('fileNames', _fileNames);
//     await prefs.setStringList('fileContents', fileContents);
//   }
//
//   // Show dialog to edit file name
//   void _showEditFileNameDialog(int index) {
//     TextEditingController _fileNameController =
//     TextEditingController(text: _fileNames[index]);
//
//     // FocusNode to handle the cursor placement
//     FocusNode _focusNode = FocusNode();
//
//     String _errorMessage = ''; // Variable to store error message
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           // Use StatefulBuilder to allow for state changes inside the dialog
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15), // Rounded corners
//               ),
//               backgroundColor: Colors.white, // Dialog background color
//               title: Text(
//                 "Edit File Name",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               content: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: _fileNameController,
//                       focusNode: _focusNode, // Set the focus node here
//                       decoration: InputDecoration(
//                         hintText: "Enter new file name",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.orangeAccent),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.orange),
//                         ),
//                         contentPadding:
//                         EdgeInsets.symmetric(horizontal: 12, vertical: 15),
//                       ),
//                       autofocus: true, // Automatically focus when the dialog appears
//                     ),
//                     SizedBox(height: 10),
//                     // Show error message if present
//                     if (_errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 10.0),
//                         child: Text(
//                           _errorMessage,
//                           style: TextStyle(
//                             color: Colors.redAccent,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     // Check if the file name is empty
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage = "File name cannot be empty.";
//                       });
//                       return;
//                     }
//
//                     // Check if the file name already exists
//                     bool fileExists = _fileNames.any((file) =>
//                     file.toLowerCase() == newFileName.toLowerCase() &&
//                         file != _fileNames[index]);
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage = "A file with this name already exists.";
//                       });
//                       return;
//                     }
//
//                     // If no error, update the file name
//                     setState(() {
//                       _fileNames[index] = newFileName;
//                       _errorMessage = ''; // Clear error message
//                     });
//
//                     _filterFiles(_searchController.text); // Re-filter after editing the file name
//                     _saveAllNotes();
//                     Navigator.of(context).pop();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.orange, // Button color
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       'Save',
//                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     ).then((_) {
//       // Set the cursor in the text field after the dialog is shown
//       Future.delayed(Duration(milliseconds: 100), () {
//         _focusNode.requestFocus();
//       });
//     });
//   }
//
//
//   void _openFileDetails(int index) {
//     print("Opening file at index: $index");
//     print("Filtered file names: $_filteredFileNames");
//     print(
//         "Filtered note controllers length: ${_filteredNoteControllers.length}");
//
//     if (index < 0 || index >= _filteredFileNames.length) {
//       print("Error: Invalid index $index!");
//       return;
//     }
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FileDetailScreen(
//           fileName: _filteredFileNames[index],
//           noteController: _filteredNoteControllers[index],
//         ),
//       ),
//     ).then((_) {
//       setState(() {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//         _isInSelectionMode = false;
//         _searchController.clear();
//         _filterFiles(""); // Reset filtered list
//       });
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = List.from(_fileNames);
//         _filteredNoteControllers = List.from(_noteControllers);
//       } else {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//
//         for (int i = 0; i < _fileNames.length; i++) {
//           if (_fileNames[i].toLowerCase().contains(query.toLowerCase())) {
//             _filteredFileNames.add(_fileNames[i]);
//             _filteredNoteControllers.add(_noteControllers[i]);
//           }
//         }
//       }
//
//       // अगर फ़िल्टर के बाद कोई फ़ाइल नहीं बची तो सेलेक्शन मोड बंद कर दें।
//       if (_filteredFileNames.isEmpty) {
//         _isInSelectionMode = false;
//       }
//
//       // हमेशा चयनित फ़ाइलें रीसेट करें
//       _selectedFiles = List.generate(_fileNames.length, (_) => false);
//     });
//   }
//
//   void _selectAllFiles() {
//     setState(() {
//       bool allSelected = _selectedFiles.every((selected) => selected);
//       if (allSelected) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//         _isInSelectionMode = false;
//       } else {
//         _selectedFiles = List.generate(_fileNames.length, (_) => true);
//         _isInSelectionMode = true;
//       }
//     });
//   }
//
// // Toggle selection mode
//   void _toggleSelectionMode() {
//     setState(() {
//       _isInSelectionMode = !_isInSelectionMode;
//       // Keep the selection mode active after the second long press if any files are selected
//       if (!_isInSelectionMode && !_selectedFiles.contains(true)) {
//         _selectedFiles = List.generate(_fileNames.length, (_) => false);
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//   }
//
//   // Toggle between grid and list view
//   void _toggleView() {
//     setState(() {
//       _isGridView = !_isGridView;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white60,
//         elevation: 4,
//         shadowColor: Colors.white60,
//         title: Text(
//           "My notes",
//           style: TextStyle(
//             color:  (Colors.black),
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.black45, size: 28),
//             onPressed: () async {
//               final selectedFile = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchScreen(
//                     fileNames: _fileNames,
//                     noteControllers: _noteControllers,
//                   ),
//                 ),
//               );
//
//               if (selectedFile != null) {
//                 int index = _fileNames.indexOf(selectedFile);
//                 _openFileDetails(index);
//               }
//             },
//             tooltip: "Search Notes",
//           ),
//           IconButton(
//             icon: Icon(
//               _isGridView ? Icons.view_list : Icons.grid_view,
//               color: Colors.orange,
//               size: 28,
//             ),
//             onPressed: _toggleView,
//             tooltip: 'Toggle View',
//           ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.select_all, color: Colors.orange, size: 28),
//               onPressed: _selectAllFiles,
//               tooltip: 'Select All',
//             ),
//           if (_isInSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//               onPressed: () async {
//                 await _deleteSelectedFiles(context); // Pass the context here
//               },
//               tooltip: 'Delete Selected Files',
//             ),
//
//           SizedBox(width: 10), // Extra spacing for better UI
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           // Deselect all files when the user taps outside
//           if (_isInSelectionMode) {
//             setState(() {
//               _selectedFiles = List.generate(_fileNames.length, (_) => false);
//               _isInSelectionMode = false;
//             });
//           }
//         },
//         child: Container(
//           decoration: BoxDecoration(color: Colors.white60),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: _fileNames.isEmpty ? _buildEmptyState() : (_isGridView ? _buildGridView() : _buildListView()),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateFileDialog,
//         backgroundColor: Colors.orange,
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: AnimatedSwitcher(
//           duration: Duration(milliseconds: 400),
//           transitionBuilder: (child, animation) => ScaleTransition(
//             scale: animation,
//             child: child,
//           ),
//           child: Icon(
//             Icons.add,
//             key: ValueKey<int>(1),
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Build ListView
//   Widget _buildListView() {
//     List<int> sortedIndexes =
//         List.generate(_fileNames.length, (index) => index);
//
//     return ListView.builder(
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding:
//               const EdgeInsets.only(bottom: 11.0), // Increase bottom padding
//           child: _buildFileItem(sortedIndexes[index]),
//         );
//       },
//     );
//   }
//
//   // Build GridView
//   Widget _buildGridView() {
//     List<int> sortedIndexes =
//         List.generate(_fileNames.length, (index) => index);
//
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 2.5,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemCount: sortedIndexes.length,
//       itemBuilder: (context, index) {
//         return _buildFileItem(sortedIndexes[index]);
//       },
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.note_add, size: 80, color: Colors.grey),
//           SizedBox(height: 20),
//           Text(
//             "No files found.",
//             style: TextStyle(fontSize: 24, color: Colors.grey),
//           ),
//           SizedBox(height: 10),
//           Text(
//             "Tap the '+' button to create a new file.",
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Build each file item in the list/grid
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onLongPress: () {
//         if (!_isInSelectionMode) {
//           _toggleSelectionMode(); // Enable selection mode
//           _toggleSelection(index); // Select the first file
//         }
//       },
//       onTap: () {
//         if (_isInSelectionMode) {
//           _toggleSelection(
//               index); // Allow single tap selection after long press
//         } else {
//           _openFileDetails(index); // Open file if not in selection mode
//         }
//       },
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         padding: EdgeInsets.all(11),
//         decoration: BoxDecoration(
//           color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//           border: Border.all(
//             color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(2, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.description, color: Color(0xFFFFA500)),
//                   SizedBox(width: 5),
//                   Expanded(
//                     child: Text(
//                       '${_filteredFileNames[index]}',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.edit, color: Colors.orange, size: 19),
//                     onPressed: () {
//                       _showEditFileNameDialog(index); // Trigger the same function when this button is pressed
//                     },
//                   )
//
//                 ],
//               ),
//               Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 11 * 8.0),
//                   child: Text(
//                     index < _filteredNoteControllers.length &&
//                             _filteredNoteControllers[index].text.isNotEmpty
//                         ? _filteredNoteControllers[index].text
//                         : 'Add title...',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade800,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SearchScreen extends StatefulWidget {
//   final List<String> fileNames;
//   final List<TextEditingController> noteControllers;
//
//   SearchScreen({required this.fileNames, required this.noteControllers});
//
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<String> _filteredFileNames = [];
//   List<TextEditingController> _filteredNoteControllers = [];
//   FocusNode _searchFocusNode = FocusNode(); // FocusNode
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       _filterFiles(_searchController.text);
//     });
//
//     // Automatically focus on the search field when the screen is loaded
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_searchFocusNode);
//     });
//   }
//
//   void _filterFiles(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFileNames = [];
//         _filteredNoteControllers = [];
//       } else {
//         _filteredFileNames = widget.fileNames
//             .where((fileName) =>
//                 fileName.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//         _filteredNoteControllers = _filteredFileNames.map((fileName) {
//           int index = widget.fileNames.indexOf(fileName);
//           return widget.noteControllers[index];
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 6,
//         leading: IconButton(onPressed: (){Navigator.pop(context);},
//     icon: Icon(Icons.arrow_back_ios_new_outlined,),),
//         title: Container(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: _searchController,
//             focusNode: _searchFocusNode, // Set the focus node here
//             decoration: InputDecoration(
//               hintText: "Search files...",
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               border: InputBorder.none,
//               icon: Icon(Icons.search, color: Colors.blueAccent),
//             ),
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//         ),
//       ),
//       body: _filteredFileNames.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.search_off, color: Colors.grey[400], size: 60),
//                   SizedBox(height: 16),
//                   Text(
//                     "No files found. Try searching...",
//                     style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               itemCount: _filteredFileNames.length,
//               itemBuilder: (context, index) {
//                 return InkWell(
//                   onTap: () {
//                     Navigator.pop(context, _filteredFileNames[index]);
//                   },
//                   child: AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     padding: EdgeInsets.all(16),
//                     margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.description, color: Colors.orange),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 _filteredFileNames[index],
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 _filteredNoteControllers[index].text.isNotEmpty
//                                     ? _filteredNoteControllers[index]
//                                         .text
//                                         .split("\n")
//                                         .take(1)
//                                         .join("\n")
//                                     : "Add title...",
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 16,
//                                   color: Colors.grey.shade800,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(Icons.arrow_forward_ios,
//                             color: Colors.grey[600], size: 20),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
//
// class FileDetailScreen extends StatefulWidget {
//   final String fileName;
//   final TextEditingController noteController;
//
//   FileDetailScreen({required this.fileName, required this.noteController});
//
//   @override
//   _FileDetailScreenState createState() => _FileDetailScreenState();
// }
//
// class _FileDetailScreenState extends State<FileDetailScreen> {
//   List<TextEditingController> newFileControllers = [];
//   List<String> fileNames = [];
//   List<FocusNode> focusNodes = [];
//   List<bool> _selectedFiles = []; // To track the selection of files
//   bool _isInSelectionMode = false; // Flag to track if we are in selection mode
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load original file content
//     String? savedNote = prefs.getString(widget.fileName);
//     if (savedNote != null) {
//       widget.noteController.text = savedNote;
//     }
//
//     // Load additional files
//     fileNames = prefs.getStringList('fileNames_${widget.fileName}') ?? [];
//     _selectedFiles = List.generate(
//         fileNames.length, (_) => false); // Initialize selection list
//     newFileControllers.clear();
//     focusNodes.clear(); // Clear focus nodes
//     for (String fileName in fileNames) {
//       String? fileContent = prefs.getString(fileName);
//       if (fileContent != null) {
//         TextEditingController newFileController =
//             TextEditingController(text: fileContent);
//         newFileControllers.add(newFileController);
//
//         FocusNode newFocusNode = FocusNode();
//         focusNodes.add(newFocusNode); // Add a FocusNode for the new file
//       }
//     }
//
//     setState(() {});
//   }
//
//   Future<void> _saveData() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString(widget.fileName, widget.noteController.text);
//
//     for (int i = 0; i < newFileControllers.length; i++) {
//       prefs.setString(fileNames[i], newFileControllers[i].text);
//     }
//
//     prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//   }
//
//   Future<void> _deleteSelectedFiles(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Show confirmation dialog with a more attractive look
//     bool? confirmDelete = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20), // Rounded corners for a modern look
//           ),
//           title: Text(
//             'Confirm Deletion',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.redAccent, // Color of the title to highlight the action
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete the selected files?',
//             style: TextStyle(fontSize: 16, color: Colors.black87),
//           ),
//           actions: <Widget>[
//             // Cancel button with modern design
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false); // User pressed cancel
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.grey.shade300, // Light grey background for cancel
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.cancel, color: Colors.redAccent), // Cancel icon
//                   SizedBox(width: 8),
//                   Text(
//                     'Cancel',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.redAccent,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Delete button with attractive red color
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true); // User confirmed deletion
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.redAccent, // Red background for delete button
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.delete, color: Colors.white), // Delete icon
//                   SizedBox(width: 8),
//                   Text(
//                     'Delete',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white, // White text on delete button
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//
//     // If the user confirmed the deletion
//     if (confirmDelete == true) {
//       List<String> newFileNames = [];
//       List<String> newFileContents = [];
//
//       setState(() {
//         for (int i = 0; i < _selectedFiles.length; i++) {
//           if (!_selectedFiles[i]) {
//             newFileNames.add(fileNames[i]);
//             newFileContents.add(newFileControllers[i].text);
//           }
//         }
//
//         fileNames = List.from(newFileNames);
//         newFileControllers = newFileContents
//             .map((content) => TextEditingController(text: content))
//             .toList();
//         focusNodes = List.generate(fileNames.length, (_) => FocusNode());
//         _selectedFiles = List.generate(fileNames.length, (_) => false);
//         _isInSelectionMode = false;
//       });
//
//       // Update the data in SharedPreferences
//       await prefs.setStringList('fileNames_${widget.fileName}', fileNames);
//       for (int i = 0; i < newFileControllers.length; i++) {
//         await prefs.setString(fileNames[i], newFileControllers[i].text);
//       }
//     }
//   }
//
//
//   void _selectAllFiles() {
//     setState(() {
//       // Select all files
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         _selectedFiles[i] = true;
//       }
//     });
//   }
//
//   void _deselectAllFiles() {
//     setState(() {
//       // Deselect all files and disable selection mode
//       for (int i = 0; i < _selectedFiles.length; i++) {
//         _selectedFiles[i] = false;
//       }
//       _isInSelectionMode = false; // Disable selection mode
//     });
//   }
//
//   Future<void> _showCreateFileDialog() async {
//     TextEditingController _fileNameController = TextEditingController();
//     String _errorMessage = '';
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 10,
//               title: Text(
//                 "Enter File Name",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: _fileNameController,
//                     decoration: InputDecoration(
//                       hintText: "Create a new file",
//                       border: OutlineInputBorder(
//                         borderRadius:
//                         BorderRadius.circular(12), // Rounded corners
//                         borderSide: BorderSide(
//                             color: Colors.blue), // Border color
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.blueAccent),
//                       ),
//                       contentPadding:
//                       EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//                     ),
//                     autofocus: true,
//                     maxLength: 10,
//                   ),
//                   SizedBox(height: 10),
//                   if (_errorMessage.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 10.0),
//                       child: Text(
//                         _errorMessage,
//                         style: TextStyle(
//                           color: Colors.redAccent,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12), // Rounded button
//                     ),
//                     padding: EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 12), // Button padding
//                   ),
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage = "File name cannot be empty!";
//                       });
//                       return;
//                     }
//
//                     bool fileExists = fileNames.any((file) =>
//                     file.toLowerCase() == newFileName.toLowerCase());
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage = "A file with this name already exists!";
//                       });
//                       return;
//                     }
//
//                     setState(() {
//                       _errorMessage = '';
//                       fileNames.insert(0, newFileName);
//                       TextEditingController newController = TextEditingController();
//                       newFileControllers.insert(0, newController);
//                       FocusNode newFocusNode = FocusNode();
//                       focusNodes.insert(0, newFocusNode);
//                       _selectedFiles.insert(0, false); // Initialize selection state
//                     });
//
//                     // Save data and reload to reflect changes
//                     _saveData();
//                     _loadData(); // Reload data to ensure the UI is updated
//
//                     // Use Future.delayed to ensure the widget tree is stable
//                     Future.delayed(Duration(milliseconds: 200), () {
//                       if (mounted) { // Check if the widget is still mounted
//                         FocusScope.of(context).requestFocus(focusNodes[0]);
//                       }
//                     });
//
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     'Create',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> _editFileName(int index) async {
//     TextEditingController _fileNameController =
//     TextEditingController(text: fileNames[index]);
//     String _errorMessage = '';
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               backgroundColor: Colors.white,
//               title: Text(
//                 "Edit File Name",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               content: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: _fileNameController,
//                       autofocus: true, // Automatically shows cursor
//                       decoration: InputDecoration(
//                         hintText: "Enter new file name",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.orangeAccent),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.blueAccent),
//                         ),
//                         contentPadding:
//                         EdgeInsets.symmetric(horizontal: 12, vertical: 15),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     if (_errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 10.0),
//                         child: Text(
//                           _errorMessage,
//                           style: TextStyle(
//                             color: Colors.redAccent,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     String newFileName = _fileNameController.text.trim();
//
//                     // Check if the file name is empty
//                     if (newFileName.isEmpty) {
//                       setState(() {
//                         _errorMessage = "File name cannot be empty!";
//                       });
//                       return;
//                     }
//
//                     // Check if the file name already exists
//                     bool fileExists = fileNames.any((file) =>
//                     file.toLowerCase() == newFileName.toLowerCase() &&
//                         file != fileNames[index]);
//
//                     if (fileExists) {
//                       setState(() {
//                         _errorMessage = "A file with this name already exists!";
//                       });
//                       return;
//                     }
//
//                     // If no error, update the file name
//                     setState(() {
//                       _errorMessage = ''; // Clear error message
//                       fileNames[index] = newFileName;
//                     });
//
//                     _saveData();
//                     Navigator.of(context).pop();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.blue,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       'Save',
//                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildFileItem(int index) {
//     return GestureDetector(
//       onLongPress: () {
//         // Sirf tabhi chale jab selection mode inactive ho
//         if (!_isInSelectionMode) {
//           setState(() {
//             _isInSelectionMode = true; // Selection mode enable
//             _selectedFiles[index] = true; // Pehli file automatically select
//           });
//         }
//       },
//       onTap: () {
//         // Sirf tabhi chale jab selection mode active ho
//         if (_isInSelectionMode) {
//           setState(() {
//             _selectedFiles[index] = !_selectedFiles[index]; // Toggle selection
//
//             // Agar sari files unselect ho gayi, to selection mode off karna hai
//             bool anyFileSelected = _selectedFiles.contains(true);
//             if (!anyFileSelected) {
//               _isInSelectionMode = false; // Selection mode disable
//             }
//           });
//         }
//       },
//
//       child: Column(
//         children: [
//           SizedBox(height: 11,),
//           AnimatedContainer(
//             duration: Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             padding: EdgeInsets.all(11),
//             decoration: BoxDecoration(
//               color: _selectedFiles[index] ? Colors.blue.shade50 : Colors.white,
//               border: Border.all(
//                 color: _selectedFiles[index] ? Colors.blue : Colors.grey.shade300,
//                 width: 2,
//               ),
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 8,
//                   offset: Offset(2, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.end,
//                  children: [
//                    Icon(Icons.description, color: Colors.blue),
//                    SizedBox(width: 7,),
//                    Expanded(
//                      child:
//                          Text(
//                            fileNames[index],
//                            style: TextStyle(
//                              fontWeight: FontWeight.bold,
//                              fontSize: 20,
//                              color: Colors.black87,
//                            ),
//                            overflow: TextOverflow.ellipsis,
//                          ),
//
//
//                    ),
//                    IconButton(
//                        icon: Icon(Icons.edit, color: Colors.blue, size: 19),
//                        onPressed: () {
//                          _editFileName(index);
//                        },
//                      ),
//                  ],
//                ),
//
//                 SizedBox(height: 6),
//                 TextField(
//                   controller: newFileControllers[index],
//                   focusNode: focusNodes[index], // Set the FocusNode here
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     border: InputBorder.none,
//                     hintText: 'Write your notes...',
//                     hintStyle: TextStyle(color: Colors.black54),
//                   ),
//                   onChanged: (text) {
//                     _saveData();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (_isInSelectionMode) {
//           setState(() {
//             _isInSelectionMode = false;
//             _selectedFiles =
//                 List.generate(fileNames.length, (_) => false); // Deselect all
//           });
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white60,
//           elevation: 4,
//           shadowColor: Colors.white60,
//           title: Row(
//             children: [
//               Icon(Icons.description, color: Color(0xFFFFA500)),
//               SizedBox(width: 11,),
//               Text(
//                 widget.fileName,
//                 style: TextStyle(
//                   color: Colors.black, // Title color
//                   fontWeight: FontWeight.bold, // Bold font
//                   fontSize: 22, // Increased font size
//                 ),
//               ),
//
//             ],
//           ),
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios_new_outlined,
//                 color: Colors.black), // Back button color
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           actions: [
//             // Select/Deselect All button - toggles between selecting and deselecting all files
//             if (_isInSelectionMode)
//               IconButton(
//                 icon: Icon(
//                   _selectedFiles.every((selected) => selected) // Check if all are selected
//                       ? Icons.clear_all // Show Deselect All when all files are selected
//                       : Icons.select_all, // Show Select All when not all files are selected
//                   color: Colors.orange,
//                   size: 28,
//                 ),
//                 onPressed: () {
//                   if (_selectedFiles.every((selected) => selected)) {
//                     _deselectAllFiles(); // Unselect all files
//                   } else {
//                     _selectAllFiles(); // Select all files
//                   }
//                 },
//                 tooltip: _selectedFiles.every((selected) => selected)
//                     ? 'Deselect All' // Tooltip when all files are selected
//                     : 'Select All', // Tooltip when not all files are selected
//               ),
//             // Delete button - only shows if some files are selected
//             if (_isInSelectionMode && _selectedFiles.any((selected) => selected))
//               IconButton(
//                 icon: Icon(Icons.delete, color: Colors.redAccent, size: 28),
//                 onPressed: () async {
//                   await _deleteSelectedFiles(context); // Pass context to the method
//                 },
//                 tooltip: 'Delete Selected Files',
//               ),
//
//             SizedBox(width: 10), // Extra spacing for better UI
//           ],
//
//         ),
//         body: Stack(
//           children: [
//             // GestureDetector for empty space
//             GestureDetector(
//               behavior: HitTestBehavior
//                   .translucent, // Only detects taps on empty areas
//               onTap: () {
//                 widget.noteController.selection = TextSelection.fromPosition(
//                   TextPosition(offset: widget.noteController.text.length),
//                 );
//                 FocusScope.of(context)
//                     .requestFocus(FocusNode()); // Move cursor to TextField
//               },
//               child: Container(), // Ensures GestureDetector covers the background
//             ),
//
//             // Main ListView Content
//             ListView(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       TextField(
//                         controller: widget.noteController,
//                         maxLines: null,
//                         keyboardType: TextInputType.multiline,
//                         decoration: InputDecoration(
//                           labelText: 'Title...',
//                           labelStyle: TextStyle(color: Colors.blue,),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),  // Smooth rounded corners
//                             borderSide: BorderSide(color: Colors.orange, width: 2), // Stylish orange border
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.blue, width: 2), // Black border when focused
//                           ),
//                           filled: true,
//                           fillColor: Colors.white10 // Subtle background color
//                         ),
//                         style: TextStyle(fontSize: 18, color: Colors.black87), // Elegant text style
//                         onChanged: (text) {
//                           _saveData();
//                         },
//                       ),
//
//                       ...List.generate(fileNames.length, (index) {
//                         return _buildFileItem(
//                             index); // Long press functionality will remain unchanged
//                       }),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: _showCreateFileDialog,
//           backgroundColor: Colors.blue,
//           elevation: 10,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           child: Icon(
//             Icons.add,
//             size: 30,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }


