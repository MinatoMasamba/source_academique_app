// lib/core/utils/image_utils.dart

class ImageUtils {
  // Collection d'images thème bibliothèque
  static const List<String> _libraryImages = [
    //'https://images.pexels.com/photos/159711/books-bookcase-library-read-159711.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/12064/pexels-photo-12064.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/2041540/pexels-photo-2041540.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/1106468/pexels-photo-1106468.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/267586/pexels-photo-267586.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/1290141/books-library-education-study-1290141.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/256450/pexels-photo-256450.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/207691/pexels-photo-207691.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/290595/pexels-photo-290595.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    //'https://images.pexels.com/photos/904616/pexels-photo-904616.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/7092456/pexels-photo-7092456.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/3768126/pexels-photo-3768126.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/1438072/pexels-photo-1438072.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
  ];
  
  
  // Collection d'images thème nature
  static const List<String> _natureImages = [
    'https://images.pexels.com/photos/3825586/pexels-photo-3825586.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/256262/pexels-photo-256262.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/577585/pexels-photo-577585.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/3913025/pexels-photo-3913025.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/2102416/pexels-photo-2102416.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/417173/pexels-photo-417173.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/158279/fir-tree-forest-nature-fog-158279.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/1431822/pexels-photo-1431822.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/1162251/pexels-photo-1162251.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/235734/pexels-photo-235734.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/1431822/pexels-photo-1431822.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/3225517/pexels-photo-3225517.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
    'https://images.pexels.com/photos/417074/pexels-photo-417074.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop',
  ];
  
  // Mapping type -> collection d'images
  static const Map<String, List<String>> _typeImages = {
    'cours': _libraryImages,
    'tp': _natureImages,
    'examen': _libraryImages,
    'interro': _natureImages,
    'note': _libraryImages,
    'article': _natureImages,
    'decouverte': _natureImages,
    'projet': _libraryImages,
  };
  
  /// Retourne une image par défaut selon le type de document
  static String getDefaultImage(String type, {int seed = 0}) {
    final images = _typeImages[type] ?? _libraryImages;
    final index = seed % images.length;
    return images[index];
  }
  
  /// Image par défaut universelle (bibliothèque)
  static const String defaultDocument = 'https://images.pexels.com/photos/1290141/books-library-education-study-1290141.jpeg?auto=compress&cs=tinysrgb&w=600&h=400&fit=crop';
}