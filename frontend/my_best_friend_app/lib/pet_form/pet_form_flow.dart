import 'package:flutter/material.dart';

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

// 1. Situación actual
class PetFormSituationScreen extends StatelessWidget {
  final PetFormState state;
  const PetFormSituationScreen({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              '¿Qué es lo más se\nacomoda a tú\nsituación actual?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 28),
            _FullWidthGreenButton(
              label: 'Acabo de tener un perro',
              onTap: () {
                state.situation = 'Acabo de tener un perro';
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PetFormNameScreen(state: state)),
                );
              },
            ),
            const SizedBox(height: 12),
            _FullWidthGreenButton(
              label: 'Ya conozco bien a mi perro',
              onTap: () {
                state.situation = 'Ya conozco bien a mi perro';
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PetFormNameScreen(state: state)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Nombre
class PetFormNameScreen extends StatefulWidget {
  final PetFormState state;
  const PetFormNameScreen({Key? key, required this.state}) : super(key: key);
  @override
  State<PetFormNameScreen> createState() => _PetFormNameScreenState();
}

class _PetFormNameScreenState extends State<PetFormNameScreen> {
  final TextEditingController _ctrl = TextEditingController();
  bool get _valid => _ctrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Cómo se llama tu\nperro?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Escribe el nombre',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),
            _NextButton(
              enabled: _valid,
              label: 'Siguiente',
              onTap: () {
                widget.state.name = _ctrl.text.trim();
                Navigator.push(context, MaterialPageRoute(builder: (_) => PetFormSexScreen(state: widget.state)));
              },
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  widget.state.name = 'Sin nombre';
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PetFormSexScreen(state: widget.state)));
                },
                child: const Text('No lo he elegido todavía', style: TextStyle(color: Colors.black87)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Sexo
class PetFormSexScreen extends StatelessWidget {
  final PetFormState state;
  const PetFormSexScreen({Key? key, required this.state}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¿Tú mascota es un?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: _FullWidthGreenButton(
                label: 'Macho',
                onTap: () {
                  state.sex = 'Macho';
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PetFormBirthdayScreen(state: state)));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FullWidthGreenButton(
                label: 'Hembra',
                onTap: () {
                  state.sex = 'Hembra';
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PetFormBirthdayScreen(state: state)));
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// 4. Cumpleaños
class PetFormBirthdayScreen extends StatefulWidget {
  final PetFormState state;
  const PetFormBirthdayScreen({Key? key, required this.state}) : super(key: key);
  @override
  State<PetFormBirthdayScreen> createState() => _PetFormBirthdayScreenState();
}

class _PetFormBirthdayScreenState extends State<PetFormBirthdayScreen> {
  int day = DateTime.now().day;
  int month = DateTime.now().month;
  int year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final months = const [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    // Ajustar el día válido según mes/año
    final int lastDay = DateTime(year, month + 1, 0).day;
    if (day > lastDay) {
      day = lastDay;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¿Cuándo es el\ncumpleaños de tu\nperro?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          // Selectores grandes y centrados
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 14,
                children: [
                  _PillSelector<int>(
                    width: 120,
                    items: List.generate(lastDay, (i) => i + 1),
                    value: day,
                    labelBuilder: (v) => '$v',
                    onChanged: (v) => setState(() => day = v),
                  ),
                  _PillSelector<int>(
                    width: 180,
                    items: List.generate(12, (i) => i + 1),
                    value: month,
                    labelBuilder: (v) => months[v - 1],
                    onChanged: (v) => setState(() => month = v),
                  ),
                  _PillSelector<int>(
                    width: 120,
                    items: List.generate(40, (i) => DateTime.now().year - i),
                    value: year,
                    labelBuilder: (v) => '$v',
                    onChanged: (v) => setState(() => year = v),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              height: 160,
              child: Image.asset('assets/images/perro_logo.png', fit: BoxFit.contain),
            ),
          ),
          const Spacer(),
          Center(
            child: TextButton(
              onPressed: () {
                widget.state.birthday = null;
                Navigator.push(context, MaterialPageRoute(builder: (_) => PetFormBreedScreen(state: widget.state)));
              },
              child: const Text('No lo sé', style: TextStyle(color: Colors.black87)),
            ),
          ),
          const SizedBox(height: 8),
          _NextButton(
            enabled: true,
            label: 'Siguiente',
            onTap: () {
              widget.state.birthday = DateTime(year, month, day);
              Navigator.push(context, MaterialPageRoute(builder: (_) => PetFormBreedScreen(state: widget.state)));
            },
          ),
        ]),
      ),
    );
  }
}

// 5. Raza
class PetFormBreedScreen extends StatefulWidget {
  final PetFormState state;
  const PetFormBreedScreen({Key? key, required this.state}) : super(key: key);
  @override
  State<PetFormBreedScreen> createState() => _PetFormBreedScreenState();
}

class _PetFormBreedScreenState extends State<PetFormBreedScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = kDogBreeds.where((b) => b.toLowerCase().contains(query.toLowerCase())).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¿De qué raza es tu\nperro?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Selecciona o introduce la raza', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar raza...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.black87)),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black87),
              itemBuilder: (context, i) {
                final item = filtered[i];
                return ListTile(
                  title: Text(item, style: const TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () {
                    widget.state.breed = item;
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PetFormTrackingScreen(state: widget.state)));
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// Lista extensa de razas para la búsqueda
const List<String> kDogBreeds = [
  'Mestizo',
  'Pastor Alemán',
  'Labrador Retriever',
  'Golden Retriever',
  'Bulldog',
  'Beagle',
  'Poodle',
  'Rottweiler',
  'Yorkshire Terrier',
  'Boxer',
  'Dachshund (Teckel)',
  'Siberian Husky',
  'Doberman',
  'Shih Tzu',
  'Border Collie',
  'Chihuahua',
  'Cocker Spaniel',
  'Pug',
  'French Bulldog',
  'Australian Shepherd',
  'Bichón Frisé',
  'Akita Inu',
  'American Pitbull Terrier',
  'Maltés',
  'Boston Terrier',
  'Jack Russell Terrier',
  'Shar Pei',
  'Samoyedo',
  'Weimaraner',
  'Gran Danés',
  'San Bernardo',
  'Basset Hound',
  'Husky Alaskano',
  'Galgo',
  'Setter Irlandés',
  'Fox Terrier',
  'Dálmata',
  'Staffordshire Bull Terrier',
  'Cane Corso',
  'Pinscher Miniatura',
  'Lhasa Apso',
  'Whippet',
  'Caniche Toy',
  'Pastor Belga',
  'Pastor Australiano',
  'Airedale Terrier',
  'Papillón',
  'Cavalier King Charles Spaniel',
  'Shiba Inu',
  'Basenji',
  'Bulldog Inglés',
  'Bulldog Francés',
  'Bóxer',
  'Pointer',
  'Kerry Blue Terrier',
  'Pomerania (Spitz)',
  'Perro de Agua Español',
  'Collie de Pelo Largo',
  'Collie de Pelo Corto',
  'Hovawart',
  'Keeshond',
  'Saluki',
  'Pekinés',
  'Affenpinscher',
  'Braco Alemán',
  'Chesapeake Bay Retriever',
  'Terranova',
  'Pastor Holandés',
  'Bobtail (Old English Sheepdog)',
  'Corgi Galés de Pembroke',
  'Corgi Galés de Cardigan',
  'Presa Canario',
  'Podenco Ibicenco',
  'Podenco Canario',
  'Perro Sin Pelo del Perú',
  'Xoloitzcuintle',
  'Galgo Español',
  'Perro Lobo Checoslovaco',
  'Cão de Água Português',
  'Alaskan Malamute',
  'Schipperke',
  'Bull Terrier',
  'Bullmastiff',
  'Leonberger',
  'Borzoi',
  'Norwegian Elkhound',
  'Spitz Finlandés',
  'Mastín Napolitano',
  'Mastín Tibetano',
  'Mastín Inglés',
  'Pastor Caucásico',
  'Spaniel Tibetano',
  'Spaniel Bretón',
  'Gran Pirineo',
  'Entlebucher Mountain Dog',
  'Appenzeller',
  'Boyero de Berna',
  'Pinscher Alemán',
  'Grifón de Bruselas',
  'Barbet',
  'Spinone Italiano',
  'Lagotto Romagnolo',
  'Azawakh',
  'Chow Chow',
  'Kooikerhondje',
  'Coton de Tuléar',
  'Perro Pastor de los Pirineos',
  'Hokkaido',
  'Kai',
  'Kishu',
  'Thai Ridgeback',
  'Rhodesian Ridgeback',
  'Pharaoh Hound',
  'American Eskimo',
  'Bergamasco',
  'Boerboel',
  'Bluetick Coonhound',
  'Treeing Walker Coonhound',
  'Redbone Coonhound',
  'English Springer Spaniel',
  'Field Spaniel',
  'Clumber Spaniel',
  'Sussex Spaniel',
  'Irish Setter',
  'Gordon Setter',
];

// 6. Seguimiento (comidas/vacunas)
class PetFormTrackingScreen extends StatelessWidget {
  final PetFormState state;
  const PetFormTrackingScreen({Key? key, required this.state}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¿Quieres hacer un seguimiento de comidas, vacunas y todo lo relacionado con tu perro?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: _OutlinedSegmentButton(
                label: 'Sí',
                onTap: () {
                  state.tracking = true;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PetFormLifestyleScreen(state: state)));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OutlinedSegmentButton(
                label: 'No',
                onTap: () {
                  state.tracking = false;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PetFormLifestyleScreen(state: state)));
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// 7. Estilo de vida (multi-selección)
class PetFormLifestyleScreen extends StatefulWidget {
  final PetFormState state;
  const PetFormLifestyleScreen({Key? key, required this.state}) : super(key: key);
  @override
  State<PetFormLifestyleScreen> createState() => _PetFormLifestyleScreenState();
}

class _PetFormLifestyleScreenState extends State<PetFormLifestyleScreen> {
  static const options = [
    'Soy una persona de ciudad',
    'Me gusta recibir gente',
    'Tengo hijos',
    'Me estreso mucho',
    'Otro',
  ];
  bool get _canContinue => widget.state.lifestyle.isNotEmpty;
  void _toggle(String v) {
    setState(() {
      if (widget.state.lifestyle.contains(v)) {
        widget.state.lifestyle.remove(v);
      } else {
        widget.state.lifestyle.add(v);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¿Qué hay con tu estilo de vida?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Selecciona todas las que correspondan', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((o) {
              final selected = widget.state.lifestyle.contains(o);
              return ChoiceChip(
                label: Text(o, style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.white : Colors.black)),
                selected: selected,
                onSelected: (_) => _toggle(o),
                selectedColor: const Color(0xFF4CAF50),
                backgroundColor: Colors.white,
                shape: StadiumBorder(side: BorderSide(color: Colors.black87, width: 1)),
              );
            }).toList(),
          ),
          const Spacer(),
          _NextButton(
            enabled: _canContinue,
            label: 'Continuar',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PetFormCoCareScreen(state: widget.state)));
            },
          ),
        ]),
      ),
    );
  }
}

