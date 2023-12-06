import 'package:flutter/material.dart';
import 'package:myproject/models/observation.dart';
import 'package:myproject/utils/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
class ObservationForm extends StatefulWidget {
  final String titleAppBar;
  final Function(Observation ob) onObAdded;
  late Observation initialOb;
  late int hike_id;

  ObservationForm(
      {required this.titleAppBar,
      required this.initialOb,
      required this.onObAdded,
      required this.hike_id,
      });

  @override
  _ObservationFormState createState() => _ObservationFormState();
}

class _ObservationFormState extends State<ObservationForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _priorities = <String>['Animal', 'Vegetable', 'Cloud'];
  late String _selectedPriority;
  TextEditingController dateController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  bool parkingAvailable = false;

  late DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    _selectedPriority = _priorities[0];
    databaseHelper = DatabaseHelper();

    // Check if initialHike is provided and populate form fields
    if (widget.initialOb.id != -1) {
      populateFormFields();
    }
  }

  // Function to populate form fields when editing an existing hike
  void populateFormFields() {
    setState(() {
      _selectedPriority = widget.initialOb.type;
      dateController.text = widget.initialOb.date;
      commentController.text = widget.initialOb.comment;
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
            buildTextFieldWithIcon(
                Icons.description, 'Comment', commentController),
            buildDateFieldWithIcon(
                Icons.calendar_month, 'Date', dateController),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await saveOb();
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

  Future<void> saveOb() async {
    String date = dateController.text.trim();
    String comment = commentController.text.trim();

    if (date.isEmpty) {
      showValidationDialog(
        'Please fill in all fields and provide a valid length.',
      );
    } else {
      Observation ob = Observation(
        _selectedPriority,
        comment,
        date,
        widget.hike_id,
      );

      try {
        if (widget.initialOb.id != -1) {
          // If the initialHike has an ID, it means we are editing an existing hike
          ob.id = widget.initialOb.id;

          // Update the observation in the database
          await databaseHelper.updateObservation(ob);
        } else {
          // Save the observation to the database
          await databaseHelper.insertObservation(ob);
        }

        // Notify the parent widget about the saved observation
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.initialOb.id != -1
              ? "Observation edited successfully"
              : "Observation added successfully"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ));
        widget.onObAdded(ob);

        // Close the keyboard
        FocusScope.of(context).unfocus();

        // Navigate back to HikeDetail with the updated observation
        Navigator.pop(context, ob);
      } catch (e) {
        // Handle errors, e.g., show an error toast
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Something error from the server"),
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
