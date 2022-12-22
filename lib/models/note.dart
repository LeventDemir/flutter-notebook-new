class Note {
  final int? id;
  final String title;
  final String? description;
  final String? photo;
  final String? audio;
  final String date;

  Note({
    this.id,
    required this.title,
    this.description,
    this.photo,
    this.audio,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'photo': photo,
        'audio': audio,
        'date': date,
      };

  factory Note.formString(Map<String, dynamic> value) => Note(
        id: value['id'],
        title: value['title'],
        description: value['description'],
        photo: value['photo'],
        audio: value['audio'],
        date: value['date'],
      );
}