// 8. ¿Cuidas con alguien?
class PetFormCoCareScreen extends StatelessWidget {
  final PetFormState state;
  const PetFormCoCareScreen({Key? key, required this.state}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¿Cuidas a tu perro junto con alguien?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: _OutlinedSegmentButton(
                label: 'Sí',
                onTap: () {
                  state.coCare = true;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PetFormLoadingScreen()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OutlinedSegmentButton(
                label: 'No',
                onTap: () {
                  state.coCare = false;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PetFormLoadingScreen()));
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// 9. Loading
class PetFormLoadingScreen extends StatefulWidget {
  const PetFormLoadingScreen({Key? key}) : super(key: key);
  @override
  State<PetFormLoadingScreen> createState() => _PetFormLoadingScreenState();
}

class _PetFormLoadingScreenState extends State<PetFormLoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              height: 140,
              child: Image(image: AssetImage('assets/images/perro_logo.png')),
            ),
            SizedBox(height: 12),
            Text('Cargando tus datos\ningresados...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

// RUTA SECUNDARIA (abajo): nombre y rol
class PetAltNameScreen extends StatefulWidget {
  final PetFormState state;
  const PetAltNameScreen({Key? key, required this.state}) : super(key: key);
  @override
  State<PetAltNameScreen> createState() => _PetAltNameScreenState();
}

class _PetAltNameScreenState extends State<PetAltNameScreen> {
  final TextEditingController _ctrl = TextEditingController();
  bool get _valid => _ctrl.text.trim().isNotEmpty;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¿Cómo se llama tu\nperro?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
            ),
            child: TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Escribe el nombre',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
          _NextButton(
            enabled: _valid,
            label: 'Siguiente',
            onTap: () {
              widget.state.name = _ctrl.text.trim();
              Navigator.push(context, MaterialPageRoute(builder: (_) => PetRoleScreen(state: widget.state)));
            },
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('No lo he elegido todavía', style: TextStyle(color: Colors.black54)),
          ),
        ]),
      ),
    );
  }
}

class PetRoleScreen extends StatelessWidget {
  final PetFormState state;
  const PetRoleScreen({Key? key, required this.state}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¿Eres del perro..?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: _FullWidthGreenButton(
                label: 'Dueño',
                onTap: () {
                  state.role = 'Dueño';
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PetFormLoadingScreen()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FullWidthGreenButton(
                label: 'Cuidador',
                onTap: () {
                  state.role = 'Cuidador';
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PetFormLoadingScreen()));
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// Widgets base
class _FullWidthGreenButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FullWidthGreenButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 1,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool enabled;
  final String label;
  final VoidCallback onTap;
  const _NextButton({required this.enabled, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          foregroundColor: enabled ? Colors.white : Colors.black54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: enabled ? 1 : 0,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _OutlinedSegmentButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlinedSegmentButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black87, width: 1.2),
        shape: const StadiumBorder(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _PillSelector<T> extends StatelessWidget {
  final List<T> items;
  final T value;
  final String Function(T) labelBuilder;
  final void Function(T) onChanged;
  final double width;
  const _PillSelector({
    Key? key,
    required this.items,
    required this.value,
    required this.labelBuilder,
    required this.onChanged,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.expand_more, color: Colors.black),
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(labelBuilder(e), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
