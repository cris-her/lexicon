class Word{
  int? id;
  String? spanish;
  String? english;
  String? note;
  int? creationDate;
  wordMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id ?? null;
    mapping['spanish'] = spanish!;
    mapping['english'] = english!;
    mapping['note'] = note!;
    mapping['creation_date'] = creationDate!;
    return mapping;
  }
}