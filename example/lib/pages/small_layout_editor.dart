import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/mobile_editor.dart';
import 'package:flutter/material.dart';

class SmallLayoutEditor extends StatefulWidget {
  const SmallLayoutEditor({super.key});

  @override
  State<SmallLayoutEditor> createState() => _SmallLayoutEditorState();
}

class _SmallLayoutEditorState extends State<SmallLayoutEditor> {
  late final EditorState editorState;

  double height = 100;

  @override
  void initState() {
    super.initState();

    editorState = EditorState(document: Document.blank(withInitialText: true));
  }

  void _onSizeChange(Size size) {
    if (size.height <= 250) {
      setState(() {
        height = size.height + 48;
      });
    }
  }

  @override
  void dispose() {
    editorState.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 134, 46, 247),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Small Layout Editor'),
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          child: Column(
            children: [
              const Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text("Message List"),
                  ),
                ),
              ),
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.7),
                    width: 0.5,
                  ),
                ),
                child: MobileEditor(
                  editorState: editorState,
                  onSizeChanged: _onSizeChange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
