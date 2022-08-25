import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: FirstScreen(
          title: 'Note App'
      ),
    );
  }
}

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  List todolist = List.empty();
  String title = "";
  String description = "";
  @override
  void initState() {
    super.initState();
    todolist = ["hello", "here for your notes"];
  }

  createToDo(){
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("Note App").doc(title);

    Map<String,String> todolist ={
      "todoTitle": title,
      "todoDescription" : description
    };

    documentReference
        .set(todolist)
        .whenComplete(() =>print ("Data Stored"));
  }
  deleteTodo(item){
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("Note App").doc(item);

    documentReference.delete().whenComplete(() => print ("note deleted"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Note App").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('error');
          } else if (snapshot.hasData || snapshot.data != null) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  QueryDocumentSnapshot<Object?>? documentSnapshot =
                  snapshot.data?.docs[index];
                  return Dismissible(
                      key: Key(index.toString()),
                      child: Card(
                        elevation: 5,
                        child: ListTile(
                          title: Text((documentSnapshot != null)
                              ? (documentSnapshot["todoTitle"])
                              : ""),
                          subtitle: Text((documentSnapshot != null)
                              ? ((documentSnapshot["todoDescription"] != null)
                              ? documentSnapshot["todoDescription"]
                              : "")
                              : ""),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.black,
                            onPressed: () {
                              setState(() {
                                // todolist.removeAt(index);
                                deleteTodo((documentSnapshot != null)
                                    ? (documentSnapshot["todoTitle"])
                                    : "");
                              });
                            },
                          ),
                        ),
                      ));
                });
          }
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.black,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: Text("Add Note"),
                  content: Container(
                    width: 400,
                    height: 100,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          onChanged: (String value) {
                            title = value;
                          },
                        ),
                        TextField(
                          onChanged: (String value) {
                            description = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            //todolist.add(title);
                            createToDo();
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text('Add'))
                  ],
                );
              });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}