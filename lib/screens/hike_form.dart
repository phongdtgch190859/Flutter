import 'package:flutter/material.dart';
import 'package:myproject/models/hike.dart';
import 'package:myproject/utils/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
class HikeForm extends StatefulWidget {
  final String titleAppBar;
  final Function(Hike hike) onHikeAdded;
  late Hike initialHike;

  HikeForm(
      {required this.titleAppBar,
      required this.initialHike,
      required this.onHikeAdded});

  @override
  _HikeFormState createState() => _HikeFormState();
}

class _HikeFormState extends State<HikeForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _priorities = <String>['Easy', 'Moderate', 'Hard'];
  late String _selectedPriority;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController dateController =
      TextEditingController(); // Add date controller
  bool parkingAvailable = false;

  late DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    _selectedPriority = _priorities[0];
    databaseHelper = DatabaseHelper();

    if (widget.initialHike.id != -1) {
      populateFormFields();
    }
  }

  void populateFormFields() {
    setState(() {
      _selectedPriority = widget.initialHike.level;
      titleController.text = widget.initialHike.name;
      descriptionController.text = widget.initialHike.desc;
      locationController.text = widget.initialHike.location;
      lengthController.text = widget.initialHike.length.toString();
      dateController.text = widget.initialHike.date;
      parkingAvailable = widget.initialHike.haveParking;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.titleAppBar),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropDownStringItem) {
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                }).toList(),
                style: Theme.of(context).textTheme.subtitle1,
                value: _selectedPriority,
                onChanged: (valueSelectedByUser) {
                  setState(() {
                    _selectedPriority = valueSelectedByUser!;
                  });
                },
              ),
            ),
            buildTextFieldWithIcon(Icons.title, 'Title', titleController),
            buildTextFieldWithIcon(
                Icons.description, 'Description', descriptionController),
            buildTextFieldWithIcon(
                Icons.location_on, 'Location', locationController),
            buildTextFieldWithIcon(
                Icons.linear_scale, 'Length', lengthController),
            buildDateFieldWithIcon(
                Icons.calendar_today, 'Date', dateController),
            Row(
              children: [
                Text('Parking Available'),
                Switch(
                  value: parkingAvailable,
                  onChanged: (value) {
                    setState(() {
                      parkingAvailable = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await saveHike();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFieldWithIcon(
      IconData icon, String labelText, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.subtitle1,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  Widget buildDateFieldWithIcon(
      IconData icon, String labelText, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(context),
        style: Theme.of(context).textTheme.subtitle1,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      setState(() {
        dateController.text = formattedDate;
      });
    }
  }


  Future<void> saveHike() async {
    String title = titleController.text.trim();
    String description = descriptionController.text.trim();
    String location = locationController.text.trim();
    int length = int.tryParse(lengthController.text.trim()) ?? 0;
    String date = dateController.text.trim();
    if (title.isEmpty ||
        description.isEmpty ||
        location.isEmpty ||
        date.isEmpty ||
        length <= 0) {
      showValidationDialog(
          'Please fill in all fields and provide a valid length.');
    } else {
      Hike hike = Hike(
        title,
        length,
        _selectedPriority,
        parkingAvailable,
        location,
        date,
        description,
      );

      try {
        if (widget.initialHike.id != -1) {
          // If the initialHike has an ID, it means we are editing an existing hike
          hike.id = widget.initialHike.id;

          // Update the hike in the database
          await databaseHelper.updateHike(hike);
        } else {
          // Save the hike to the database
          await databaseHelper.insertHike(hike);
        }

        // Notify the parent widget about the saved hike

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.initialHike.id != -1
              ? "Hike edited successfully"
              : "Hike added successfully"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ));
        widget.onHikeAdded(hike);
        // Close the keyboard
        FocusScope.of(context).unfocus();

        // Show success toast

        // Navigate back
        Navigator.pop(context);
      } catch (e) {
        // Handle errors, e.g., show an error toast
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Something error from server"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ));
      }
    }
  }

  void showValidationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Validation Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
