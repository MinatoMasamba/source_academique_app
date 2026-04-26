import 'package:source_academique/core/network/dio_client.dart';
import 'package:source_academique/core/constants/api_endpoints.dart';
import 'package:source_academique/features/auth/domain/entities/etablissement.dart';


class AcademicRepository {
  final DioClient _dioClient;

  AcademicRepository(this._dioClient);

  /// 1. Récupère la liste de toutes les universités
  /// URL: /universities/
  Future<List<Universite>> getUniversities() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.universities);
      
      // Ton backend renvoie {'universities': [[id, nom, logo], ...]}
      final List rawData = response.data['universities'];
      
      return rawData.map((data) => Universite(
        id: data[0],
        nom: data[1],
        logo: data[2],
      )).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 2. Récupère les facultés liées à une université spécifique
  /// URL: /universities/$uniId/faculties/
  Future<List<Faculte>> getFaculties(int uniId) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.faculties(uniId));
      
      // Ton backend renvoie {'faculties': [[id, nom], ...]}
      final List rawData = response.data['faculties'];
      
      return rawData.map((data) => Faculte(
        id: data[0],
        nom: data[1],
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// 3. Récupère les départements liés à une faculté spécifique
  /// URL: /faculties/$facId/departments/
  Future<List<Departement>> getDepartments(int facId) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.departments(facId));
      
      // Ton backend renvoie {'departments': [[id, nom], ...]}
      final List rawData = response.data['departments'];
      
      return rawData.map((data) => Departement(
        id: data[0],
        nom: data[1],
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// 4. Recherche optionnelle d'une université par ID (pour détails)
  Future<Universite?> getUniversityDetails(int id) async {
    try {
      final response = await _dioClient.dio.get('${ApiEndpoints.universities}$id/');
      return Universite.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}