/*
 * Alex Yip 2021-04-07.
 * main.dart last modified 2021-04-07.
 */

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:snapfile/widgets/sign_in_dialog.dart';
import 'package:snapfile/widgets/sign_up_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print(snapshot.error);
          return Container();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Flutter Demo',
            darkTheme: ThemeData(
              primarySwatch: Colors.orange,
              accentColor: Colors.orangeAccent,
              brightness: Brightness.dark,
            ),
            themeMode: ThemeMode.dark,
            home: MyHomePage(title: 'Snapfile'),
            debugShowCheckedModeBanner: false,
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return CircularProgressIndicator();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final List<Widget> actions;

        if (snapshot.connectionState == ConnectionState.waiting) {
          actions = [CircularProgressIndicator()];
        } else if (snapshot.data == null) {
          actions = [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
              child: ElevatedButton(
                onPressed: _showSignUpDialog,
                child: Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
              child: ElevatedButton(
                onPressed: _showSignInDialog,
                child: Text(
                  "Sign in",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                ),
              ),
            ),
          ];
        } else {
          actions = [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
              child: TextButton(
                onPressed: () {},
                child:
                    Text(FirebaseAuth.instance.currentUser?.displayName ?? ""),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: Text(
                  "Sign out",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                ),
              ),
            ),
          ];
        }

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 72.0,
            title: Text(
              widget.title!.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.audiowide(
                textStyle: Theme.of(context).appBarTheme.titleTextStyle,
                fontSize: 32.0,
                letterSpacing: 15.0,
              ),
            ),
            actions: actions + [SizedBox(width: 8)],
          ),
          body: Column(
            children: [
              Expanded(
                child: Card(
                  // TODO drag&drop
                  margin: const EdgeInsets.symmetric(
                    horizontal: 128,
                    vertical: 64,
                  ),
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: Radius.circular(4),
                    strokeWidth: 2.5,
                    dashPattern: [10, 10],
                    color: Theme.of(context).accentColor,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_upload,
                            size: 128,
                          ),
                          SizedBox(height: 64),
                          Text(
                            "Drop your files here!",
                            style: TextStyle(fontSize: 72),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _uploadFile,
                            child: Text("Pick file"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSignUpDialog() async => await showDialog<bool>(
        context: context,
        builder: (context) => SignUpDialog(),
      );

  void _showSignInDialog() async => await showDialog<bool>(
        context: context,
        builder: (context) => SignInDialog(),
      );

  void _uploadFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withReadStream: true);

    if (result?.files.single != null) {
      final PlatformFile file = result!.files.single;

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("http://localhost:3000/"), // TODO use actual URL
      );

      request.files.add(new http.MultipartFile(
          "uploadFile", file.readStream!, file.size!,
          filename: file.name));
      var resp = await request.send();

      String respString = await resp.stream.bytesToString();

      print(respString);
      // TODO redirect
    }
  }
}
