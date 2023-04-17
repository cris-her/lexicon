import 'dart:async';

import 'package:lexicon/db_helper/repository.dart';
import 'package:lexicon/model/word.dart';

class WordService
{
  late Repository _repository;
  WordService(){
    _repository = Repository();
  }

  SaveWord(Word word) async{
    return await _repository.insertData('words', word.wordMap());
  }

  readAllWords() async{
    return await _repository.readData('words');
  }

  UpdateWord(Word word) async{
    return await _repository.updateData('words', word.wordMap());
  }

  deleteWord(wordId) async {
    return await _repository.deleteDataById('words', wordId);
  }

}