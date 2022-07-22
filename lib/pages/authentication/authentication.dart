import 'dart:convert';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:intl/intl.dart';
import 'package:HyS/constants/style.dart';
import 'package:HyS/helpers/responsiveness.dart';
import 'package:HyS/layout.dart';
import 'package:HyS/pages/registration/registration.dart';
import 'package:HyS/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:http/http.dart' as http;

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool _obsecuretext = true;
  final _formKeySignIn = GlobalKey<FormState>();
  final _formKeySignUp = GlobalKey<FormState>();
  final _formKeyForgotEmail = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  final databaseReference = FirebaseDatabase.instance.reference();

  String email = '';
  String password = '';
  String pass = '';
  String error = '';
  String validate = '';
  String validatepass = '';
  int count = 0;
  bool loading = false;
  bool _forgotEmainloading = false;

  DateTime currentdatetime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light,
      body: ListView(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 8),
        children: [
          _menu(), // Responsive
          _body()
        ],
      ),
    );
  }

  _menu() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: !ResponsiveWidget.isSmallScreen(context)
            ? MainAxisAlignment.end
            : MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isLogin == true
                  ? _menuItem(title: 'Sign In', isActive: true)
                  : _topMenuButton("Sign In"),
              SizedBox(width: 75),
              isLogin == false
                  ? _menuItem(title: 'Register', isActive: true)
                  : _topMenuButton("Register"),
            ],
          ),
        ],
      ),
    );
  }

  _body() {
    return Row(
      mainAxisAlignment: !ResponsiveWidget.isSmallScreen(context)
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.center,
      children: [
        !ResponsiveWidget.isSmallScreen(context)
            ? Container(
                width: 360,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign In to \nHyS',
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "If you don't have an account",
                      style: TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "You can",
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 15),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                          child: Text(
                            "Register here!",
                            style: TextStyle(
                                color: active, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fillustration-2.png?alt=media&token=3de4dda2-5fea-4e53-8f5d-24f394ee5c5c',
                      width: 300,
                    ),
                  ],
                ),
              )
            : SizedBox(),
        ResponsiveWidget.isLargeScreen(context)
            ? Image.network(
                'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fillustration-1.png?alt=media&token=4d982c7a-b200-42fe-a978-8a5b36efb44d',
                width: 300,
              )
            : SizedBox(),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 6),
          child: Container(
            width: 320,
            child: isLogin == true ? _formLogin() : _formRegister(),
          ),
        )
      ],
    );
  }

  Widget _menuItem({String title = 'Title Menu', isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          children: [
            Text(
              '$title',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? active : Colors.grey,
              ),
            ),
            SizedBox(
              height: 6,
            ),
            isActive
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: active,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _topMenuButton(String value) {
    return InkWell(
      onTap: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 10,
              blurRadius: 12,
            ),
          ],
        ),
        child: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());

  Widget _formLogin() {
    return Form(
      key: _formKeySignIn,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            validator: (val) =>
                ((val!.isEmpty)) ? 'Enter Email ID correctly' : null,
            onChanged: (val) {
              setState(() {
                email = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter email',
              filled: true,
              fillColor: Colors.blueGrey[50],
              labelStyle: TextStyle(fontSize: 12),
              contentPadding: EdgeInsets.only(left: 30),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blueGrey.withOpacity(0.05),
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blueGrey.withOpacity(0.05),
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          SizedBox(height: 30),
          TextFormField(
            keyboardType: TextInputType.text,
            obscureText: _obsecuretext,
            validator: (val) {
              return (val!.isEmpty)
                  ? "Passowrd should not be null"
                  : val.length < 6
                      ? 'Enter a password 6+ chars long'
                      : null;
            },
            onChanged: (val) {
              setState(() => password = val);
            },
            decoration: InputDecoration(
              hintText: 'Password',
              counter: ElevatedButton(
                onPressed: () async {
                  _showForgotPWDDialog();
                },
                child: Container(
                  color: Colors.transparent,
                  child: Text("Forgot password?"),
                ),
                style: ElevatedButton.styleFrom(
                  primary: light,
                  onPrimary: lightGrey,
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              counterText: 'Forgot password?',
              suffixIcon: IconButton(
                  color: Color(0xff0962ff),
                  icon: Icon(
                      _obsecuretext ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obsecuretext = !_obsecuretext;
                    });
                  }),
              filled: true,
              fillColor: Colors.blueGrey[50],
              labelStyle: TextStyle(fontSize: 12),
              contentPadding: EdgeInsets.only(left: 30),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.blueGrey.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.blueGrey.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          SizedBox(height: 40),
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    spreadRadius: 10,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ElevatedButton(
                child: Container(
                    width: double.infinity,
                    height: 50,
                    child: Center(child: Text("Sign In"))),
                onPressed: loading == false
                    ? () async {
                        print("button pressed");
                        if (_formKeySignIn.currentState!.validate()) {
                          print("form validation: correct");
                          setState(() {
                            loading = true;
                          });
                          dynamic result = await _auth.signIn(
                            email,
                            password,
                          );
                          if (result == "Signed in") {
                            print("User signed in");
                            setState(() {
                              loading = false;
                            });
                            {
                              databaseReference
                                  .child("hysweb")
                                  .child("app_bar_navigation")
                                  .child(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                "${FirebaseAuth.instance.currentUser!.uid}": 1,
                                "userid": FirebaseAuth.instance.currentUser!.uid
                              });

                              databaseReference
                                  .child("hysweb")
                                  .child("qANDa")
                                  .child("jump_to_listview_index")
                                  .update({
                                "${FirebaseAuth.instance.currentUser!.uid}": 0
                              });
                              databaseReference
                                  .child("hysweb")
                                  .child("social")
                                  .child("jump_to_listview_index")
                                  .update({
                                "${FirebaseAuth.instance.currentUser!.uid}": 0
                              });

                              databaseReference
                                  .child("hysweb")
                                  .child("chat")
                                  .child(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                "index": 0,
                                "userdetails": [],
                                "chatid": ""
                              });
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SiteLayout()));
                            }
                          } else {
                            print("Invalid user");
                            ElegantNotification.error(
                              title: Text("Error"),
                              description: Text(
                                  "Something wrong, please check email ID or Password: $result"),
                            );

                            setState(() {
                              loading = false;
                              // _showAlertDialog(result);
                            });
                          }
                        } else {
                          ElegantNotification.error(
                            title: Text("Error"),
                            description: Text(
                                "Something wrong, please check email ID or Password"),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  primary: active,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Row(children: [
            Expanded(
              child: Divider(
                color: Colors.grey[300],
                height: 50,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text("Or continue with"),
            ),
            Expanded(
              child: Divider(
                color: Colors.grey[400],
                height: 50,
              ),
            ),
          ]),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _loginWithButton(
                  image:
                      'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fgoogle.png?alt=media&token=c113f0fa-80df-4899-910b-dda5b14c7117'),
              _loginWithButton(
                  image:
                      'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fgithub.png?alt=media&token=0149dc0f-572d-4c26-be7e-84263c46a69c'),
              _loginWithButton(
                  image:
                      'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Ffacebook.png?alt=media&token=34202804-9237-4599-9000-c82cb9057509'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formRegister() {
    return Form(
      key: _formKeySignUp,
      child: Column(
        children: [
          TextFormField(
            validator: (val) =>
                ((val!.isEmpty)) ? 'Enter Email ID correctly' : null,
            onChanged: (val) {
              setState(() => email = val);
            },
            decoration: InputDecoration(
              hintText: 'Enter email',
              filled: true,
              fillColor: Colors.blueGrey[50],
              labelStyle: TextStyle(fontSize: 12),
              contentPadding: EdgeInsets.only(left: 30),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blueGrey.withOpacity(0.05),
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blueGrey.withOpacity(0.05),
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          SizedBox(height: 30),
          TextFormField(
            obscureText: true,
            validator: (val) {
              return val!.length < 6 ? 'Enter a password 6+ chars long' : null;
            },
            onChanged: (val) {
              setState(() => pass = val);
            },
            decoration: InputDecoration(
              hintText: 'Password',
              suffixIcon: Icon(
                Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
              filled: true,
              fillColor: Colors.blueGrey[50],
              labelStyle: TextStyle(fontSize: 12),
              contentPadding: EdgeInsets.only(left: 30),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.blueGrey.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.blueGrey.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          SizedBox(height: 30),
          TextFormField(
            obscureText: true,
            validator: (val) {
              return val != pass ? 'Password not matched' : null;
            },
            onChanged: (val) {
              setState(() => password = val);
            },
            decoration: InputDecoration(
              hintText: 'Re-enter Password',
              suffixIcon: Icon(
                Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
              filled: true,
              fillColor: Colors.blueGrey[50],
              labelStyle: TextStyle(fontSize: 12),
              contentPadding: EdgeInsets.only(left: 30),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.blueGrey.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.blueGrey.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.1),
                  spreadRadius: 10,
                  blurRadius: 20,
                ),
              ],
            ),
            child: ElevatedButton(
              child: Container(
                  width: double.infinity,
                  height: 50,
                  child: Center(child: Text("Register"))),
              onPressed: loading == false
                  ? () async {
                      print("Buttom pressed");
                      if (password != pass) {
                        loading = false;
                        error = 'Please Enter password correctly';
                        print(error);
                      } else if (_formKeySignUp.currentState!.validate()) {
                        print("Form Validted");
                        setState(() {
                          loading = true;
                        });

                        dynamic result = await _auth.signUp(
                            email, password, currentdatetime.toString());
                        print(result);
                        if (result == "Signed up") {
                          databaseReference
                              .child("hysweb")
                              .child("app_bar_navigation")
                              .child(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            "${FirebaseAuth.instance.currentUser!.uid}": 1,
                            "userid": FirebaseAuth.instance.currentUser!.uid
                          });
                          databaseReference
                              .child("hysweb")
                              .child("qANDa")
                              .child("jump_to_listview_index")
                              .update({
                            "${FirebaseAuth.instance.currentUser!.uid}": 0
                          });
                          databaseReference
                              .child("hysweb")
                              .child("social")
                              .child("jump_to_listview_index")
                              .update({
                            "${FirebaseAuth.instance.currentUser!.uid}": 0
                          });

                          databaseReference
                              .child("hysweb")
                              .child("chat")
                              .child(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            "index": 0,
                            "userdetails": [],
                            "chatid": ""
                          });
                          print("Sign up done");
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegistrationProcess()));
                        } else {
                          print("Signup failed");
                          ElegantNotification.error(
                            title: Text("Signup failed,"),
                            description: Text("$result."),
                          );
                          setState(() {
                            loading = false;
                          });
                        }
                      } else {
                        ElegantNotification.error(
                          title: Text("Error"),
                          description: Text("Something wrong"),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                primary: active,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Row(children: [
            Expanded(
              child: Divider(
                color: Colors.grey[300],
                height: 50,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text("Or continue with"),
            ),
            Expanded(
              child: Divider(
                color: Colors.grey[400],
                height: 50,
              ),
            ),
          ]),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _loginWithButton(
                  image:
                      'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fgoogle.png?alt=media&token=c113f0fa-80df-4899-910b-dda5b14c7117'),
              _loginWithButton(
                  image:
                      'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fgithub.png?alt=media&token=0149dc0f-572d-4c26-be7e-84263c46a69c'),
              _loginWithButton(
                  image:
                      'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Ffacebook.png?alt=media&token=34202804-9237-4599-9000-c82cb9057509'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loginWithButton({required String image, bool isActive = false}) {
    return Container(
      width: 90,
      height: 70,
      decoration: isActive
          ? BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 10,
                  blurRadius: 30,
                )
              ],
              borderRadius: BorderRadius.circular(15),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withOpacity(0.4)),
            ),
      child: Center(
          child: Container(
        decoration: isActive
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 15,
                  )
                ],
              )
            : BoxDecoration(),
        child: Image.network(
          '$image',
          width: 35,
        ),
      )),
    );
  }

  void _showForgotPWDDialog() {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Email ID',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Product Sans',
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKeyForgotEmail,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 250,
              child: TextFormField(
                validator: (val) =>
                    ((val!.isEmpty)) ? 'Enter Email ID correctly' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
                initialValue: email,
                decoration: InputDecoration(
                  hintText: 'Enter email',
                  filled: true,
                  fillColor: Colors.blueGrey[50],
                  labelStyle: TextStyle(fontSize: 12),
                  contentPadding: EdgeInsets.only(left: 30),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey.withOpacity(0.05),
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey.withOpacity(0.05),
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    spreadRadius: 10,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ElevatedButton(
                child: Container(
                    width: 150, height: 50, child: Center(child: Text("Next"))),
                onPressed: _forgotEmainloading == false
                    ? () async {
                        if (_formKeyForgotEmail.currentState!.validate()) {
                          setState(() {
                            _forgotEmainloading = true;
                          });
                          var result = await _auth.resetPasswordEmail(email);
                          print(result);
                          if (result == 1) {
                            setState(() {
                              isLogin = true;
                              _forgotEmainloading = false;
                            });
                            Navigator.pop(context);
                            ElegantNotification.error(
                              title: Text("Error"),
                              description: Text(
                                  "Your Email ID is not registered. Please enter correct email ID or registered yourself."),
                            );
                          } else {
                            Navigator.pop(context);
                            setState(() {
                              _forgotEmainloading = false;
                            });
                            ElegantNotification.info(
                              title: Text("Hey,"),
                              description: Text(
                                  "Reset link sent on your Email Address. Please reset password by using that link."),
                            );
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  primary: active,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
