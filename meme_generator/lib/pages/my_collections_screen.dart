import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class CollectionsMemsSrceen extends StatelessWidget {
  const CollectionsMemsSrceen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Uint8List>? mems =
        getImgMems('/data/user/0/com.example.meme_generator/app_flutter/');
    return Scaffold(
      backgroundColor: Colors.black,
      body: Body(
        mems: mems,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/selectSample', (route) => false);
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
    required this.mems,
  });

  final List<Uint8List>? mems;

  @override
  Widget build(BuildContext context) {
    return mems == null
        ? const SizedBox()
        : ListView(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: mems!
                    .map(
                      (bytes) => Image.memory(
                        bytes,
                        width: 150,
                      ),
                    )
                    .toList(),
              )
            ],
          );
  }
}

List<Uint8List>? getImgMems(String directoryPath) {
  Directory directory = Directory(directoryPath);
  List<FileSystemEntity> fileList = directory.listSync();

  List<Uint8List> data = [];
  for (var file in fileList) {
    if (!file.path.contains(".png")) {
      continue;
    }
    if (file is File) {
      Uint8List bytes = file.readAsBytesSync();
      bytes.length > 0 ? data.add(bytes) : null;
    }
  }
  return data;
}
