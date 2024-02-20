import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SelectSampleScreen extends StatelessWidget {
  const SelectSampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Body(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'fab1',
            onPressed: () {
              final TextEditingController _controller = TextEditingController();
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 500,
                    child: Center(
                      child: Column(children: [
                        const SizedBox(
                          height: 40,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'url',
                                  ),
                                  controller: _controller,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () async {
                                  await prependToFile(_controller.text);
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/selectSample',
                                    (route) => false,
                                  );
                                  // Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        )
                      ]),
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.add_a_photo),
          ),
          const SizedBox(
            width: 8,
          ),
          FloatingActionButton(
            heroTag: 'fab2',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/myCollectionsMems', (route) => false);
            },
            child: const Icon(Icons.collections_rounded),
          )
        ],
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      // load imges with repository - getUrls
      future: getUrls(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Ошибка загрузки данных');
        } else {
          List<String> urls = snapshot.data ?? [];
          return ListView(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: urls
                    .map(
                      (url) => GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/createMeme',
                              arguments: url);
                        },
                        child: Image.network(
                          url,
                          width: 70 + Random().nextDouble() * (90),
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox();
                          },
                        ),
                      ),
                    )
                    .toList(),
              )
            ],
          );
        }
      },
    );
  }
}

Future<List<String>> getUrls() async {
  try {
    List<String> lines = [];
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/additionalUrls';

    final File file = File(filePath);
    if (!file.existsSync()) {
      await file.create();
    }
    // Читаем текущее содержимое файла
    String contents = await file.readAsString();
    lines.addAll(contents.split('\n').where((line) => line.isNotEmpty));
    contents = await rootBundle.loadString('assets/urls');
    lines.addAll(contents.split('\n').where((line) => line.isNotEmpty));

    return lines;
  } catch (e) {
    print('Ошибка при чтении файла: $e');
    return [];
  }
}

Future<void> prependToFile(String text) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/additionalUrls';

  final File file = File(filePath);
  if (!file.existsSync()) {
    await file.create();
  }
  // Читаем текущее содержимое файла
  String contents = await file.readAsString();

  // Добавляем новую строку в начало содержимого
  contents = '$text\n$contents';

  // Записываем обновленное содержимое обратно в файл
  await file.writeAsString(contents);
}
