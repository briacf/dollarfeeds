class Report {
  String refersToID;
  String type;
  String message;

  Report(this.refersToID, this.type, this.message);

  Map<String, dynamic> toJson() => {
    'refersToID': refersToID,
    'type': type,
    'message': message,
  };
}
