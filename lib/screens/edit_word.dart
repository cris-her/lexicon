import 'package:lexicon/model/word.dart';
import 'package:lexicon/services/word_service.dart';
import 'package:flutter/material.dart';

class EditWord extends StatefulWidget {
  final Word word;
  const EditWord({Key? key, required this.word}) : super(key: key);

  @override
  State<EditWord> createState() => _EditWordState();
}

class _EditWordState extends State<EditWord> {
  var _spanishWordController = TextEditingController();
  var _englishWordController = TextEditingController();
  var _wordNoteController = TextEditingController();
  bool _validateSpanish = false;
  bool _validateEnglish = false;
  bool _isLoading = false;

  var _wordService = WordService();

  @override
  void initState() {
    setState(() {
      _spanishWordController.text = widget.word.spanish ?? '';
      _englishWordController.text = widget.word.english ?? '';
      _wordNoteController.text = widget.word.note ?? '';
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                      controller: _spanishWordController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Español',
                        labelText: 'Español',
                        errorText: _validateSpanish
                            ? 'Este campo no puede estar vacío'
                            : null,
                      )),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                      controller: _englishWordController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Inglés',
                        labelText: 'Inglés',
                        errorText: _validateEnglish
                            ? 'Este campo no puede estar vacío'
                            : null,
                      )),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                      controller: _wordNoteController,
                      decoration: const InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Nota',
                        labelText: 'Nota',
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
                              _isLoading = true;

                              _spanishWordController.text.isEmpty
                                  ? _validateSpanish = true
                                  : _validateSpanish = false;
                              _englishWordController.text.isEmpty
                                  ? _validateEnglish = true
                                  : _validateEnglish = false;
                            });
                            if (_validateSpanish == false &&
                                _validateEnglish == false) {
                              var _word = Word();
                              _word.id = widget.word.id;
                              _word.spanish =
                                  _spanishWordController.text.toLowerCase();
                              _word.english =
                                  _englishWordController.text.toLowerCase();
                              _word.note = _wordNoteController.text.isEmpty
                                  ? " "
                                  : _wordNoteController.text;
                              _word.datetime =
                                  DateTime.now().millisecondsSinceEpoch;

                              var result = await _wordService.UpdateWord(_word);
                              _isLoading = false;

                              Navigator.pop(context, result);
                            } else {
                              _isLoading = false;
                            }
                          },
                          child: const Text('Actualizar')),
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
          _isLoading
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ))
              : Container(),
        ],
      ),
    );
  }
}
