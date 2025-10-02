# ProGuard / R8 custom rules for My Best Friend app
# Mantén este archivo si activas minifyEnabled/shrinkResources.
# Puedes añadir reglas específicas si algo se ofusca indebidamente (crashes por ClassNotFound, etc.).

# Ejemplos útiles (descomenta según necesidad):
# - Mantener modelos usados por reflexión / serialización JSON
# -keep class com.example.my_best_friend_app.model.** { *; }

# Mantener clases de Flutter y plugins (normalmente ya cubierto por reglas del plugin, pero por seguridad):
# -keep class io.flutter.app.** { *; }
# -keep class io.flutter.plugins.** { *; }
# -keep class io.flutter.embedding.** { *; }

# Si usas Gson / Moshi / Jackson, añade reglas correspondientes.

# Por ahora no se requieren reglas personalizadas.
