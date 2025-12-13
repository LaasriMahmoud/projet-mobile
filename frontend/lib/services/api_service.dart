import 'package:dio/dio.dart';
import 'storage_service.dart';
import '../models/user.dart';
import '../models/offre.dart';
import '../models/candidature.dart';

class ApiService {
  // Android Emulator : Utiliser 10.0.2.2 pour accéder au localhost de la machine hôte
  // Web : Utiliser localhost
  // iOS Simulator : Utiliser localhost
  static const String baseUrl = 'http://10.0.2.2:8000';
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ));

    // Interceptor to add JWT token to requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401 Unauthorized
        if (error.response?.statusCode == 401) {
          StorageService.deleteToken();
        }
        return handler.next(error);
      },
    ));
  }

  // Auth endpoints
  Future<User> register(String email, String username, String password, String role) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'username': username,
        'password': password,
        'role': role,
      });
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final formData = FormData.fromMap({
        'username': email, // OAuth2 uses 'username' field
        'password': password,
      });
      
      final response = await _dio.post('/auth/login', data: formData);
      final token = response.data['access_token'];
      await StorageService.saveToken(token);
      return token;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await StorageService.deleteToken();
  }

  // Offres endpoints
  Future<List<Offre>> getOffres() async {
    try {
      final response = await _dio.get('/offres/');
      return (response.data as List).map((json) => Offre.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Offre> getOffre(int id) async {
    try {
      final response = await _dio.get('/offres/$id');
      return Offre.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Offre> createOffre(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/offres/', data: data);
      return Offre.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Offre> updateOffre(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/offres/$id', data: data);
      return Offre.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteOffre(int id) async {
    try {
      await _dio.delete('/offres/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Candidatures endpoints
  Future<Candidature> submitCandidature({
    required int offreId,
    required String nom,
    required String prenom,
    String? dateNaissance,
    String? telephone,
    required String cne,
    required String mention,
    required String cinImagePath,
    required String bacImagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'offre_id': offreId,
        'nom': nom,
        'prenom': prenom,
        if (dateNaissance != null) 'date_naissance': dateNaissance,
        if (telephone != null) 'telephone': telephone,
        'cne': cne,
        'mention': mention,
        'cin_image': await MultipartFile.fromFile(cinImagePath, filename: 'cin.jpg'),
        'bac_image': await MultipartFile.fromFile(bacImagePath, filename: 'bac.jpg'),
      });

      final response = await _dio.post('/candidatures/', data: formData);
      return Candidature.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get my candidatures with grades info
  Future<List<Map<String, dynamic>>> getMyCandidaturesWithGrades() async {
    try {
      final response = await _dio.get('/candidatures/my-candidatures');
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Candidature>> getMyCandidatures() async {
    try {
      final response = await _dio.get('/candidatures/me');
      return (response.data as List).map((json) => Candidature.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Candidature>> getCandidaturesForOffre(int offreId) async {
    try {
      final response = await _dio.get('/candidatures/offre/$offreId');
      return (response.data as List).map((json) => Candidature.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Add or update semester grade
  Future<void> addCandidatureGrade({
    required int candidatureId,
    required int semesterNumber,
    required String diplomaType,
    required String academicYear,
    required double average,
  }) async {
    try {
      await _dio.post(
        '/candidatures/$candidatureId/grades',
        queryParameters: {
          'semester_number': semesterNumber,
          'diploma_type': diplomaType,
          'academic_year': academicYear,
          'average': average,
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Submit grades (change status to SUBMITTED)
  Future<void> submitCandidatureGrades(int candidatureId) async {
    try {
      await _dio.post('/candidatures/$candidatureId/submit-grades');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delete a grade
  Future<void> deleteCandidatureGrade(int gradeId) async {
    try {
      await _dio.delete('/candidatures/grades/$gradeId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Admin endpoints
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get('/admin/users');
      return (response.data as List).map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateUserStatus(int userId, bool isActive) async {
    try {
      final response = await _dio.put(
        '/admin/users/$userId/status',
        queryParameters: {'is_active': isActive},
      );
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Offre>> getPendingOffres() async {
    try {
      final response = await _dio.get('/admin/offres/pending');
      return (response.data as List).map((json) => Offre.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Offre> validateOffre(int offreId, String status) async {
    try {
      final response = await _dio.put('/admin/offres/$offreId/validate', data: {
        'status': status,
      });
      return Offre.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _dio.get('/admin/statistics');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getStudents({
    String? diploma,
    double? minAverage,
    double? maxAverage,
    String? profileStatus,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (diploma != null) queryParams['diploma'] = diploma;
      if (minAverage != null) queryParams['min_average'] = minAverage;
      if (maxAverage != null) queryParams['max_average'] = maxAverage;
      if (profileStatus != null) queryParams['profile_status'] = profileStatus;

      final response = await _dio.get('/admin/students', queryParameters: queryParams);
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Admin - Get all candidatures
  Future<List<Map<String, dynamic>>> getAdminCandidatures({String? statusFilter}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (statusFilter != null) queryParams['status_filter'] = statusFilter;
      
      final response = await _dio.get('/admin/candidatures', queryParameters: queryParams);
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Admin - Get candidature details
  Future<Map<String, dynamic>> getAdminCandidatureDetails(int candidatureId) async {
    try {
      final response = await _dio.get('/admin/candidatures/$candidatureId');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Admin - Update candidature status
  Future<void> updateCandidatureStatus({
    required int candidatureId,
    required String newStatus,
    String? commentaire,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'new_status': newStatus,
      };
      if (commentaire != null) queryParams['commentaire'] = commentaire;

      await _dio.put(
        '/admin/candidatures/$candidatureId/status',
        queryParameters: queryParams,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        if (error.response?.data is Map<String, dynamic>) {
          return error.response?.data['detail'] ?? 'Une erreur est survenue';
        }
        return 'Erreur: ${error.response?.statusCode}';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Délai de connexion dépassé';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Erreur de connexion au serveur';
      }
      return 'Erreur de réseau';
    }
    return 'Une erreur inattendue est survenue';
  }
}
