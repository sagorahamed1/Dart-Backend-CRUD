import 'package:dart_frog/dart_frog.dart';

Response onRequest (RequestContext context){
    final message = context.read<String>();
  return Response.json(
    body: {
      "name" : "sagor",
      "email" : "sagor@gmail.com",
      "pass" : message
    }
  );
}