import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileUtils {
  Future<File> openFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final filePath = '$path/$fileName';
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create();
    }
    return file;
  }

  Future<File> createTemporaryFile(String fileName) async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final filePath = "$path/$fileName";
    final file = File(filePath);
    if (await file.exists()) {
      throw Exception('Requested File "$fileName" already exists');
    }
    return file;
  }

  Future<File?> pickFile() async {
    final pickedFile = await FilePicker.pickFile();

    if (pickedFile?.path != null) {
      return File(pickedFile!.path!);
    }
    return null;
  }

  Future<bool> _exportFile(
    File file,
    String fileName,
    String dialogTitle,
  ) async {
    final outputFileUri = await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      bytes: await file.readAsBytes(),
    );
    return outputFileUri != null;
  }

  Future<bool> shareFile(File file, String fileName, String dialogTitle) async {
    final File tmpFile = await createTemporaryFile(fileName);
    await tmpFile.writeAsString(await file.readAsString());

    final xFile = XFile(
      tmpFile.path,
      mimeType: 'application/json',
      name: fileName,
    );
    final result = await Share.shareXFiles([xFile], subject: dialogTitle);

    await tmpFile.delete();

    return result.status == ShareResultStatus.success;
  }

  Future<bool> exportFile(
    File file,
    String fileName,
    String dialogTitle,
  ) {
    return _exportFile(file, fileName, dialogTitle);
  }
}
