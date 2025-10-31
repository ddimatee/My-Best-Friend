import 'package:flutter/material.dart';
import 'estado.dart';
import 'paso_6_seguimiento.dart';

class MascotaPasoRazaPantalla extends StatefulWidget {
  final PetFormState estado;
  const MascotaPasoRazaPantalla({super.key, required this.estado});
  @override
  State<MascotaPasoRazaPantalla> createState() => _MascotaPasoRazaPantallaState();
}

class _MascotaPasoRazaPantallaState extends State<MascotaPasoRazaPantalla> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final filtradas = kRazas.where((b) => b.toLowerCase().contains(query.toLowerCase())).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Text('¿De qué raza es tu\nperro?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Selecciona o introduce la raza', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar raza...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black87)),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: filtradas.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black87),
              itemBuilder: (context, i) {
                final item = filtradas[i];
                return ListTile(
                  title: Text(item, style: const TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () {
                    widget.estado.breed = item;
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoSeguimientoPantalla(estado: widget.estado)));
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

const List<String> kRazas = [
  'Mestizo','Pastor Alemán','Labrador Retriever','Golden Retriever','Bulldog','Beagle','Poodle','Rottweiler','Yorkshire Terrier',
  'Boxer','Dachshund (Teckel)','Siberian Husky','Doberman','Shih Tzu','Border Collie','Chihuahua','Cocker Spaniel','Pug','French Bulldog',
  'Australian Shepherd','Bichón Frisé','Akita Inu','American Pitbull Terrier','Maltés','Boston Terrier','Jack Russell Terrier','Shar Pei',
  'Samoyedo','Weimaraner','Gran Danés','San Bernardo','Basset Hound','Husky Alaskano','Galgo','Setter Irlandés','Fox Terrier','Dálmata',
  'Staffordshire Bull Terrier','Cane Corso','Pinscher Miniatura','Lhasa Apso','Whippet','Caniche Toy','Pastor Belga','Pastor Australiano',
  'Airedale Terrier','Papillón','Cavalier King Charles Spaniel','Shiba Inu','Basenji','Bulldog Inglés','Bulldog Francés','Bóxer','Pointer',
  'Kerry Blue Terrier','Pomerania (Spitz)','Perro de Agua Español','Collie de Pelo Largo','Collie de Pelo Corto','Hovawart','Keeshond','Saluki',
  'Pekinés','Affenpinscher','Braco Alemán','Chesapeake Bay Retriever','Terranova','Pastor Holandés','Bobtail (Old English Sheepdog)',
  'Corgi Galés de Pembroke','Corgi Galés de Cardigan','Presa Canario','Podenco Ibicenco','Podenco Canario','Perro Sin Pelo del Perú',
  'Xoloitzcuintle','Galgo Español','Perro Lobo Checoslovaco','Cão de Água Português','Alaskan Malamute','Schipperke','Bull Terrier','Bullmastiff',
  'Leonberger','Borzoi','Norwegian Elkhound','Spitz Finlandés','Mastín Napolitano','Mastín Tibetano','Mastín Inglés','Pastor Caucásico',
  'Spaniel Tibetano','Spaniel Bretón','Gran Pirineo','Entlebucher Mountain Dog','Appenzeller','Boyero de Berna','Pinscher Alemán',
  'Grifón de Bruselas','Barbet','Spinone Italiano','Lagotto Romagnolo','Azawakh','Chow Chow','Kooikerhondje','Coton de Tuléar',
  'Perro Pastor de los Pirineos','Hokkaido','Kai','Kishu','Thai Ridgeback','Rhodesian Ridgeback','Pharaoh Hound','American Eskimo',
  'Bergamasco','Boerboel','Bluetick Coonhound','Treeing Walker Coonhound','Redbone Coonhound','English Springer Spaniel','Field Spaniel',
  'Clumber Spaniel','Sussex Spaniel','Irish Setter','Gordon Setter',
];
