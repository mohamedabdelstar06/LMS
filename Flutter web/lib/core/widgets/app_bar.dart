import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../generated/assets.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {

  const CustomAppBar({super.key,});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
        height: 100,
      decoration: BoxDecoration(
        color: Color(0xffE3F6FF),
      ) ,
      child: Center(
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(Assets.logo),
            ),

            SizedBox(
              width: 400,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                InkWell(
                  onTap: (){},
                  child: Text("Home",style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: "inter",
                    color: Color(0xff0D2772)

                  ))),
                 Spacer(),
                  InkWell(
                      onTap: (){},
                      child: Text("My Courses",style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: "inter",
                          color: Color(0xff0D2772)

                      ))),
              Spacer(),
                  InkWell(
                      onTap: (){},
                      child: Text("Dashboard",style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: "inter",
                          color: Color(0xff0D2772)

                      ))),

                ],
              ),
            ),
            SizedBox(
              width: 180,
              child: Row(
                mainAxisSize: MainAxisSize.min,

                children: [


                  InkWell(child: SvgPicture.asset(Assets.iconsSearchIcon),onTap: (){},),
            Spacer(),
                  InkWell(child: SvgPicture.asset(Assets.iconsBellIcon),onTap: (){},),
                  Spacer(),
                  InkWell(child: SvgPicture.asset(Assets.iconsMessageIcon),onTap: (){},),
                  Spacer(),
                  InkWell(child: SvgPicture.asset(Assets.iconsManIcon),onTap: (){},),




                ],
              ),
            )

          ]
        ),
      ),
    );
    //   AppBar(
    //   backgroundColor: Colors.teal,
    //   centerTitle: true,
    //   leading: IconButton(
    //     icon: const Icon(Icons.arrow_back),
    //     onPressed: () => Navigator.pop(context),
    //   ),
    //
    //   actions: [
    //     IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
    //   ],
    // );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
