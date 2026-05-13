import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../services/club_post_service.dart';

class CreateClubPostScreen
    extends StatefulWidget {

  final String club;

  const CreateClubPostScreen({

    super.key,

    required this.club,

  });

  @override
  State<CreateClubPostScreen>
      createState() =>
          _CreateClubPostScreenState();

}

class _CreateClubPostScreenState
    extends State<
        CreateClubPostScreen> {

  final titleController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final picker =
      ImagePicker();

  final clubService =
      ClubPostService();

  File? selectedImage;

  Future pickImage()
  async {

    final image =

        await picker
            .pickImage(

      source:
          ImageSource.gallery,

    );

    if(
      image == null
    ) return;

    setState(() {

      selectedImage =

          File(
            image.path,
          );

    });

  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:

          Colors.grey[100],

      appBar: AppBar(

        title:
            Text(
          widget.club,
        ),
      ),

      body: SingleChildScrollView(

        child: Padding(

          padding:

              const EdgeInsets
                  .all(
            20,
          ),

          child: Column(

            children: [

              if(
                selectedImage
                    != null
              )

                ClipRRect(

                  borderRadius:

                      BorderRadius
                          .circular(
                    20,
                  ),

                  child:
                      Image.file(

                    selectedImage!,

                    height:
                        220,

                  ),
                ),

              const SizedBox(
                height: 15,
              ),

              ElevatedButton(

                onPressed:
                    pickImage,

                child:
                    const Text(

                  "Choose Photo",

                ),
              ),

              const SizedBox(
                height: 20,
              ),

              TextField(

                controller:

                    titleController,

                decoration:

                    const InputDecoration(

                  labelText:
                      "Title",

                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextField(

                controller:

                    descriptionController,

                maxLines: 4,

                decoration:

                    const InputDecoration(

                  labelText:
                      "Description",

                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(

                width:
                    double.infinity,

                height: 55,

                child:
                    ElevatedButton(

                  onPressed:
                      () async {

                    if(
                      selectedImage
                          ==
                      null
                    ){

                      return;

                    }

                    await clubService
                        .createPost(

                      title:

                          titleController
                              .text,

                      description:

                          descriptionController
                              .text,

                      image:
                          selectedImage!,

                    );

                    Navigator.pop(
                      context,
                    );

                  },

                  child:
                      const Text(

                    "POST",

                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}