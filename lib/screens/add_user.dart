import 'dart:convert';

import 'package:lexicon/model/user.dart';
import 'package:lexicon/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddUser extends StatefulWidget {
  const AddUser({Key? key}) : super(key: key);

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  var _userNameController = TextEditingController();
  var _userContactController = TextEditingController();
  var _userDescriptionController = TextEditingController();
  bool _validateName = false;
  bool _validateContact = false;
  bool _validateDescription = false;
  var _userService=UserService();

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

    var url = Uri.parse('https://api.mymemory.translated.net/get?q=${text.replaceAll(" ", "%20")}&langpair=es|en');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      print(response.body);
      // var data = json.decode(response.body);
      // return data['data']['translations'][0]['translatedText'];


      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);
      print("WOOHOOOOOOOO!!!!!!!!!!!!");
      print(jsonData["responseData"]["translatedText"]);
      /**/
      return jsonData["responseData"]["translatedText"];
    } else {
      throw Exception('Failed to translate text');
    }
  }
  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQLite CRUD"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New User',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.teal,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter Name',
                    labelText: 'Name',
                    errorText:
                    _validateName ? 'Name Value Can\'t Be Empty' : null,
                  )),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                  controller: _userContactController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter Contact',
                    labelText: 'Contact',
                    errorText: _validateContact
                        ? 'Contact Value Can\'t Be Empty'
                        : null,
                  )),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                  controller: _userDescriptionController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter Description',
                    labelText: 'Description',
                    errorText: _validateDescription
                        ? 'Description Value Can\'t Be Empty'
                        : null,
                  )),
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
                          _userNameController.text.isEmpty
                              ? _validateName = true
                              : _validateName = false;
                          _userContactController.text.isEmpty
                              ? _validateContact = true
                              : _validateContact = false;
                          _userDescriptionController.text.isEmpty
                              ? _validateDescription = true
                              : _validateDescription = false;

                        });
                        if (_validateName == false &&
                            _validateContact == false &&
                            _validateDescription == false) {
                          // print("Good Data Can Save");
                          var _user = User();
                          _user.name = _userNameController.text;
                          // await translate(spanishWord, 'es', 'en');
                          _user.contact = await translate(_userNameController.text, 'es', 'en');//_userContactController.text;
                          _user.description = _userDescriptionController.text;
                          var result=await _userService.SaveUser(_user);
                          Navigator.pop(context,result);
                        }
                      },
                      child: const Text('Save Details')),
                  const SizedBox(
                    width: 10.0,
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.red,
                          textStyle: const TextStyle(fontSize: 15)),
                      onPressed: () {
                        _userNameController.text = '';
                        _userContactController.text = '';
                        _userDescriptionController.text = '';
                      },
                      child: const Text('Clear Details'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}