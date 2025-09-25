class PetFormState {
  String? situation; // "Acabo de tener un perro" | "Ya conozco bien a mi perro"
  String? name;
  String? sex; // Macho | Hembra
  DateTime? birthday;
  String? breed;
  bool? tracking; // seguimiento de comidas/vacunas
  Set<String> lifestyle = {};
  bool? coCare; // cuidas con alguien
  String? role; // Dueño | Cuidador
}
