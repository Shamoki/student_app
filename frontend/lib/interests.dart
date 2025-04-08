import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const Map<String, String> readableCategoryNames = {
  "astro-ph": "Astrophysics",
  "astro-ph.CO": "Astrophysics - Cosmology",
  "astro-ph.EP": "Astrophysics - Earth and Planetary Astrophysics",
  "astro-ph.GA": "Astrophysics - Galaxy Astrophysics",
  "astro-ph.HE": "Astrophysics - High Energy Astrophysical Phenomena",
  "astro-ph.IM": "Astrophysics - Instrumentation and Methods",
  "astro-ph.SR": "Astrophysics - Solar and Stellar Astrophysics",
  "chao-dyn": "Chaotic Dynamics",
  "cond-mat": "Condensed Matter",
  "cond-mat.dis-nn": "Disordered Systems and Neural Networks",
  "cond-mat.mes-hall": "Mesoscopic Systems and Quantum Hall Effect",
  "cond-mat.mtrl-sci": "Materials Science",
  "cond-mat.other": "Other Condensed Matter",
  "cond-mat.quant-gas": "Quantum Gases",
  "cond-mat.soft": "Soft Condensed Matter",
  "cond-mat.stat-mech": "Statistical Mechanics",
  "cond-mat.str-el": "Strongly Correlated Electrons",
  "cond-mat.supr-con": "Superconductivity",
  "cs": "Computer Science",
  "cs.AI": "Artificial Intelligence",
  "cs.AR": "Architecture",
  "cs.CC": "Computational Complexity",
  "cs.CE": "Computational Engineering",
  "cs.CG": "Computational Geometry",
  "cs.CL": "Computation and Language",
  "cs.CR": "Cryptography and Security",
  "cs.CV": "Computer Vision and Pattern Recognition",
  "cs.CY": "Computers and Society",
  "cs.DB": "Databases",
  "cs.DC": "Distributed, Parallel, and Cluster Computing",
  "cs.DL": "Digital Libraries",
  "cs.DM": "Discrete Mathematics",
  "cs.DS": "Data Structures and Algorithms",
  "cs.ET": "Emerging Technologies",
  "cs.FL": "Formal Languages and Automata Theory",
  "cs.GR": "Graphics",
  "cs.GT": "Computer Science and Game Theory",
  "cs.HC": "Human-Computer Interaction",
  "cs.IR": "Information Retrieval",
  "cs.IT": "Information Theory",
  "cs.LG": "Machine Learning",
  "cs.LO": "Logic in Computer Science",
  "cs.MA": "Multiagent Systems",
  "cs.MM": "Multimedia",
  "cs.MS": "Mathematical Software",
  "cs.NA": "Numerical Analysis",
  "cs.NE": "Neural and Evolutionary Computing",
  "cs.NI": "Networking and Internet Architecture",
  "cs.OH": "Other Computer Science",
  "cs.OS": "Operating Systems",
  "cs.PF": "Performance",
  "cs.PL": "Programming Languages",
  "cs.RO": "Robotics",
  "cs.SC": "Symbolic Computation",
  "cs.SD": "Sound",
  "cs.SE": "Software Engineering",
  "cs.SI": "Social and Information Networks",
  "cs.SY": "Systems and Control",
  "econ": "Economics",
  "econ.EM": "Econometrics",
  "econ.GN": "General Economics",
  "econ.TH": "Economic Theory",
  "eess": "Electrical Engineering and Systems Science",
  "eess.AS": "Audio and Speech Processing",
  "eess.IV": "Image and Video Processing",
  "eess.SP": "Signal Processing",
  "eess.SY": "Systems and Control",
  "gr-qc": "General Relativity and Quantum Cosmology",
  "hep-ex": "High Energy Physics - Experiment",
  "hep-lat": "High Energy Physics - Lattice",
  "hep-ph": "High Energy Physics - Phenomenology",
  "hep-th": "High Energy Physics - Theory",
  "math": "Mathematics",
  "math.AC": "Commutative Algebra",
  "math.AG": "Algebraic Geometry",
  "math.AP": "Analysis of PDEs",
  "math.AT": "Algebraic Topology",
  "math.CA": "Classical Analysis and ODEs",
  "math.CO": "Combinatorics",
  "math.CT": "Category Theory",
  "math.CV": "Complex Variables",
  "math.DG": "Differential Geometry",
  "math.DS": "Dynamical Systems",
  "math.FA": "Functional Analysis",
  "math.GM": "General Mathematics",
  "math.GN": "General Topology",
  "math.GR": "Group Theory",
  "math.GT": "Geometric Topology",
  "math.HO": "History and Overview",
  "math.IT": "Information Theory",
  "math.KT": "K-Theory and Homology",
  "math.LO": "Logic",
  "math.MG": "Metric Geometry",
  "math.MP": "Mathematical Physics",
  "math.NA": "Numerical Analysis",
  "math.NT": "Number Theory",
  "math.OA": "Operator Algebras",
  "math.OC": "Optimization and Control",
  "math.PR": "Probability",
  "math-ph": "Mathematics - Mathematical Physics",
  "math.QA": "Quantum Algebra",
  "math.RA": "Rings and Algebras",
  "math.RT": "Representation Theory",
  "math.SG": "Symplectic Geometry",
  "math.SP": "Spectral Theory",
  "math.ST": "Statistics Theory",
  "nlin": "Nonlinear Sciences",
  "nlin.AO": "Adaptation and Self-Organizing Systems",
  "nlin.CD": "Chaotic Dynamics",
  "nlin.CG": "Cellular Automata and Lattice Gases",
  "nlin.PS": "Pattern Formation and Solitons",
  "nlin.SI": "Exactly Solvable and Integrable Systems",
  "nucl-ex": "Nuclear Experiment",
  "nucl-th": "Nuclear Theory",
  "physics": "Physics",
  "physics.acc-ph": "Accelerator Physics",
  "physics.ao-ph": "Atmospheric and Oceanic Physics",
  "physics.app-ph": "Applied Physics",
  "physics.atm-clus": "Atomic and Molecular Clusters",
  "physics.atom-ph": "Atomic Physics",
  "physics.bio-ph": "Biological Physics",
  "physics.chem-ph": "Chemical Physics",
  "physics.class-ph": "Classical Physics",
  "physics.comp-ph": "Computational Physics",
  "physics.data-an": "Data Analysis, Statistics and Probability",
  "physics.ed-ph": "Physics Education",
  "physics.flu-dyn": "Fluid Dynamics",
  "physics.gen-ph": "General Physics",
  "physics.geo-ph": "Geophysics",
  "physics.hist-ph": "History of Physics",
  "physics.ins-det": "Instrumentation and Detectors",
  "physics.med-ph": "Medical Physics",
  "physics.optics": "Optics",
  "physics.plasm-ph": "Plasma Physics",
  "physics.pop-ph": "Popular Physics",
  "physics.soc-ph": "Physics and Society",
  "physics.space-ph": "Space Physics",
  "q-alg": "Quantum Algebra",
  "q-bio": "Quantitative Biology",
  "q-bio.BM": "Biomolecules",
  "q-bio.CB": "Cell Behavior",
  "q-bio.GN": "Genomics",
  "q-bio.MN": "Molecular Networks",
  "q-bio.NC": "Neurons and Cognition",
  "q-bio.OT": "Other Quantitative Biology",
  "q-bio.PE": "Populations and Evolution",
  "q-bio.QM": "Quantitative Methods",
  "q-bio.SC": "Subcellular Processes",
  "q-bio.TO": "Tissues and Organs",
  "q-fin": "Quantitative Finance",
  "q-fin.CP": "Computational Finance",
  "q-fin.EC": "Economics",
  "q-fin.GN": "General Finance",
  "q-fin.MF": "Mathematical Finance",
  "q-fin.PM": "Portfolio Management",
  "q-fin.PR": "Pricing of Securities",
  "q-fin.RM": "Risk Management",
  "q-fin.ST": "Statistical Finance",
  "q-fin.TR": "Trading and Market Microstructure",
  "quant-ph": "Quantum Physics",
  "solv-int": "Exactly Solvable and Integrable Systems",
  "stat": "Statistics",
  "stat.AP": "Applications",
  "stat.CO": "Computation",
  "stat.ME": "Methodology",
  "stat.ML": "Machine Learning",
  "stat.OT": "Other Statistics",
  "stat.TH": "Statistics Theory"
};

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  Map<String, List<String>> groupedCategories = {};
  List<String> selectedMainCategories = [];
  Map<String, List<String>> selectedSubcategories = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGroupedCategories();
  }

  Future<void> fetchGroupedCategories() async {
    try {
      //change ip address
      final response = await http.get(Uri.parse("http://172.20.10.4:5001/grouped-categories"));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          groupedCategories = Map<String, List<String>>.from(
            decoded.map((key, value) => MapEntry(key, List<String>.from(value))),
          );
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() => isLoading = false);
    }
  }

  void _toggleMainCategory(String category) {
    setState(() {
      if (selectedMainCategories.contains(category)) {
        selectedMainCategories.remove(category);
        selectedSubcategories.remove(category);
      } else {
        selectedMainCategories.add(category);
        selectedSubcategories[category] = [];
      }
    });
  }

  void _toggleSubcategory(String main, String sub) {
    if (!selectedMainCategories.contains(main)) return;
    setState(() {
      final subs = selectedSubcategories[main] ?? [];
      if (subs.contains(sub)) {
        subs.remove(sub);
      } else {
        subs.add(sub);
      }
      selectedSubcategories[main] = subs;
    });
  }

  Future<void> _saveInterests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');

    if (token == null || userId == null) return;

    final response = await http.put(
      //change ip address
      Uri.parse("http://172.20.10.4:5001/api/auth/set-interests"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "userId": userId,
        "categories": selectedMainCategories,
        "subcategories": selectedSubcategories,
      }),
    );

    if (response.statusCode == 200) {
      await prefs.setBool('interestsSet', true);
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Choose topics you love! This helps us personalize content for you.",
                    style: TextStyle(fontSize: 20, color: Colors.purple),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: groupedCategories.entries.map((entry) {
                        String main = entry.key;
                        List<String> subs = entry.value;
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ExpansionTile(
                            iconColor: Colors.purple,
                            title: Row(
                              children: [
                                Checkbox(
                                  value: selectedMainCategories.contains(main),
                                  onChanged: (_) => _toggleMainCategory(main),
                                  activeColor: Colors.purple,
                                ),
                                Expanded(
                                  child: Text(
                                    readableCategoryNames[main] ?? main,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            children: subs.map((sub) {
                              final isSelected = selectedSubcategories[main]?.contains(sub) ?? false;
                              final isEnabled = selectedMainCategories.contains(main);
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: ChoiceChip(
                                  label: Text(readableCategoryNames[sub] ?? sub),
                                  selected: isSelected,
                                  onSelected: isEnabled ? (_) => _toggleSubcategory(main, sub) : null,
                                  selectedColor: Colors.purple.withOpacity(0.2),
                                  backgroundColor: Colors.grey[200],
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.purple
                                        : isEnabled
                                            ? Colors.black
                                            : Colors.grey,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveInterests,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    ),
                    child: const Text("Save & Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}
