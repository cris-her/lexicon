import 'dart:convert';

import 'package:lexicon/model/word.dart';
import 'package:lexicon/services/word_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddWord extends StatefulWidget {
  const AddWord({Key? key}) : super(key: key);

  @override
  State<AddWord> createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {
  var _spanishWordController = TextEditingController();
  var _englishWordController = TextEditingController();
  var _wordNoteController = TextEditingController();
  bool _validateSpanish = false;
  bool _validateEnglish = false;
  //bool _validateNote = false;
  var _wordService=WordService();

  bool _isSpanishActive = false;
  bool _isEnglishActive = false;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   // Step 2 <- SEE HERE
  //   _wordNoteController.text = 'Complete the story from here...';
  // }

  /*
  {"responseData":{
    "translatedText":"Ciao Mondo!",
    "match":1},
  "quotaFinished":false,
  "mtLangSupported":null,
  "responseDetails":"",
  "responseStatus":200,
  "responderId":null,
  "exception_code":null,
  "matches":[{
    "id":"718900173",
    "segment":
    "Hello World!",
    "translation":"Ciao Mondo!",
    "source":"en-GB",
    "target":"it-IT",
    "quality":"74",
    "reference":null,
    "usage-count":2,
    "subject":"All",
    "created-by":"MateCat",
    "last-updated-by":"MateCat",
    "create-date":"2023-04-14 06:35:33",
    "last-update-date":"2023-04-14 06:35:33",
    "match":1}]
  }
  */
  //
  Future<String> translate(String text, String sourceLanguage, String targetLanguage) async {

    var url = Uri.parse('https://api.mymemory.translated.net/get?q=${text.replaceAll(" ", "%20")}&langpair=$sourceLanguage|$targetLanguage');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      //print(response.body);
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      final str = jsonData["responseData"]["translatedText"];
      print(str);
      if (str.contains('(')){
        List<String> substrings = str.split(RegExp(r"(\()|(\))"));
        //print(substrings); // Output: [hello , world,  how are , you,  doing?]
        return substrings[1];
      } else {
        return str;
      }

    } else {
      throw Exception('Failed to translate text');
    }
  }
  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Palabra o frase',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.teal,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                  onChanged: (value){
                    setState(() {
                      if (value.isNotEmpty) {
                        _isSpanishActive = true;
                        _validateSpanish = false;
                      } else {
                        _isSpanishActive = false;
                      }
                    });
                  },
                  enabled: !_isEnglishActive,
                  controller: _spanishWordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Español',
                    labelText: 'Español',
                    errorText:
                    _validateSpanish ? 'Solo un campo obligatorio puede estar vacio' : null,
                  )),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                  onChanged: (value){
                    setState(() {
                      if (value.isNotEmpty) {
                        _isEnglishActive = true;
                        _validateEnglish = false;
                      } else {
                        _isEnglishActive = false;
                      }
                    });
                  },
                  enabled: !_isSpanishActive,
                  controller: _englishWordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Inglés',
                    labelText: 'Inglés',
                    errorText: _validateEnglish ? 'Solo un campo obligatorio puede estar vacio' : null,
                  )),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                  controller: _wordNoteController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nota (opcional)',
                    labelText: 'Nota (opcional)',
                    //errorText: _validateNote ? 'Note Value Can\'t Be Empty' : null,
                  )
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  TextButton(
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.teal,
                          textStyle: const TextStyle(fontSize: 15)),
                      onPressed: () async {
                        setState(() {
                          (_spanishWordController.text.isEmpty ^ _englishWordController.text.isEmpty)
                              ? _validateSpanish = false
                              : _validateSpanish = true;
                          (_englishWordController.text.isEmpty ^ _spanishWordController.text.isEmpty)
                              ? _validateEnglish = false
                              : _validateEnglish = true;
                          // _wordNoteController.text.isEmpty
                          //     ? _validateNote = true
                          //     : _validateNote = false;
                        });
                        if (_validateSpanish == false &&
                            _validateEnglish == false) {
                          // print("Good Data Can Save");
                          var _word = Word();
                          _word.spanish = _spanishWordController.text.isEmpty ? await translate(_englishWordController.text, 'en', 'es') : _spanishWordController.text;
                          _word.english = _englishWordController.text.isEmpty ? await translate(_spanishWordController.text, 'es', 'en') : _englishWordController.text;
                          _word.note = _wordNoteController.text.isEmpty ? " " : _wordNoteController.text;
                          var result=await _wordService.SaveWord(_word);
                          Navigator.pop(context,result);
                        }
                      },
                      child: const Text('Guardar')),
                  const SizedBox(
                    width: 10.0,
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.red,
                          textStyle: const TextStyle(fontSize: 15)),
                      onPressed: () {
                        _spanishWordController.text = '';
                        _englishWordController.text = '';
                        _wordNoteController.text = '';
                      },
                      child: const Text('Limpiar'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}