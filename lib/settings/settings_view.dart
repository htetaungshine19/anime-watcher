import 'dart:convert';
import 'dart:io';

import 'package:animely/core/models/anime.dart';
import 'package:animely/core/utils/show_snackbar.dart';
import 'package:animely/library/presentation/library_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> read(BuildContext context) async {
  final a = await FilePicker.platform.pickFiles(
    type: FileType.any,
  );
  if (a != null && a.count > 0) {
    final f = File("${a.files.first.path}");
    final data = await f.readAsString();
    final d = json.decode(data) as List<dynamic>;
    for (var i in d) {
      context.read(libraryProvider).addToLibrary(Anime.fromJson(i));
    }
  }
}

Future<void> write(String data) async {
  final a = await FilePicker.platform.getDirectoryPath();
  final f = File("$a/save_library.fs");
  if (!f.existsSync()) {
    await f.create(recursive: true);
  }
  await f.writeAsString(data);
}

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Theme'),
                  DropdownButton<ThemeMode>(
                    hint: const Text("Theme"),
                    value: widget.controller.themeMode,
                    onChanged: (value) {
                      widget.controller.updateThemeMode(value);
                      setState(() {});
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark Theme'),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    List<Anime> content = [
                      ...context.read(libraryProvider).list.values
                    ];
                    final status = await Permission.storage.request();
                    final status2 =
                        await Permission.manageExternalStorage.request();
                    if (status.isGranted &&
                        (status2.isGranted || status2.isRestricted)) {
                      await write(json.encode(content));
                      showSnackBar(context, "export completed");
                    }
                  },
                  child: const Text("Export")),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final status = await Permission.storage.request();
                    final status2 =
                        await Permission.manageExternalStorage.request();
                    if (status.isGranted &&
                        (status2.isGranted || status2.isRestricted)) {
                      await read(context);
                      showSnackBar(context, "import completed");
                    }
                  },
                  child: const Text("Import")),
            ],
          ),
        ),
      ),
    );
  }
}
