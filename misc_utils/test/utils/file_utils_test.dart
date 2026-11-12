import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misc_utils/misc_utils.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePathProviderPlatform mockPathProviderPlatform;
    late FakeFilePickerPlatform mockFilePickerPlatform;

  setUp(() {
    mockPathProviderPlatform = FakePathProviderPlatform();
    PathProviderPlatform.instance = mockPathProviderPlatform;
        mockFilePickerPlatform = FakeFilePickerPlatform();
        FilePickerPlatform.instance = mockFilePickerPlatform;
  });

  test(
      "correctly concatenates the path of a file to the application directory path",
      () async {
    final File result = await FileUtils().openFile("game-store.json");

    expect(result.path, 'test_resources/game-store.json');
    expect(result.readAsStringSync().replaceAll('\r', ""), """
{
    "games": [
        {
            "id": "witcher-3",
            "name": "The Witcher 3: Wild Hunt",
            "platform": "Gog",
            "status": "completed",
            "lastModified": "2023-01-01T00:00:00.000",
            "createdAt": "2015-05-19T00:00:00.000",
            "price": 59.99,
            "usk": "usk18",
            "dlcs": [
                {
                    "id": "witcher-3-hearts-of-stone",
                    "name": "Hearts of Stone",
                    "status": "completed",
                    "lastModified": "2023-01-02T00:00:00.000",
                    "createdAt": "2015-10-13T00:00:00.000",
                    "price": 9.99,
                    "notes": "This one contains Gaunter O'Dim",
                    "isFavorite": false,
                    "wasGifted": false
                },
                {
                    "id": "witcher-3-blood-and-wine",
                    "name": "Hearts of Stone",
                    "status": "playing",
                    "lastModified": "2023-01-02T00:00:00.000",
                    "createdAt": "2016-05-31T00:00:00.000",
                    "price": 19.99,
                    "notes": "Let's head to Toussaint",
                    "isFavorite": true,
                    "wasGifted": false
                }
            ],
            "notes": null,
            "isFavorite": false,
            "wasGifted": false
        },
        {
            "id": "ssx-3",
            "name": "SSX 3",
            "platform": "PS2",
            "status": "completed100Percent",
            "lastModified": "2023-01-03T00:00:00.000",
            "createdAt": "2022-08-08T00:00:00.000",
            "price": 39.95,
            "usk": "usk6",
            "dlcs": [],
            "notes": null,
            "isFavorite": false,
            "wasGifted": false
        },
        {
            "id": "ori-and-the-blind-forest",
            "name": "Ori and the blind forest",
            "platform": "PS4",
            "status": "onPileOfShame",
            "lastModified": "2023-01-04T00:00:00.000",
            "createdAt": "2022-08-08T00:00:00.000",
            "price": 25.0,
            "usk": "usk12",
            "dlcs": [],
            "notes": null,
            "isFavorite": false,
            "wasGifted": false
        }
    ]
}""");
  });

    test('exports the original bytes with the requested name and title', () async {
        final file = File('test_resources/game-store.json');
        mockFilePickerPlatform.saveResult = Uri.parse('content://saved/game-store.json');

        final result = await FileUtils().exportFile(
            file,
            'game-store.json',
            'Export games',
        );

        expect(result, isTrue);
        expect(mockFilePickerPlatform.savedBytes, await file.readAsBytes());
        expect(mockFilePickerPlatform.savedFileName, 'game-store.json');
        expect(mockFilePickerPlatform.savedDialogTitle, 'Export games');
    });

    test('returns false when export is cancelled', () async {
        final file = File('test_resources/game-store.json');

        final result = await FileUtils().exportFile(
            file,
            'game-store.json',
            'Export games',
        );

        expect(result, isFalse);
    });

    test('returns null when file selection is cancelled', () async {
        expect(await FileUtils().pickFile(), isNull);
    });
}

class FakeFilePickerPlatform extends FilePickerPlatform {
    Uri? saveResult;
    Uint8List? savedBytes;
    String? savedFileName;
    String? savedDialogTitle;

    @override
    Future<PlatformFile?> pickFile({
        String? dialogTitle,
        String? initialDirectory,
        FileType type = FileType.any,
        List<String>? allowedExtensions,
        Function(FilePickerStatus)? onFileLoading,
        int compressionQuality = 0,
        AndroidOptions androidOptions = const AndroidOptions(),
        DarwinOptions darwinOptions = const DarwinOptions(),
        WindowsOptions windowsOptions = const WindowsOptions(),
        LinuxOptions linuxOptions = const LinuxOptions(),
        WebOptions webOptions = const WebOptions(),
    }) async => null;

    @override
    Future<Uri?> saveFile({
        required String fileName,
        required Uint8List bytes,
        required String mimeType,
        String? dialogTitle,
        String? initialDirectory,
        Function(FilePickerStatus)? onFileSaving,
        WindowsOptions windowsOptions = const WindowsOptions(),
        LinuxOptions linuxOptions = const LinuxOptions(),
        WebOptions webOptions = const WebOptions(),
    }) async {
        savedFileName = fileName;
        savedBytes = bytes;
        savedDialogTitle = dialogTitle;
        return saveResult;
    }
}
