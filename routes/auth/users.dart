import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getUser(context),
    HttpMethod.post => _createUser(context),
    _ => Future.value(Response.json(statusCode: HttpStatus.methodNotAllowed))
  };
}

///=====================Get User=========================>
Future<Response> _getUser(RequestContext context) async {
  final userList = await context.read<Db>().collection('user').find().toList();
  final userJsonList = userList
      .map((user) => {
            '_id': user['_id'].toHexString(),
            'name': user['name'],
            'age': user['age'],
            'email': user['email']
          })
      .toList();

  return Response.json(body: {
    'status' : "success",
    'message' : "User fetch successful",
    'data' : userJsonList
  });
}

///=====================Create New User===================>
Future<Response> _createUser(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final name = body['name'] as String?;
  final age = body['age'] as int?;
  final email = body['email'] as String?;

  if (name == null || age == null || email == null) {
    return Response.json(body: {
      "message": "Missing required fields: name, age, email",
      'statusCode': 400
    });
  }

  final user = <String, dynamic>{"name": name, "age": age, "email": email};

  final result = await context.read<Db>().collection('user').insertOne(user);

  return Response.json(body: {
    'status': 'success',
    "message": "user create successfully",
    'data': {'_id': result.id,   'name': name, 'age': age, 'email': email}
  });
}
