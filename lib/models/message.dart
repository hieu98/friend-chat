class Message {
  final String text;
  final DateTime date;

  Message(this.text, this.date);

  Message.fromJsom(Map<dynamic, dynamic> json)
    :date =DateTime.parse(json['date'] as String),
    text = json as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic> {
    'date' : date.toString(),
    'text' : text,
  };
}

