// import 'package:dio/dio.dart';
// import 'package:retrofit/retrofit.dart';
// import '../../../domain/entities/note.dart';

// part 'api_service.g.dart';

// @RestApi()
// abstract class ApiService {
//   factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

//   @GET("/notes")
//   Future<List<Note>> getNotes();

//   @POST("/notes")
//   Future<Note> createNote(@Body() Note note);

//   @PUT("/notes/{id}")
//   Future<Note> updateNote(@Path("id") String id, @Body() Note note);

//   @DELETE("/notes/{id}")
//   Future<void> deleteNote(@Path("id") String id);

//   @POST("/sync")
//   Future<Map<String, dynamic>> syncData(@Body() Map<String, dynamic> data);
// }
