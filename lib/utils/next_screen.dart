import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NextScreen {
  static void normal(context, page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  static void iOS(context, page) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => page));
  }

  static void closeOthers(context, page) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => page), (route) => false);
  }

  static void replace(context, page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
  }

  static void popup(context, page) {
    Navigator.push(
      context,
      MaterialPageRoute(fullscreenDialog: true, builder: (context) => page),
    );
  }

  static void replaceAnimation(context, page) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
    ));
  }

  // Жаңа анимация: Солдан оңға қарай ашылу (Slide Left to Right)
  static void replaceSlideAnimation(context, page) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0); // Сол жақтан бастау
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ));
  }

  static void closeOthersAnimation(context, page) {
    Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        ),
        ((route) => false));
  }

  static void openBottomSheet(context, page, {double maxHeight = 0.95, bool isDismissable = true}) {
    showModalBottomSheet(
      enableDrag: isDismissable,
      isScrollControlled: true,
      isDismissible: isDismissable,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.50,
        maxHeight: MediaQuery.of(context).size.height * maxHeight,
      ),
      context: context,
      builder: (context) => page,
    );
  }
}
