

class LastPlayed {
  String album;
  String id;
  String title;

  LastPlayed({
    required this.album,
    required this.id,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'album': album,
      'id': id,
      'title': title,
    };
  }

  factory LastPlayed.fromMap(Map<String, dynamic> map) {
    return LastPlayed(
      album: map['album'] as String,
      id: map['id'] as String,
      title: map['title'] as String,
    );
  }

  @override
  String toString() {
    return 'LastPlayed(album: $album, id: $id, title: $title)';
  }
}
