//library commonly used for dart files
import 'package:flutter/material.dart';

//background stateless widget function
class BackgroundImage extends StatelessWidget {
  const BackgroundImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.grey, Colors.black12],
        begin: Alignment.bottomCenter,
        end: Alignment.center,
      ).createShader(bounds),blendMode: BlendMode.darken,
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
          //insert any image to show on the background from the asset/images directory
            /*image: DecorationImage(
                image: AssetImage('assets/images/mc_logo1.png'),
                fit: BoxFit.fitWidth,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.darken)
            )*/
        ),
      ),
    );
  }
}