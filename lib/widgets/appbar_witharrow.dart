import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final Color backgroundColor;

  const CustomAppBar({
    Key? key,
    required this.titleText,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      shadowColor: Colors.grey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        side: BorderSide(color: Colors.grey, width: 0.5),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 222, 237, 249),
              Color.fromARGB(255, 183, 221, 252),
              Color.fromARGB(255, 173, 186, 202),
              Color.fromARGB(255, 175, 215, 248),
            ],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        child: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false, 
          backgroundColor: Colors.transparent, 
          elevation: 0, // Remove AppBar shadow
          leading: Navigator.canPop(context) ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(221, 8, 0, 119)),
          onPressed: () => Navigator.of(context).pop(),
          ) : null,

          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Image.asset('assets/images/cradle_logo.png', scale: 30), 
              const SizedBox(width: 10),
              Text(
                titleText,
                style: const TextStyle(
                  color: Color.fromARGB(221, 8, 0, 119),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10); 
}
