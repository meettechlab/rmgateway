import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:html_editor_enhanced/utils/options.dart';
import 'package:rmgateway/model/country_model.dart';
import 'package:rmgateway/model/student_type_model.dart';
import 'package:rmgateway/model/university_model.dart';
import 'package:rmgateway/screens/update_country.dart';
import 'package:rmgateway/screens/update_student_type.dart';
import 'package:rmgateway/screens/update_university.dart';
import 'package:rmgateway/screens/view_lead.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:zefyrka/zefyrka.dart';

class SendEmail extends StatefulWidget {
  final String? singleEmail;

  const SendEmail({Key? key, this.singleEmail}) : super(key: key);

  @override
  State<SendEmail> createState() => _SendEmailState();
}

class _SendEmailState extends State<SendEmail> {
  final _formKey = GlobalKey<FormState>();
  final emailEditingController = new TextEditingController();
  final subjectEditingController = new TextEditingController();

  // HtmlEditorController controller = HtmlEditorController();
  ZefyrController _controller = ZefyrController();
  List<String> emailList = [];
  List<String> nameList = [];
  bool? _process;
  int? _count;

  final _emailTypes = [
    "It`s nice to speak to you",
    "RM Gateway tried to contact again"
  ];
  String? _chosenEmailType;

  String message = '''''';

  String subject1 = '''It is nice to speak to you''';

  String subject2 =
      '''UK University Representative RM Gateway tried to contact again''';

  String template1 = '''Dear Concern,

Thank you for registering with RM gateway and showing interest to study in the UK.

It is nice to speak with you about studying in the UK. I am happy to inform you that we can start

your application process by following the next stage.

We will require scan copies of listed documents to formally assess your application and process

for admission in the UK.

May we please request you to send us the following documents?

• Copy of passport

• Copy of previous UK visa (if applicable)

• Copies of educational certificates and transcripts

• Copy of IELTS Test Report (if available)

• Recent CV, personal statement, and reference letter (if available)

Our experienced team member will assess your eligibility after receiving these documents. We will

then get back to you with the name of the University you qualified with fees and scholarship

opportunities.

Meanwhile, please do not hesitate to contact us if you have any queries.

We are looking forward to hearing from you soon.

Thank you once again for your interest to study in the UK. Your UK admission process is now just

one step away.
 ''';

  String template2 = '''Dear concern,



Thank you for registering with RM gateway and showing interest to study in the UK.



I am sorry to inform you that our Admissions Team tried to contact you again but was unable to reach

you. However, there is nothing to worry about as you can reply to this email to go to the next stage

of application processing.



We will require scan copies of your documents to formally assess your

application and process for admission to the UK. May we please request you to send us

the following documents?

Copy of your passport

Copy of your previous UK visa (if applicable)

Copies of your educational certificates and transcripts

Copy of IELTS Test Report (if available)

Recent CV, personal statement, and reference letter (if available)
Our experienced team member will assess your eligibility after receiving these documents. We will

then get back to you with the name of the University you qualified with fees and scholarship

opportunities. We will also provide you with further information about the course structure and other

University facilities.



Meanwhile, please do not hesitate to contact us if you have any queries. We are working Saturday to

Thursday 10 am to 6 pm (BD time).

Please do not forget there is a high chance of scholarship and securing your place at University if you

start processing earlier.



We are looking forward to hearing from you soon.



Thank you once again for your interest to study in the UK. Your UK admission process is now just one

step away. 


 ''';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _process = false;
    _count = 1;

    if (widget.singleEmail != null) {
      emailList.add(widget.singleEmail.toString());
    }

