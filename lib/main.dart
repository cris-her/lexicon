import 'package:lexicon/model/word.dart';
import 'package:lexicon/screens/edit_word.dart';
import 'package:lexicon/screens/add_word.dart';
import 'package:lexicon/screens/view_words.dart';
import 'package:lexicon/services/word_service.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  //  const MyApp({Key? key}) : super(key: key);
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexicon',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Lexicon'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  //  const MyHomePage({Key? key}) : super(key: key);
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late List<Word> _wordList = <Word>[];
  final _wordService = WordService();

  getAllWordDetails() async {
    var words = await _wordService.readAllWords();
    _wordList = <Word>[];
    words.forEach((word) {
      setState(() {
        var wordModel = Word();
        wordModel.id = word['id'];
        wordModel.spanish = word['spanish'];
        wordModel.english = word['english'];
        wordModel.note = word['note'];
        _wordList.add(wordModel);
      });
    });
  }

  @override
  void initState() {
    getAllWordDetails();
    super.initState();
  }

  _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  _deleteFormDialog(BuildContext context, wordId) {
    return showDialog(
        context: context,
        builder: (param) {
          return AlertDialog(
            title: const Text(
              '¿Está seguro que desea eliminar?',
              style: TextStyle(color: Colors.teal, fontSize: 20),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Colors.red),
                  onPressed: ()  async{
                    var result=await _wordService.deleteWord(wordId);
                    if (result != null) {
                      Navigator.pop(context);
                      getAllWordDetails();
                      _showSuccessSnackBar(
                          'Eliminado');
                    }
                  },
                  child: const Text('Sí')),
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Colors.teal),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontStyle: FontStyle.italic),),
      ),
      body: ListView.builder(
          itemCount: _wordList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewWord(
                            word: _wordList[index],
                          )));
                },
                // leading: const Icon(Icons.person),
                title: Text(_wordList[index].english ?? ''),
                subtitle: Text(_wordList[index].spanish ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditWord(
                                    word: _wordList[index],
                                  ))).then((data) {
                            if (data != null) {
                              getAllWordDetails();
                              _showSuccessSnackBar(
                                  'Actualizado');
                            }
                          });
                          ;
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.teal,
                        )),
                    IconButton(
                        onPressed: () {
                          _deleteFormDialog(context, _wordList[index].id);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ))
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddWord()))
              .then((data) {
            if (data != null) {
              getAllWordDetails();
              _showSuccessSnackBar('Agregado');
            }
          });
        },
        tooltip: 'Agregar',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
