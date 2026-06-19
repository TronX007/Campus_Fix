import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/idea_model.dart';
import '../services/firestore_service.dart';
import '../utils/image_utils.dart';

class IdeaProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<IdeaModel>>? _ideasSubscription;

  List<IdeaModel> _ideas = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<IdeaModel> get ideas => _ideas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadIdeas() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _ideas = await _firestoreService.getIdeas();
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint("loadIdeas error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void startListeningToIdeas() {
    _ideasSubscription?.cancel();
    _setLoading(true);
    _errorMessage = null;
    _ideasSubscription = _firestoreService.getIdeasStream().listen(
      (ideasSnapshot) {
        _ideas = ideasSnapshot;
        _errorMessage = null;
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = _parseError(error);
        _setLoading(false);
        notifyListeners();
      },
    );
  }

  Future<void> addIdea(IdeaModel idea, {File? imageFile}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      String? imageBase64;
      if (imageFile != null) {
        imageBase64 = await ImageUtils.compressAndEncode(imageFile)
            .timeout(const Duration(seconds: 15));
      }

      final updatedIdea = idea.copyWith(imageBase64: imageBase64);
      await _firestoreService.addIdea(updatedIdea);
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint("addIdea error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleUpvote(String ideaId, String userId) async {
    final index = _ideas.indexWhere((i) => i.id == ideaId);
    if (index == -1) return;

    final idea = _ideas[index];
    final hasUpvoted = idea.upvotes.contains(userId);
    final updatedUpvotes = List<String>.from(idea.upvotes);

    if (hasUpvoted) {
      updatedUpvotes.remove(userId);
    } else {
      updatedUpvotes.add(userId);
    }

    // Optimistic UI update
    _ideas[index] = idea.copyWith(upvotes: updatedUpvotes);
    notifyListeners();

    try {
      await _firestoreService.toggleUpvoteIdea(ideaId, userId, !hasUpvoted);
    } catch (e) {
      // Revert optimistic update on failure
      final revertIndex = _ideas.indexWhere((i) => i.id == ideaId);
      if (revertIndex != -1) {
        _ideas[revertIndex] = idea; // revert to original
        notifyListeners();
      }
      _errorMessage = _parseError(e);
      debugPrint("toggleUpvote error: $e");
      rethrow;
    }
  }

  Future<void> deleteIdea(String ideaId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _firestoreService.deleteIdea(ideaId);
      _ideas.removeWhere((i) => i.id == ideaId);
      notifyListeners();
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint("deleteIdea error: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String _parseError(dynamic e) {
    if (e is TimeoutException) {
      return "Operation timed out. Please check database connectivity.";
    }
    final str = e.toString().toLowerCase();
    if (str.contains('permission') || str.contains('denied')) {
      return "Database error occurred.";
    }
    if (str.contains('network') || str.contains('timeout') || str.contains('offline')) {
      return "Network connection lost.";
    }
    return e.toString();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _ideasSubscription?.cancel();
    super.dispose();
  }
}
