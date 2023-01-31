import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomePage1 extends StatelessWidget {
  const HomePage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropShadow(
                child: Image.network(
                  'https://images.pexels.com/photos/1191639/pexels-photo-1191639.jpeg',
                  width: 250,
                ),
              ),
              const SizedBox(height: 35),
              ZoomTapAnimation(
                onTap: () {},
                child: DropShadow(
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.8, color: Colors.white54),
                      gradient: const LinearGradient(colors: [
                        Colors.blueAccent,
                        Colors.purpleAccent,
                        Colors.orangeAccent
                      ]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              DropShadow(
                child: Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.blueAccent,
                        Colors.purpleAccent,
                        Colors.orangeAccent
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              const DropShadow(
                child: Text(
                  'Ehuehuehueuhe',
                  style: TextStyle(fontSize: 35, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
