import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meme_generator/entities/text_object_data.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

enum EditMode {
  modeSelection,
  newText,
  editPosition,
  editText,
  editSize,
}

class GeneratorMemeScreen extends StatelessWidget {
  const GeneratorMemeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Body(),
    );
  }
}

class Body extends StatefulWidget {
  const Body({
    super.key,
  });
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  // Создание мема реализовано через конвейерное представления,
  // что позволяет реализовать модульность, даст расширяемость, заложить простое ядро на будущее.
  EditMode editMode = EditMode.modeSelection;
  List<TextObjectData> textsMeme = [];
  TextObjectData? activeTextMeme;
  String alert = '';
  final screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    var urlImage = ModalRoute.of(context)!.settings.arguments;

    return Center(
        child: ListView(padding: const EdgeInsets.all(16), children: [
      const SizedBox(
        height: 30,
      ),
      Screenshot(
        controller: screenshotController,
        child: GestureDetector(
          onTapDown: (TapDownDetails details) {
            final Offset position = details.localPosition;
            if (editMode == EditMode.newText) {
              setState(() {
                textsMeme.add(TextObjectData(
                    containerX: position.dx,
                    containerY: position.dy,
                    textMeme: 'TextMeme'));
                alert =
                    'Вы можете менять позицию на всем протяжение редактирования текста.';
                activeTextMeme = textsMeme.last;
                editMode = EditMode.editPosition;
              });
            }
            if (editMode == EditMode.editPosition ||
                editMode == EditMode.editText ||
                editMode == EditMode.editSize) {
              setState(() {
                if (activeTextMeme != null) {
                  activeTextMeme!.containerX = position.dx;
                  activeTextMeme!.containerY = position.dy;
                }
              });
            }
          },
          child: Stack(children: [
            Container(
              width: double.infinity,
              child: Image.network(
                '$urlImage',
                fit: BoxFit.cover,
              ),
            ),
            //добавленные тексты
            ...textsMeme.map((e) => e.getWidget())
          ]),
        ),
      ),
      const SizedBox(
        height: 8,
      ),
      // alert User
      alert.isNotEmpty
          ? Text(alert, style: TextStyle(fontSize: 20, color: Colors.white))
          : const SizedBox(),
      const SizedBox(
        height: 8,
      ),
      editMode == EditMode.modeSelection
          ? Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      alert = 'Куда вставить новый текст ?';
                      editMode = EditMode.newText;
                    });
                  },
                  child: const Text('Добавить текст'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Назад'),
                ),
                ElevatedButton(
                  onPressed: () {
                    screenshotController.capture().then((value) {
                      saveFile(value!, '${Random().nextInt(4294967295)}.png');
                    });
                  },
                  child: const Text('Сохранить'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/myCollectionsMems', (route) => false);
                  },
                  child: const Text('Мая коллекцию'),
                )
              ],
            )
          : const SizedBox(),
      editMode == EditMode.editPosition
          ? Wrap(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      alert = 'Введите текст';
                      editMode = EditMode.editText;
                    });
                  },
                  child: Text('Далее'),
                )
              ],
            )
          : const SizedBox(),
      editMode == EditMode.editText
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (String value) {
                    setState(() {
                      if (activeTextMeme != null) {
                        activeTextMeme!.textMeme = value;
                      }
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      alert = 'Измените размер шрифта';
                      editMode = EditMode.editSize;
                    });
                  },
                  child: const Text('Далее'),
                ),
              ],
            )
          : const SizedBox(),
      editMode == EditMode.editSize
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Slider(
                value: activeTextMeme!.fontSize,
                max: 100,
                divisions: 100,
                onChanged: (double value) {
                  setState(() {
                    activeTextMeme!.fontSize = value;
                  });
                },
                label: activeTextMeme!.fontSize.round().toString(),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    alert = '';
                    editMode = EditMode.modeSelection;
                  });
                },
                child: const Text('Сохранить'),
              ),
            ])
          : const SizedBox(),
    ]));
  }
}

Future<void> saveFile(Uint8List bytes, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';
  final file = File(filePath);
  await file.writeAsBytes(bytes);
}
