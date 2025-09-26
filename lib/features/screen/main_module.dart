import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/features/dialogs/get_instruments.dart';
import 'package:sergey_sobyanin/repositories/database/database_service.dart';
import 'package:sergey_sobyanin/repositories/database/models/user.dart';

class MainModule extends StatefulWidget {
  const MainModule({
    super.key,
    required this.centerW,
    required this.h,
  });

  final double centerW;
  final double h;

  @override
  State<MainModule> createState() => _MainModuleState();
}

class _MainModuleState extends State<MainModule> {
  final database = DatabaseService();
  String id = "";

  Future<CustomUser> fetchOrCreateUserById(String id) async {
    final ref = FirebaseFirestore.instance.collection(collectionPath).doc(id);
    final snap = await ref.get();

    if (!snap.exists) {
      // создаём нового пользователя
      final user = CustomUser(
        pictureData: '',
        session: 0,
        result: {},
        id: id,
        // здесь добавь дефолтные значения для остальных обязательных полей
      );
      await ref.set(user.toJson());
      return user;
    }

    // документ есть → парсим
    final map = (snap.data() as Map<String, dynamic>?) ?? <String, dynamic>{};

    map.putIfAbsent('id', () => id); // чтобы id точно был в модели

    return CustomUser.fromJson(map);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.centerW,
      height: widget.h,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            "Введите id инженера",
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500),
          ),
          Container(
              width: 700,
              height: 70,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(offset: Offset(0, 4), blurRadius: 4, spreadRadius: 0, color: Colors.black26)]),
              child: TextField(
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 28, color: Colors.black87),
                maxLength: 20,
                onChanged: (value) => setState(() {
                  id = value;
                }),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: EdgeInsets.only(left: 10, bottom: 30),
                  counterText: "",
                  border: InputBorder.none,
                  labelText: "Ваш id",
                  labelStyle: TextStyle(color: Colors.black12, fontSize: 28, fontWeight: FontWeight.w700),
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(left: 500, top: 5),
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(10),

              color: Colors.transparent, // нужен Material-предок для волны
              child: InkWell(
                onTap: id != ''
                    ? () async {
                        final user = await fetchOrCreateUserById(id);

                        log(user.id.toString());

                        // showDialog(
                        //     context: context,
                        //     builder: (context) => GetInstrumentsDialog(
                        //           id: id,
                        //         ));
                      }
                    : () {},
                borderRadius: BorderRadius.circular(10),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Color(CustomColors.accent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                      width: 200,
                      height: 60,
                      alignment: Alignment.center,
                      child: Text(
                        'Готово',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w500),
                      )),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
