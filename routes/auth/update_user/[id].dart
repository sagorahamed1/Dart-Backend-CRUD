
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  return switch (context.request.method) {
    HttpMethod.put => _updateProfile(context, id),
    HttpMethod.delete => _deleteUser(context, id),
    _ => Future.value(Response.json(statusCode: HttpStatus.methodNotAllowed))
  };
}

///==========================Update Profile===========================>
Future<Response> _updateProfile(RequestContext context, String id) async {
  try {
    var objectId = ObjectId.fromHexString(id);
    var body = await context.request.json() as Map<String, dynamic>;

    if (body == null || !body.containsKey('name') || !body.containsKey('age')) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Missing required fields: name and age'},
      );
    }

    final name = body['name'] as String?;
    final age = body['age'] as int?;
    final email = body['email'] as String?;

    if (name == null || name.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Name must not be empty'},
      );
    }

    if (age == null || age < 0 || age > 120) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Age must be a valid integer between 0 and 120'},
      );
    }

    final updateResult = await context
        .read<Db>()
        .collection('user')
        .updateOne(where.eq('_id', objectId), modify.set('name', name).set('age', age));

        print("====>id ${updateResult.id}");

    if (updateResult.id == 0) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'User not found'},
      );
    }

    return Response.json(
      statusCode: HttpStatus.noContent,
      body: {
        'status' : "success",
        'message' : "user update successful",
        'data' : {
          'id' : id,
          "name" : name,
          'age' : age
        }
      }
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'An unexpected error occurred', 'details': e.toString()},
    );
  }
}

///=======================Delete User===========================>


Future<Response> _deleteUser(RequestContext context, String id) async {
  try {
    var objectId = ObjectId.fromHexString(id); // Convert the string id to ObjectId
    var result = await context.read<Db>().collection('user').deleteMany({'_id': objectId});

    // Check if any document was deleted
    if (result.nRemoved != null && result.nRemoved > 0) {
      return Response.json(
        statusCode: HttpStatus.noContent,
        body: {
          'status': 'success',
          'message': 'User(s) deleted successfully',
        },
      );
    } else {
      // If no document was deleted, it means the user(s) was not found
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {
          'status': 'error',
          'message': 'User(s) not found',
        },
      );
    }
  } catch (e) {
    // Handle any errors that occurred during the deletion
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'message': 'An error occurred while deleting the user(s)',
        'details': e.toString(),
      },
    );
  }
}
