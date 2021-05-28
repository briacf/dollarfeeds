import 'dart:io';
import 'package:path_provider/path_provider.dart';

void writeFile(String fileName, String text) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/' + fileName);
    await file.writeAsString(text);
}

Future<String> readFile(String fileName) async {
    String text;
    try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/' + fileName);
        text = await file.readAsString();
    } catch (e) {
        print(e.message);
    }
    return text;
}