import 'package:flutter/material.dart';
class Hike {
  // static const String TABLE_NAME = 'hikes';
  // static const String COLUMN_ID = 'hike_ID';
  // static const String COLUMN_NAME = 'hike_name';
  // static const String COLUMN_LENGTH = 'hike_length';
  // static const String COLUMN_LEVEL_DIFFICULTY = 'level_difficulty';
  // static const String COLUMN_PARKING_AVAILABLE = 'parking_available';
  // static const String COLUMN_LOCATION = 'hike_location';
  // static const String COLUMN_DATE = 'hike_date';
  // static const String COLUMN_DESCRIPTION = 'hike_description';
  // static const String CREATE_TABLE =
  //     "CREATE TABLE $TABLE_NAME ("
  //     "$COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT, "
  //     "$COLUMN_NAME TEXT, "
  //     "$COLUMN_LENGTH INTEGER, "
  //     "$COLUMN_LEVEL_DIFFICULTY TEXT, "
  //     "$COLUMN_PARKING_AVAILABLE INTEGER, "
  //     "$COLUMN_LOCATION TEXT, "
  //     "$COLUMN_DATE TEXT, "
  //     "$COLUMN_DESCRIPTION TEXT"
  //     ")";
  int _id = -1;
  String _nameOfHike;
  int _lengthOfHike;
  String _levelDifficulty;

  set id(int value) {
    _id = value;
  }

  bool _parkingAvailable;
  String _location;
  String _date;
  String _description;

  Hike(
      this._nameOfHike,
      this._lengthOfHike,
      this._levelDifficulty,
      this._parkingAvailable,
      this._location,
      this._date,
      this._description,
      );

  Hike.WithId(
    this._id,
    this._nameOfHike,
    this._lengthOfHike,
    this._levelDifficulty,
    this._parkingAvailable,
    this._location,
    this._date,
    this._description,
  );

  int get id => _id;
  String get name => _nameOfHike;
  int get length => _lengthOfHike;
  String get level =>  _levelDifficulty;
  bool get haveParking => _parkingAvailable;
  String get location => _location;
  String get date => _date;
  String get desc => _description;

  set nameOfHike(String value) {
    _nameOfHike = value;
  }

  set lengthOfHike(int value) {
    _lengthOfHike = value;
  }

  set levelDifficulty(String value) {
    _levelDifficulty = value;
  }

  set parkingAvailable(bool value) {
    _parkingAvailable = value;
  }

  set location(String value) {
    _location = value;
  }

  set date(String value) {
    _date = value;
  }

  set description(String value) {
    _description = value;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (_id != -1) {
      map['id'] = _id;
    }
    map['nameOfHike'] = _nameOfHike;
    map['lengthOfHike'] = _lengthOfHike;
    map['levelDifficulty'] = _levelDifficulty;
    map['parkingAvailable'] = _parkingAvailable ? 1 : 0;
    map['location'] = _location;
    map['date'] = _date;
    map['description'] = _description;

    return map;
  }
  factory Hike.fromMap(Map<String, dynamic> map) {
    return Hike.WithId(
      map['id'] ?? -1, // Use -1 if 'id' is not present in the map
      map['nameOfHike'],
      map['lengthOfHike'],
      map['levelDifficulty'],
      map['parkingAvailable'] == 1,
      map['location'],
      map['date'],
      map['description'],
    );
  }


}

