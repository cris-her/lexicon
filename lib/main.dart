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
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Word> _wordList = <Word>[];
  late List<Word> _originalWordList = <Word>[];
  final _wordService = WordService();
  TextEditingController _searchController = TextEditingController();

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
        wordModel.creationDate = word['creation_date'];
        _wordList.add(wordModel);
      });
    });

    _originalWordList = _wordList;
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

  _deleteFormDialog(BuildContext context, wordId, englishWord, spanishWord) {
    return showDialog(
        context: context,
        builder: (param) {
          return AlertDialog(
            title: Text(
              '¿Está seguro que desea eliminar $englishWord ($spanishWord)?',
              style: TextStyle(color: Colors.teal, fontSize: 20),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, backgroundColor: Colors.red),
                  onPressed: () async {
                    var result = await _wordService.deleteWord(wordId);
                    if (result != null) {
                      Navigator.pop(context);
                      getAllWordDetails();

                      _onClearSearch();

                      _showSuccessSnackBar('Eliminado');
                    }
                  },
                  child: const Text('Sí')),
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, backgroundColor: Colors.teal),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'))
            ],
          );
        });
  }

  void _onClearSearch() {
    setState(() {
      _searchController.clear();
      _wordList = _originalWordList.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    _wordList.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _wordList = value.isEmpty
                      ? _originalWordList.toList()
                      : _originalWordList
                          .where((word) =>
                              word.english!
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              word.spanish!
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                          .toList();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _wordList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        FocusScope.of(context).unfocus();

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewWord(
                                      word: _wordList[index],
                                    )));
                      },
                      title: Text(_wordList[index].english ?? ''),
                      subtitle: Text(_wordList[index].spanish ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditWord(
                                              word: _wordList[index],
                                            ))).then((data) {
                                  if (data != null) {
                                    _onClearSearch();
                                    getAllWordDetails();

                                    _showSuccessSnackBar('Actualizado');
                                  }
                                });
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.teal,
                              )),
                          IconButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _deleteFormDialog(
                                    context,
                                    _wordList[index].id,
                                    _wordList[index].english,
                                    _wordList[index].spanish);
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).unfocus();

          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddWord()))
              .then((data) {
            if (data != null) {
              _onClearSearch();
              getAllWordDetails();
              _showSuccessSnackBar('Agregado');
            }
          });
        },
        tooltip: 'Agregar',
        child: const Icon(Icons.add),
      ),
    );
  }
}
