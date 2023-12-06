import 'package:flutter/material.dart';
import 'package:myproject/models/hike.dart';
import 'package:myproject/models/observation.dart';
import 'package:myproject/screens/observation_form.dart';
import 'package:myproject/utils/database_helper.dart';
import 'package:intl/intl.dart';

class HikeDetail extends StatefulWidget {
  final Hike hike;

  HikeDetail({required this.hike});

  @override
  _HikeDetailState createState() => _HikeDetailState();
}

class _HikeDetailState extends State<HikeDetail> {
  late List<Observation> observations;
  late DatabaseHelper databaseHelper;
  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    loadObservations();
  }

  void loadObservations() async {
    try {
      List<Observation> fetchedObservations =
      await DatabaseHelper().getObservationsByHikeId(widget.hike.id!);

      setState(() {
        observations = fetchedObservations;
      });
    } catch (e) {
      print('Error loading observations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Hike Detail'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.hike.name,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Location: ${widget.hike.location}',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Length: ${widget.hike.length} km',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Difficulty: ${widget.hike.level}',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Parking Available: ${widget.hike.haveParking ? 'Yes' : 'No'}',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Date: ${widget.hike.date}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Description:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.hike.desc,
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Observations:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            if (observations == null)
              CircularProgressIndicator()
            else if (observations.isEmpty)
              Center(
                child: Text('No observations available.'),
              )
            else
              Expanded(
                child: getHikeListView()

              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the ObservationForm and pass the onObAdded callback
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ObservationForm(
                titleAppBar: "Add Observation",
                initialOb: Observation.WithId(-1, "", "", "", widget.hike.id), // Provide an initial observation object
                onObAdded: (Observation ob) {
                  // Handle the added observation here if needed
                  // For example, you can update the state with the new observation
                  setState(() {
                    loadObservations();
                    observations.add(ob);
                  });
                },
                hike_id: widget.hike.id!,
                // Pass the Hike ID
              ),
            ),
          );
        },
        tooltip: 'Add Observation',
        child: Icon(Icons.add),
      ),
    );
  }
  ListView getHikeListView() {
    return ListView.builder(
      itemCount: observations.length,
      itemBuilder: (BuildContext context, int position) {


        return Align(
          alignment: Alignment.topRight,
          child: Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                observations[position].type,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.0),
                  Text('Date: ${observations[position].date}',),
                  SizedBox(height: 8.0),
                  Text('Comment: ${observations[position].comment}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    // Navigate to the EditHikeScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ObservationForm(
                          titleAppBar: "Edit Obsevation",
                          initialOb: observations[position],
                          onObAdded: (newHike) {
                            loadObservations();
                          },
                          hike_id:  widget.hike.id,

                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    showDeleteConfirmationDialog(observations[position]);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
              onTap: () {
                debugPrint("On tap observation");
              },
            ),
          ),
        );
      },
    );
  }
  void showDeleteConfirmationDialog(Observation ob) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Observation'),
        content: Text('Are you sure you want to delete this observation?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteOb(ob);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void deleteOb(Observation ob) async {
    await databaseHelper.deleteObservation(ob.id!);
    loadObservations();
  }
}

