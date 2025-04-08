import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
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


class FeedPageApp extends StatefulWidget {
  const FeedPageApp({super.key});

  @override
  State<FeedPageApp> createState() => _FeedPageAppState();
}

class _FeedPageAppState extends State<FeedPageApp> {
  List<dynamic> articles = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchRecommendedArticles();
  }

  Future<void> fetchRecommendedArticles() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');

    if (token == null || userId == null) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      return;
    }

    final interestResponse = await http.get(
      //change ip address
      Uri.parse("http://172.20.10.4:5001/api/auth/get-interests/$userId"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (interestResponse.statusCode != 200) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      return;
    }

    final interestsData = json.decode(interestResponse.body);
    List<String> categories = List<String>.from(interestsData["interests"]["categories"] ?? []);

    if (categories.isEmpty) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      return;
    }

    final flaskResponse = await http.post(
      //change ip address
      Uri.parse("http://172.20.10.4:5001/recommend/categories"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'topics': categories}),
    );

    if (flaskResponse.statusCode == 200) {
      final recommended = json.decode(flaskResponse.body);
      setState(() {
        articles = recommended;
        isLoading = false;
        hasError = false;
      });
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  String formatCategories(String rawCategories) {
    return rawCategories
        .split(' ')
        .map((cat) => readableCategoryNames[cat.trim()] ?? cat.trim())
        .join('  ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recommended Articles",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : fetchRecommendedArticles,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchRecommendedArticles,
                child: isLoading
                    ? Center(
                        child: Lottie.asset(
                          'assets/animations/loading.json',
                          height: 200,
                        ),
                      )
                    : hasError || articles.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 100),
                              Lottie.asset('assets/animations/inspect.json', height: 150),
                              const SizedBox(height: 10),
                              const Center(
                                child: Text(
                                  "No recommendations available at the moment.",
                                  style: TextStyle(fontSize: 16, color: Colors.black54),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              final article = articles[index];
                              final String title = article["title"] ?? "No Title";
                              final String categories = article["categories"] ?? "No Category";
                              final String link = article["link"] ?? "";

                              return GestureDetector(
                                onTap: () async {
                                  if (await canLaunchUrl(Uri.parse(link))) {
                                    await launchUrl(Uri.parse(link));
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Text(
                                      title.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Text(
                                      formatCategories(categories),
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}