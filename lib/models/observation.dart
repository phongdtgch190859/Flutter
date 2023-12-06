class Observation {

  int _id = -1;
  String _type;
  String _date;

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String _comment;
  int _hikeId;

  Observation.WithId(this._id, this._type, this._date,  this._comment,  this._hikeId,);

  Observation(this._type, this._date, this._comment, this._hikeId);

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  String get comment => _comment;

  set comment(String value) {
    _comment = value;
  }

  int get hikeId => _hikeId;

  set hikeId(int value) {
    _hikeId = value;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (_id != -1) {
      map['id'] = _id;
    }
    map['type'] = _type;
    map['date'] = _date;
    map['comment'] = _comment;
    map['hikeId'] = _hikeId;
    return map;
  }

  // Add this factory method to create ObservationData from Map
  factory Observation.fromMap(Map<String, dynamic> map) {
    return Observation.WithId(
      map['id'] ?? -1,
      map['type'],
      map['date'],
      map['comment'],
      map['hikeId'],
    );
  }

}
