import 'package:flutter/material.dart';
import 'package:myproject/screens/hike_form.dart';
import 'package:myproject/utils/database_helper.dart';
import 'package:myproject/models/hike.dart';
import 'package:intl/intl.dart';
import 'package:myproject/screens/hike_detail.dart';


class HikeList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HikeListState();
  }
}

class HikeListState extends State<HikeList> {
  late DatabaseHelper databaseHelper;
  late List<Hike> hikes;
  List<Hike> filteredHikes = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
    deleteAllData();
  }

  void refreshHikeList() async {
    print("check: ${filteredHikes.length}");
    try {
      List<Hike> fetchedHikes = await databaseHelper.getHikes();
      setState(() {
        hikes = fetchedHikes;
        filteredHikes = List.from(hikes);
      });
    } catch (e) {
      print('Error refreshing hike list: $e');
    }
  }

  void filterHikes(String searchTerm) {
    List<Hike> filteredList = hikes
        .where((hike) =>
            hike.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
            hike.location.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();

    setState(() {
      filteredHikes = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hikes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Call the method to refresh all data
              showDeleteConfirmationDialog(null,"all");
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterHikes(value);
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                labelText: 'Search Hikes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: filteredHikes.isEmpty
                ? Center(
                    child: Text(
                      searchController.text.isEmpty
                          ? 'No hikes available.'
                          : 'No hikes found with the given search term.',
                    ),
                  )
                : getHikeListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          debugPrint('FAB clicked');
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HikeForm(
                        titleAppBar: "Add Hike",
                         initialHike: new Hike.WithId(-1 ,"", 0,"", false, "", "", ""),
                        onHikeAdded: (newHike) {
                          // Callback to refresh the list when a new hike is added
                          refreshHikeList();
                        },
                      )));
        },
        tooltip: 'Add Hike',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getHikeListView() {

    return ListView.builder(
      itemCount: filteredHikes.length,
      itemBuilder: (BuildContext context, int position) {

        return Align(
          alignment: Alignment.topRight,
          child: Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                filteredHikes[position].name,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.0),
                  Text('Location: ${filteredHikes[position].location}'),
                  Text('Length: ${filteredHikes[position].length} km'),
                  Text('Difficulty: ${filteredHikes[position].level}'),
                  Text(
                      'Parking Available: ${filteredHikes[position].haveParking ? 'Yes' : 'No'}'),
                  Text('Date:  ${filteredHikes[position].date}'),
                  SizedBox(height: 8.0),
                  Text('Description: ${filteredHikes[position].desc}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    // Navigate to the EditHikeScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HikeForm(
                          titleAppBar: "Edit Hike",
                          initialHike: filteredHikes[position], // Pass the selected hike to the form
                          onHikeAdded: (newHike) {
                            // Callback to refresh the list when a new hike is added or edited
                            refreshHikeList();
                          },
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    showDeleteConfirmationDialog(filteredHikes[position], "this");
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HikeDetail(hike: filteredHikes[position]),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showDeleteConfirmationDialog(Hike? hike, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Hike'),
        content: Text('Are you sure you want to delete' + type + 'hike?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {

              type=="this"?deleteHike(hike!):deleteAllData();

              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void deleteHike(Hike hike) async {
    await databaseHelper.deleteHike(hike.id!);
    refreshHikeList();
  }

  void deleteAllData() async {
    final dbClient = await databaseHelper.db;
    try {

      await dbClient?.delete('hike');
      // Refresh the UI
      refreshHikeList();
    } catch (e) {
      print('Error deleting all data: $e');
    }
  }
}
