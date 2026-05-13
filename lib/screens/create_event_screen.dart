import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../services/event_service.dart';

class CreateEventScreen
    extends StatefulWidget {

  const CreateEventScreen({
    super.key,
  });

  @override
  State<CreateEventScreen>
      createState() =>
          _CreateEventScreenState();

}

class _CreateEventScreenState
    extends State<
        CreateEventScreen> {

  final titleController =
      TextEditingController();

  final venueController =
      TextEditingController();

  final dateController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final picker =
      ImagePicker();

  final eventService =
      EventService();

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
            const Text(
          "Create Event",
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

                  "Choose Poster",

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

              TextField(

                controller:

                    venueController,

                decoration:

                    const InputDecoration(

                  labelText:
                      "Venue",

                ),
              ),

              TextField(

                controller:

                    dateController,

                decoration:

                    const InputDecoration(

                  labelText:
                      "Date",

                ),
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

                    await eventService
                        .createEvent(

                      title:

                          titleController
                              .text,

                      venue:

                          venueController
                              .text,

                      date:

                          dateController
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

                    "POST EVENT",

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