import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Handler middleware(Handler handler) {
  return (context)async{
var db = Db('mongodb://localhost:27017/sagor');

    if(!db.isConnected){
      await db.open();
    }

    final response = await handler.use(provider((_) => db)).call(context);
    await db.close();

    return response;
  };
}
