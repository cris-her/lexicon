class Word{
  int? id;
  String? spanish;
  String? english;
  String? note;
  int? datetime;
  wordMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id ?? null;
    mapping['spanish'] = spanish!;
    mapping['english'] = english!;
    mapping['note'] = note!;
    mapping['datetime'] = datetime!;
    return mapping;
  }
}