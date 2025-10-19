import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/Colors/app_colors.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MYColors.gradientColor_3,
            MYColors.gradientColor_1.withValues(alpha: 0.35),
            MYColors.gradientColor_3,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
body: Center(
  child: SizedBox(

    height: 1092,
    width: 1010,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),

        Container(
          width: 1092,
          height: 92,
          decoration: BoxDecoration(
            color: Color(0xffF5FAFF).withValues(alpha: 0.5),

          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xffF5FAFF),
                ),

                width: 367,
                height: 38,
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,


                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    hintText: "Search",
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    fontFamily: "inter",
                      color: Color(0xFFADA7A7),
                    ),
                    prefixIcon: SvgPicture.asset("assets/icons/search.svg")
                )),
              ),
              Row(
                children: [
                  Badge(smallSize: 7,
                    backgroundColor: Color(0xffFF3B30),
                    offset: Offset(-4, 0),child: InkWell(
                      onTap: (){},
                      child: SvgPicture.asset("assets/icons/message-icon.svg",
                                        colorFilter: ColorFilter.mode(Colors.lightBlueAccent, BlendMode.srcIn),

                                        ),
                    ),   ),
                  SizedBox(width: 23),
                  Badge(
                    offset: Offset(2, 0),

                    backgroundColor: Color(0xffFF3B30),
                    smallSize: 7,child: InkWell(
                      onTap: (){},
                      child: SvgPicture.asset("assets/icons/bell_icon.svg",
                        colorFilter: ColorFilter.mode(Colors.lightBlueAccent, BlendMode.srcIn),),
                    ),
                  ),
                  SizedBox(width: 35),
                  CircleAvatar(
                    radius: 17,
                    backgroundImage: AssetImage("assets/logo/logo.jpg"),
                  ),
                  SizedBox(width: 12),
                  Text("Mohamed Ahmed",style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: "inter",
                    color: Colors.black

                  ),
                  ),
                  SizedBox(width: 10,),
                  IconButton(onPressed: (){}, icon: Icon(Icons.keyboard_arrow_down_outlined))
                ],
              )
            ]
          ),
        ),
        Container(
width: 1092,
          height: 600,
          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
          decoration: BoxDecoration(
            color: Color(0xffF5FAFF),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12),bottomRight: Radius.circular(12))
          ),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20

          ),
          physics: NeverScrollableScrollPhysics()
          ,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Colors.lightBlueAccent,

                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    fontFamily: "inter",
                  ),
                ),
                SizedBox(width: 5),
                Image.asset("assets/icons/hand.png"),
              ],
            ),
            Text(
              "Start your learning journey now — your next big achievement starts here!",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: "inter",
                color: Color(0xFF545F70),
              ),
            ),
          ],
        ),
        )

  ,

      ],
    ),
  ),
),
      ),
    );
  }
}
