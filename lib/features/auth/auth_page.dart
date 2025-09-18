import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/tiles.dart';
import 'package:sergey_sobyanin/features/auth/auth_error_hander.dart';
import 'package:sergey_sobyanin/repositories/auth/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool obscureBool = true;
  String? username;
  String? password;
  AuthService auth = AuthService();

  void signIn(String em, String p) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(CustomColors.mainLight)),
            ),
          );
        });

    final List user = await auth.loginUserWithEmailAndPassword(em, p);
    Navigator.pop(context);
    Navigator.of(context).pushNamed('/');

    if (user[0] == 0) {
      if (user[1].emailVerified) {
        log(user[1].emailVerified.toString());
        log("Успешный вход");
      } else {
        showModalBottomSheet(context: context, builder: (BuildContext context) => const AuthDenySheet(type: "verify"));
      }
    } else if (user[0] == 1) {
      log("Ошибка ${user[1]}");

      showModalBottomSheet(context: context, builder: (BuildContext context) => AuthDenySheet(type: user[1]));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return Container(
      decoration: BoxDecoration(gradient: BackgroundGrad()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height / 8),

                    Container(
                      height: 200,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 20),
                            child: Transform.rotate(
                                angle: math.pi,
                                child: Image.asset("images/triangle.png",
                                    scale: 1.3,
                                    opacity: const AlwaysStoppedAnimation(0.05),
                                    alignment: Alignment.center)),
                          ),
                          Text(
                            '  Система ТОиР  ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 96,
                              fontFamily: 'Jura',
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(0.0, 4.0),
                                  blurRadius: 5.0,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(left: 160.0),
                    //   child: SizedBox(
                    //     width: 400,
                    //     height: 40,
                    //     child: Text(
                    //       "One app to rule them all",
                    //       style: TextStyle(color: Colors.white, fontSize: 18),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
                SizedBox(height: height / 15),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        offset: Offset(0.0, 4.0),
                        blurRadius: 4.0,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  width: 470,
                  height: 370,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 35),
                      Text(
                        'Вход в учетную запись',
                        style: GoogleFonts.unbounded(
                          color: Color(CustomColors.main),
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        height: 50,
                        width: 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Color(CustomColors.main), width: 6),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(Icons.mail_outline, size: 30, color: Color(CustomColors.bright)),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 240,
                              height: 60,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints.expand(width: 700),
                                  child: TextField(
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black87),
                                    maxLength: 35,
                                    onChanged: (value) => setState(() {
                                      username = value;
                                    }),
                                    decoration: const InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      contentPadding: EdgeInsets.only(bottom: 15),
                                      counterText: "",
                                      border: InputBorder.none,
                                      labelText: "Почта",
                                      labelStyle: TextStyle(
                                        color: Colors.black12,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 50,
                        width: 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Color(CustomColors.main), width: 6),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(Icons.lock_outline, size: 30, color: Color(CustomColors.bright)),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 220,
                              height: 60,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints.expand(width: 550), // 18 - fontSize
                                  child: TextField(
                                    obscureText: obscureBool,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black87),
                                    maxLength: 30,
                                    onChanged: (value) => setState(() {
                                      password = value;
                                    }),
                                    decoration: const InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      contentPadding: EdgeInsets.only(bottom: 15),
                                      counterText: "",
                                      border: InputBorder.none,
                                      labelText: "Пароль",
                                      labelStyle: TextStyle(
                                        color: Colors.black12,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                iconSize: 25,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => setState(() {
                                      obscureBool = !obscureBool;
                                    }),
                                icon: !obscureBool ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off))
                          ],
                        ),
                      ),
                      // const SizedBox(height: 5),
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.of(context).pushNamed("/auth/forgot");
                      //     log("Forgot the password");
                      //   },
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(left: 150),
                      //     child: Text(
                      //       "Забыли пароль?",
                      //       style: TextStyle(
                      //         color: Color(CustomColors.main),
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.w600,
                      //         decoration: TextDecoration.underline,
                      //         decorationColor: Color(CustomColors.main),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 40),
                      Container(
                        height: 40,
                        width: 250,
                        decoration: BoxDecoration(
                            gradient: ButtonGrad(),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(spreadRadius: 1, offset: Offset(0, 2), blurRadius: 2, color: Colors.black26)
                            ]),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                          onPressed: () async {
                            if (username == null || password == null) {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) => const AuthDenySheet(type: "none"));
                            } else if (username!.length < 4 || password!.length < 4) {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) => const AuthDenySheet(type: "length"));
                            } else {
                              log("Логин: $username, пароль: $password");
                              signIn(username!, password!);
                            }
                          },
                          child: const Text(
                            "Войти",
                            style: TextStyle(
                                color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700, fontFamily: 'Jura'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed("/auth/create");
                        },
                        child: Text(
                          'Создать аккаунт',
                          style: TextStyle(
                              color: Color(CustomColors.main),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: Color(CustomColors.main),
                              fontFamily: "Jura"),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 100)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
