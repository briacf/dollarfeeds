import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Services
import '../services/get_color.dart';

class ResetPasswordPage extends StatefulWidget {
  static const title = 'Reset Password';

  final String email;
  ResetPasswordPage({Key key, @required this.email}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();
  var _email;

  bool _emailSent = false;

  Future<void> resetPassword() async {
    final form = _formKey.currentState;
    form.save();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
    } catch(e) {
      Navigator.pop(context);
    }

    Future.delayed(const Duration(milliseconds: 1500), () => Navigator.pop(context));
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Container(
              child: Text('Reset Your Password',
                  style:
                      TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
              alignment: Alignment(-1, 0.0),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(
                  "Enter your email and we'll send you instructions to change your password",
                  style: TextStyle(fontSize: 18.0)),
            ),
            SizedBox(
              height: 40,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: TextFormField(
                      initialValue: widget.email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: new InputDecoration(
                          hintText: 'account@example.com',
                          fillColor: getTextFieldColor(context),
                          filled: true,
                          errorStyle: TextStyle(
                              color: getErrorColor(context), fontSize: 14),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 0.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding: new EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0)),
                      validator: (value) =>
                          value.isEmpty ? 'Email can\'t be empty' : null,
                      onSaved: (value) => _email = value.trim(),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: _emailSent == false ? RaisedButton(
                      elevation: 0,
                      color: getColor("default"),
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(5.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0)),
                      child: const Text('Send Instructions',
                          style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _emailSent = true;
                          });
                          resetPassword();
                        }
                      },
                    ) : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          CupertinoIcons.check_mark_circled,
                          color: Colors.green,
                          size: 30,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Reset Email Sent",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.green),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ]),
    );
  }

  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: getThemeColor(context),
        border: Border(bottom: BorderSide(color: getThemeColor(context))),
      ),
      body: _buildBody(context),
    );
  }
}