    _controller.document.changes.listen((event) {
      message =_controller.document.toPlainText();
      if(_chosenEmailType == "It`s nice to speak to you"){
        setState((){

            template1 + "\n" + message;

        });
      }else{
        setState((){
          template2 + "\n" +message;
        });

    }
    });


  }

  @override
  Widget build(BuildContext context) {
    DropdownMenuItem<String> buildMenuEmail(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(color: Colors.black),
        ));

    final emailDropdown = Container(
        width: MediaQuery.of(context).size.width / 3,
        child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(
                20,
                15,
                20,
                15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            items: _emailTypes.map(buildMenuEmail).toList(),
            hint: Text(
              'Choose Email Type',
              style: TextStyle(color: Colors.black),
            ),
            value: _chosenEmailType,
            onChanged: (newValue) {
              setState(() {
                _chosenEmailType = newValue;
                if (newValue == "It`s nice to speak to you") {
                  setState(() {
                    emailEditingController.text = template1;
                    subjectEditingController.text = subject1;
                  });
                } else if (newValue == "RM Gateway tried to contact again") {
                  setState(() {
                    emailEditingController.text = template2;
                    subjectEditingController.text = subject2;
                  });
                }
              });
            }));

    final emailField = Container(
        width: MediaQuery.of(context).size.width / 3,
        child: TextFormField(
            cursorColor: Colors.blue,
            autofocus: false,
            controller: emailEditingController,
            keyboardType: TextInputType.name,
            maxLines: 10,
            validator: (value) {
              if (value!.isEmpty) {
                return ("email cannot be empty!!");
              }
              return null;
            },
            onSaved: (value) {
              emailEditingController.text = value!;
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(
                20,
                15,
                20,
                15,
              ),
              labelText: 'Write your message',
              labelStyle: TextStyle(color: Colors.black),
              floatingLabelStyle: TextStyle(color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
            )));

    final subjectField = Container(
        width: MediaQuery.of(context).size.width / 3,
        child: TextFormField(
            cursorColor: Colors.blue,
            autofocus: false,
            controller: subjectEditingController,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value!.isEmpty) {
                return ("subject cannot be empty!!");
              }
              return null;
            },
            onSaved: (value) {
              subjectEditingController.text = value!;
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(
                20,
                15,
                20,
                15,
              ),
              labelText: 'Write your subject',
              labelStyle: TextStyle(color: Colors.black),
              floatingLabelStyle: TextStyle(color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
            )));

    final createButton = Material(
      elevation: (_process!) ? 0 : 5,
      color: (_process!) ? Colors.green.shade800 : Colors.green,
      borderRadius: BorderRadius.circular(10),
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(
          100,
          20,
          100,
          20,
        ),
        minWidth: 20,
        onPressed: () {
          setState(() {
            _process = true;
            _count = (_count! - 1);
          });
          (_count! < 0)
              ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.red, content: Text("Wait Please!!")))
              : _sendEmail();
        },
        child: (_process!)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Wait',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Center(
                      child: SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ))),
                ],
              )
            : Text(
                '  Send  ',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              ),
      ),
    );

    final backButton = TextButton(
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ViewLead()));
        },
        child: Text(
          "Back",
          style: TextStyle(color: Colors.blue.shade800),
        ));

    // final eTextField = Container(
    //   width: MediaQuery.of(context).size.width/3,
    //   height: 400,
    //   child: HtmlEditor(
    //     controller: controller,
    //     htmlToolbarOptions: HtmlToolbarOptions(
    //
    //     ),//required
    //     htmlEditorOptions: HtmlEditorOptions(
    //       hint: "Your text here...",
    //       //initalText: "text content initial, if any",
    //     ),
    //     otherOptions: OtherOptions(
    //       height: 400,
    //     ),
    //   ),
    // );

    final zText = Container(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          children: [
            ZefyrToolbar.basic(
              controller: _controller,
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: ZefyrEditor(
                maxHeight: 800,
                minHeight: 300,
                controller: _controller,
              ),
            ),
          ],
        ));



    final previewWidget =  Container(
      width: MediaQuery.of(context).size.width/2,
      padding: EdgeInsets.all(20.0) ,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white
      ),
      child: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Text(
              (_chosenEmailType == "It`s nice to speak to you")?  template1 + "\n" + message:
              template2 + "\n" +message,
            ),
          ),
        ),
      )
    );


    final CollectionReference _collectionReference =
        FirebaseFirestore.instance.collection("leads");

    Widget _buildListView() {
      return StreamBuilder<QuerySnapshot>(
          stream: _collectionReference
              .orderBy("timeStamp", descending: true)
              .snapshots()
              .asBroadcastStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went Wrong'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: Text('Empty'),
              );
            } else {
              final List storedocs = [];
              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map a = document.data() as Map<String, dynamic>;
                if (widget.singleEmail == null) {
                  storedocs.add(a);
                  a['id'] = document.id;
                }
              }).toList();
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                decoration: BoxDecoration(
                    color: Colors.cyan.shade100,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Table(
                      border: TableBorder.all(),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(children: [
                          TableCell(
                            child: Container(
                              color: Colors.cyan.shade300,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Select',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Container(
                              color: Colors.cyan.shade300,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Name',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Container(
                              color: Colors.cyan.shade300,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'email',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                        for (var i = 0; i < storedocs.length; i++) ...[
                          TableRow(children: [
                            TableCell(
                              child: Container(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Checkbox(
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (storedocs[i]["email"] != null) {
                                            if (value == true) {
                                              emailList.add(
                                                storedocs[i]["email"],
                                              );
                                              nameList.add(
                                                storedocs[i]["firstName"],
                                              );
                                              print(emailList);
                                            } else {
                                              emailList.remove(
                                                  storedocs[i]["email"]);
                                              nameList.remove(
                                                  storedocs[i]["firstName"]);
                                              print(emailList);
                                            }
                                          }
                                        });
                                      },
                                      value: (emailList
                                              .contains(storedocs[i]["email"]))
                                          ? true
                                          : false,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      storedocs[i]["firstName"],
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      storedocs[i]["email"],
                                      style: TextStyle(
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ])
                        ]
                      ],
                    )),
              );
            }
          });
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade700,
      body: AlertDialog(
        backgroundColor: Colors.cyan.shade100,
        title: Center(child: Text("Send Email")),
        titleTextStyle: TextStyle(fontSize: 20),
        scrollable: true,
        content: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    emailDropdown,
                    SizedBox(
                      height: 10,
                    ),
                    zText,
                    SizedBox(
                      height: 30,
                    ),
                    previewWidget,
                    SizedBox(
                      height: 30,
                    ),
                    createButton,
                    SizedBox(
                      height: 10,
                    ),
                    backButton,
                    SizedBox(
                      height: 40,
                    ),
                    _buildListView()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendEmail() async {
    if (_chosenEmailType == "It`s nice to speak to you" &&
        emailList.isNotEmpty) {
      try {
        var response;
        for (int i = 0; i < emailList.length; i++) {
          response = await http.post(
              Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "service_id": "service_ylnt5nj",
                "template_id": "template_q6vazne",
                "user_id": "43hhc_4vd52NrjxFU",
                "template_params": {
                  "name": nameList[i],
                  "message": _controller.document.toPlainText(),
                  "user_email": emailList[i]
                }
              }));
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green, content: Text("Email sent")));
        setState(() {
          _process = false;
          _count = 1;
          subjectEditingController.clear();
          emailEditingController.clear();
        });
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text("Something is wrong!!")));
        setState(() {
          _process = false;
          _count = 1;
        });
      }
    } else if (_chosenEmailType == "RM Gateway tried to contact again" &&
        emailList.isNotEmpty) {
      try {
        var response;
        for (int i = 0; i < emailList.length; i++) {
          response = await http.post(
              Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "service_id": "service_ylnt5nj",
                "template_id": "template_o4d68b7",
                "user_id": "43hhc_4vd52NrjxFU",
                "template_params": {
                  "name": nameList[i],
                  "message": _controller.document.toPlainText(),
                  "user_email": emailList[i]
                }
              }));
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green, content: Text("Email sent")));
        setState(() {
          _process = false;
          _count = 1;
          subjectEditingController.clear();
          emailEditingController.clear();
        });
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text("Something is wrong!!")));
        setState(() {
          _process = false;
          _count = 1;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text("At Least 1 Person or Email Type Required")));
      setState(() {
        _process = false;
        _count = 1;
      });
    }
  }
}
