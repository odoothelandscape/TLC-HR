import 'package:flutter/material.dart';

import '../../utility/style/theme.dart';
import 'package:talent_hr/app/locale_controller.dart';


class ErrorDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final IconData icon;
  const ErrorDialog({ Key? key, required this.title,required this.content,required this.icon }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 20,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 70),
            height: 250,
            width: 400,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                color: Colors.white),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.redAccent
      ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child:content,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(),
                const SizedBox(
                  height:20,
                ),
                 ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(
                  ColorObj.mainColor
                  )), onPressed: (){Navigator.pop(context);}, child: Text(context.l10n.ok))
              ],
            ),
          ),
          Positioned(
            top: -55,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 8,color: Colors.white),
                shape: BoxShape.circle
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.red,
                child: Icon(
                  icon,
                  size: 55,
                  color: Colors.yellow,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}