import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ==========================================
// ⚠️ ISI URL GOOGLE SHEETS ANDA DI SINI ⚠️
// ==========================================
const String URL_GOOGLE_SHEETS = 'https://script.google.com/macros/s/AKfycbxw5_NBPfFfrIKA8rYty_Msy3t_qy9tJ4fXe2PIZ0dQxAg96bL0oZetkCrcyk_1jJDn9g/exec';

void main() {
  runApp(const AplikasiResto());
}

class AplikasiResto extends StatelessWidget {
  const AplikasiResto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jajanan Nusantara',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const HalamanLogin(),
    );
  }
}

// ==========================================
// HALAMAN 1: HALAMAN LOGIN
// ==========================================
class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key});

  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedPeran = 'Customer';
  bool _isLoading = false;
  
  // Map untuk menyimpan password di MEMORI APLIKASI saja (TIDAK ke Google Sheets)
  final Map<String, String> _dataPasswordCustomer = {};

  // Fungsi mencatat login ke Google Sheets (TANPA mengirim password)
  void _catatLoginCepat(String nama, String peran) {
    try {
      Map<String, dynamic> dataLogin = {
        "action": "login",
        "nama": nama,
        "peran": peran,
        "status": "Berhasil Login",
      };
      
      http.post(
        Uri.parse(URL_GOOGLE_SHEETS), 
        body: jsonEncode(dataLogin),
        headers: {'Content-Type': 'text/plain'},
      );
      
      print('🔵 Background: Mencatat login $nama - $peran');
    } catch (e) {
      print('🔴 Background Error: $e');
    }
  }

  void _prosesLogin() async {
    String nama = _namaController.text.trim();
    String password = _passwordController.text.trim();
    
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silahkan masukkan nama Anda!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedPeran == 'Admin' 
              ? 'Silahkan masukkan PIN Admin Anda!' 
              : 'Silahkan masukkan Password Anda!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_selectedPeran == 'Admin') {
        if (password == '1234') {
          _catatLoginCepat(nama, 'Admin');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selamat datang, Admin $nama!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HalamanDashboardOwner(
                  namaAdmin: nama,
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN Salah! akses ditolak'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // LOGIKA PASSWORD CUSTOMER (HANYA DI MEMORI APLIKASI)
        bool isFirstTime = !_dataPasswordCustomer.containsKey(nama);
        
        if (isFirstTime) {
          // Jika pertama kali (belum pernah login di sesi ini), password apapun akan diterima dan disimpan di memori
          _dataPasswordCustomer[nama] = password;
          _catatLoginCepat(nama, _selectedPeran);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selamat datang, $nama! (Password tersimpan di sesi ini)'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HalamanBeranda(
                  namaUser: nama,
                  peranUser: 'Customer',
                ),
              ),
            );
          }
        } else {
          // Jika sudah pernah login di sesi ini, cek password yang tersimpan di memori
          String storedPass = _dataPasswordCustomer[nama] ?? '';
          if (password == storedPass) {
            _catatLoginCepat(nama, _selectedPeran);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selamat datang kembali, $nama!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HalamanBeranda(
                    namaUser: nama,
                    peranUser: 'Customer',
                  ),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password salah! Silakan coba lagi.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://akcdn.detik.net.id/community/media/visual/2022/09/15/toko-kue-jajanan-pasar-4_43.jpeg?w=700&q=90',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.restaurant_menu,
                            size: 50,
                            color: Colors.red[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedPeran == 'Admin' ? 'Jajanan Nusantara (Admin)' : 'Jajanan Nusantara',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedPeran == 'Admin' ? 'Akses dashboard manajemen resto' : 'Silakan masuk untuk memesan menu',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Divider(height: 40, thickness: 1),
                        
                        TextField(
                          controller: _namaController,
                          decoration: InputDecoration(
                            labelText: _selectedPeran == 'Admin' ? 'Nama Admin' : 'Nama Anda',
                            hintText: _selectedPeran == 'Admin' ? 'Masukkan nama admin' : 'Masukkan nama Anda',
                            prefixIcon: const Icon(Icons.person, color: Colors.red),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red[800]!, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: _selectedPeran == 'Admin' ? 'PIN Admin' : 'Password',
                            hintText: _selectedPeran == 'Admin' ? 'Masukkan 4 digit PIN' : 'Password (bebas untuk sesi baru)',
                            prefixIcon: Icon(_selectedPeran == 'Admin' ? Icons.key : Icons.lock, color: Colors.red),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red[800]!, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          style: const TextStyle(fontSize: 16),
                          keyboardType: _selectedPeran == 'Admin' ? TextInputType.number : TextInputType.text,
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[800],
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _prosesLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _selectedPeran == 'Admin' 
                                            ? Icons.admin_panel_settings 
                                            : Icons.login,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _selectedPeran == 'Admin' 
                                            ? 'MASUK SEBAGAI ADMIN' 
                                            : 'MASUK SEBAGAI CUSTOMER',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedPeran = _selectedPeran == 'Customer' ? 'Admin' : 'Customer';
                              _passwordController.clear();
                            });
                          },
                          icon: Icon(
                            _selectedPeran == 'Customer' 
                                ? Icons.admin_panel_settings_outlined 
                                : Icons.person_outline,
                            color: Colors.red[800],
                            size: 20,
                          ),
                          label: Text(
                            _selectedPeran == 'Customer' 
                                ? 'Masuk sebagai Admin' 
                                : 'Kembali ke Login Customer',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HALAMAN 2: HALAMAN BERANDA
// ==========================================
class HalamanBeranda extends StatefulWidget {
  final String namaUser;
  final String peranUser;

  const HalamanBeranda({
    super.key,
    required this.namaUser,
    required this.peranUser,
  });

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> {
  List<Map<String, dynamic>> itemKeranjang = [];
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> menuMakanan = [
    {'nama': 'Putu', 'harga': 'Rp 6.000', 'gambar': 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=500&q=80'},
    {'nama': 'onde-onde', 'harga': 'Rp 5.000', 'gambar': 'https://i.ytimg.com/vi/gwi3r9GbKME/maxresdefault.jpg'},
    {'nama': 'lemper', 'harga': 'Rp 5.000', 'gambar': 'https://tse4.mm.bing.net/th/id/OIP.WI2PlPf7-k95CwAIS2ISogHaGA?pid=Api&P=0&h=180'},
    {'nama': 'Serabi', 'harga': 'Rp 3.000', 'gambar': 'https://tse4.mm.bing.net/th/id/OIP.jWuyA3FH6sBEPWLPQ0qBXwHaJQ?pid=Api&P=0&h=180'},
    {'nama': 'Cucur', 'harga': 'Rp 2.000', 'gambar': 'https://i0.wp.com/resepkoki.id/wp-content/uploads/2016/03/Resep-Kue-Cucur.jpg?fit=500%2C575&ssl=1'},
    {'nama': 'Bakwan', 'harga': 'Rp 10.000', 'gambar': 'https://i.ytimg.com/vi/j9-PzDSmm8E/maxresdefault.jpg'},
    {'nama': 'Dadar Gulung', 'harga': 'Rp 4.000', 'gambar': 'https://i.ytimg.com/vi/yLw2WXNH3II/maxresdefault.jpg?sqp=-oaymwEmCIAKENAF8quKqQMa8AEB-AH-CYAC0AWKAgwIABABGHIgRihaMA8=&rs=AOn4CLCP5T6hFywOvyMYQ_gOz9cwDmsoGg'},
    {'nama': 'Risol', 'harga': 'Rp 2.000', 'gambar': 'https://i.ytimg.com/vi/MUgAaSvuBwM/maxresdefault.jpg'},
    {'nama': 'Cente Manis', 'harga': 'Rp 2.000', 'gambar': 'https://awsimages.detik.net.id/community/media/visual/2025/09/03/10-kue-tradisional-indonesia-ini-ternyata-punya-ciri-khas-warna-pink-hijau-1756891936245.jpeg?w=700&q=90'},
    {'nama': 'Wingko', 'harga': 'Rp 2.000', 'gambar': 'https://wiratech.co.id/wp-content/uploads/2023/12/Wingko-Babat.jpg'},
    {'nama': 'Getuk', 'harga': 'Rp 2.000', 'gambar': 'https://i.ytimg.com/vi/pmrqOvCzcCc/maxresdefault.jpg'},
    {'nama': 'Naga Sari', 'harga': 'Rp 3.000', 'gambar': 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=500&q=80'},
    {'nama': 'Kue Lumpur', 'harga': 'Rp 2.000', 'gambar': 'https://assets.pikiran-rakyat.com/crop/0x0:0x0/x/photo/2023/02/28/3885672748.png'},
    {'nama': 'Kue Talam', 'harga': 'Rp 2.000', 'gambar': 'https://i0.wp.com/resepkoki.id/wp-content/uploads/2018/07/Resep-Kue-Talam.jpg?fit=1300%2C1300&ssl=1'},
    {'nama': 'Gemblong', 'harga': 'Rp 2.000', 'gambar': 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=500&q=80'},
    {'nama': 'Panada', 'harga': 'Rp 2.000', 'gambar': 'https://i2.wp.com/3.bp.blogspot.com/-J8KoAGelhXo/T5TBxiqO7_I/AAAAAAAAADE/f2GVYM2EUjs/w1200-h630-p-k-no-nu/Kue+Panada+1.jpg'},
    {'nama': 'Kue Pancong', 'harga': 'Rp 1.000', 'gambar': 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=500&q=80'},
    {'nama': 'Kue Cubit', 'harga': 'Rp 3.000', 'gambar': 'https://lelogama.go-jek.com/cms_editor/2021/08/13/kue_cubit.jpeg'},
    {'nama': 'Kue Pukis', 'harga': 'Rp 2.000', 'gambar': 'https://tse3.mm.bing.net/th/id/OIP.LUwd7H3uPOR-C8vVQKKT-QHaE7?pid=Api&P=0&h=180'},
    {'nama': 'kue Sus', 'harga': 'Rp 2.000', 'gambar': 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=500&q=80'},
    {'nama': 'Lapis Legit', 'harga': 'Rp 3.000', 'gambar': 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=500&q=80'},
    {'nama': 'kue jadah', 'harga': 'Rp 1.000', 'gambar': 'https://tse1.mm.bing.net/th/id/OIP.Ne5lPmcuMRiPz6gRZvBVJwHaE7?pid=Api&P=0&h=180'},
    {'nama': 'Lupis', 'harga': 'Rp 3.000', 'gambar': 'https://media.istockphoto.com/id/1484480877/id/foto/lupis-dengan-brown-sugar-sauce-ala-indonesia-kue-lupis-adalah-ketan-manis-tradisional.jpg?s=170667a&w=0&k=20&c=jkIhT2pP4dksz8GUbs-DBZ5NpJSS5DnhKVZQNigynbg='},
    {'nama': 'Bugis Ketan', 'harga': 'Rp 1.000', 'gambar': 'https://i.ytimg.com/vi/fmLJqo4ibjo/maxresdefault.jpg'},
    {'nama': 'Wajik', 'harga': 'Rp 1.000', 'gambar': 'https://i.ytimg.com/vi/ACkzB27CmnU/maxresdefault.jpg'},
    {'nama': 'kue Mangkok', 'harga': 'Rp 2.000', 'gambar': 'https://tse3.mm.bing.net/th/id/OIP.4SYFOtG8yK3nnJ6zHoMUUgHaE8?pid=Api&P=0&h=180'},
    {'nama': 'kue Mata Roda', 'harga': 'Rp 1.000', 'gambar': 'https://tse2.mm.bing.net/th/id/OIP.faSy8nlcQ-hT4luClDeTtQHaI-?pid=Api&P=0&h=180'},
    {'nama': 'kue Puri Mandi', 'harga': 'Rp 2.000', 'gambar': 'https://static.vecteezy.com/system/resources/previews/061/755/100/non_2x/kue-putri-mandi-a-beautiful-and-delicious-traditional-indonesian-snack-on-banana-leaf-isolated-on-white-background-photo.jpg'},
    {'nama': 'kerak Telor', 'harga': 'Rp 10.000', 'gambar': 'https://tse4.mm.bing.net/th/id/OIP.F4-e2iNMi-BlSYxn8gKOewHaE8?pid=Api&P=0&h=180'},
    {'nama': 'kue Clorot', 'harga': 'Rp 5.000', 'gambar': 'https://media.istockphoto.com/id/1431155900/id/foto/clorot-celorot-cerorot-jelurut-atau-dumbeg-adalah-kue-tradisional-jawa-yang-terbuat-dari.jpg?s=170667a&w=0&k=20&c=8dYs2m-6ZL3psEnRs1CfL45EtbBCR2uUeIOgz2_PzfU='},
    {'nama': 'kue awuk awuk', 'harga': 'Rp 3.000', 'gambar': 'https://image.idntimes.com/post/20241105/1730766000113-050d7c823376e5868043b1f6ae8078e6-fca43d2829ed606cd9c7d1088b5ada8e.jpeg'},
  ];

  List<Map<String, dynamic>> menuTerfilter = [];
  List<Map<String, dynamic>> riwayatPesanan = [];

  final List<String> kategoriMenu = ['Semua', 'Populer', 'Favorit', 'Murah'];
  String selectedKategori = 'Semua';

  @override
  void initState() {
    super.initState();
    menuTerfilter = menuMakanan;
  }

  void filterMenu(String query) {
    setState(() {
      menuTerfilter = menuMakanan
          .where((menu) => menu['nama'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void tambahKeKeranjang(Map<String, dynamic> menu) {
    setState(() {
      int index = itemKeranjang.indexWhere((item) => item['nama'] == menu['nama']);
      if (index != -1) {
        itemKeranjang[index]['jumlah'] = (itemKeranjang[index]['jumlah'] as int) + 1;
      } else {
        int hargaMurni = int.parse(menu['harga'].replaceAll(RegExp(r'[^0-9]'), ''));
        itemKeranjang.add({
          'nama': menu['nama'],
          'hargaLayar': menu['harga'],
          'hargaInt': hargaMurni,
          'jumlah': 1,
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${menu['nama']} masuk ke keranjang!'),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  void pesanLagiDariRiwayat(List<Map<String, dynamic>> itemsRiwayat) {
    itemKeranjang.clear();
    
    for (var item in itemsRiwayat) {
      var menuAsli = menuMakanan.firstWhere(
        (menu) => menu['nama'].toString().toLowerCase() == item['nama'].toString().toLowerCase(),
        orElse: () => {'nama': item['nama'], 'harga': 'Rp 5.000'}
      );

      int hargaMurni = int.parse(menuAsli['harga'].replaceAll(RegExp(r'[^0-9]'), ''));
      
      itemKeranjang.add({
        'nama': item['nama'],
        'hargaLayar': menuAsli['harga'],
        'hargaInt': hargaMurni,
        'jumlah': item['jumlah'],
      });
    }

    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Item berhasil dimasukkan ke keranjang! Silakan pesan kembali.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void simpanKeRiwayat(Map<String, dynamic> pesanan) {
    setState(() {
      riwayatPesanan.add({
        'waktu': DateTime.now(),
        ...pesanan,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.restaurant_menu, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(
              'Jajanan Nusantara',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 180, 20, 20),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.namaUser,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HalamanRiwayat(
                    riwayat: riwayatPesanan,
                    onPesanLagi: pesanLagiDariRiwayat,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HalamanLogin()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 200, 30, 30),
                    Color.fromARGB(255, 150, 20, 20),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      'https://akcdn.detik.net.id/community/media/visual/2022/09/15/toko-kue-jajanan-pasar-4_43.jpeg?w=700&q=90',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
                          color: Colors.red[800],
                          child: const Center(
                            child: Icon(Icons.restaurant, size: 60, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🍜 Nikmati Jajanan',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Khas Nusantara Terbaik!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            Icon(Icons.star_half, size: 16, color: Colors.amber),
                            SizedBox(width: 8),
                            Text(
                              '4.5 (1.2k+ review)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => filterMenu(value),
                  decoration: InputDecoration(
                    hintText: '🔍 Cari jajanan favoritmu...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.red, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            filterMenu('');
                          },
                        )
                      : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🍽️ Menu Jajanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant, size: 14, color: Colors.red[700]),
                        const SizedBox(width: 4),
                        Text(
                          '${menuTerfilter.length} menu',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: kategoriMenu.length,
                  itemBuilder: (context, index) {
                    final kategori = kategoriMenu[index];
                    final isSelected = selectedKategori == kategori;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedKategori = kategori;
                          if (kategori == 'Semua') {
                            menuTerfilter = menuMakanan;
                          } else if (kategori == 'Murah') {
                            menuTerfilter = menuMakanan
                                .where((menu) => 
                                    int.parse(menu['harga'].replaceAll(RegExp(r'[^0-9]'), '')) <= 5000)
                                .toList();
                          } else {
                            menuTerfilter = menuMakanan.take(8).toList();
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red[700] : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.red[700]! : Colors.grey[300]!,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: Center(
                          child: Text(
                            kategori,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: menuTerfilter.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Menu tidak ditemukan :(',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba kata kunci lain',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: menuTerfilter.length,
                      itemBuilder: (context, index) {
                        final menu = menuTerfilter[index];
                        return _buildMenuItemCard(menu);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: itemKeranjang.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: const Color.fromARGB(255, 200, 30, 30),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                '${itemKeranjang.fold(0, (sum, item) => sum + (item['jumlah'] as int))} item',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              onPressed: () async {
                final hasil = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HalamanKeranjang(
                      isiKeranjang: itemKeranjang,
                      onSimpanRiwayat: simpanKeRiwayat,
                    ),
                  ),
                );
                if (hasil == true) setState(() => itemKeranjang.clear());
              },
            )
          : null,
    );
  }

  Widget _buildMenuItemCard(Map<String, dynamic> menu) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  menu['gambar'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'POPULER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => tambahKeKeranjang(menu),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[700],
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu['nama'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '4.5',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'terjual 120+',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      menu['harga'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        'Tersedia',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HALAMAN 3: HALAMAN KERANJANG
// ==========================================
class HalamanKeranjang extends StatefulWidget {
  final List<Map<String, dynamic>> isiKeranjang;
  final Function(Map<String, dynamic>) onSimpanRiwayat;

  const HalamanKeranjang({
    super.key, 
    required this.isiKeranjang,
    required this.onSimpanRiwayat,
  });

  @override
  State<HalamanKeranjang> createState() => _HalamanKeranjangState();
}

class _HalamanKeranjangState extends State<HalamanKeranjang> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _mejaController = TextEditingController();
  bool _isLoading = false;
  String _metodePembayaran = 'Cash'; 
  Map<String, dynamic>? _pesananTerakhir;
  late List<Map<String, dynamic>> _keranjangItems;

  @override
  void initState() {
    super.initState();
    _keranjangItems = List.from(widget.isiKeranjang);
  }

  Future<void> kirimPesananKeDatabase() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      const String urlGAS = URL_GOOGLE_SHEETS;
      
      print('🔵 ====== DEBUG KIRIM PESANAN ======');
      print('🔵 URL yang digunakan: $urlGAS');
      print('🔵 Nama: ${_namaController.text}');
      print('🔵 Meja: ${_mejaController.text}');
      print('🔵 Metode Pembayaran: $_metodePembayaran');
      
      try {
        String teksMenuGabungan = _keranjangItems.map((item) => "${item['jumlah']}x ${item['nama']}").join(", ");
        int totalHarga = _keranjangItems.fold(0, (sum, item) => sum + (item['hargaInt'] as int) * (item['jumlah'] as int));
        
        Map<String, dynamic> dataPesanan = {
          "waktu": DateTime.now().toIso8601String(),
          "nama": _namaController.text,
          "meja": _mejaController.text,
          "menu": teksMenuGabungan,
          "pembayaran": _metodePembayaran,
          "total": totalHarga,
          "items": _keranjangItems,
        };
        
        _pesananTerakhir = dataPesanan;
        
        print('🔵 Data yang dikirim: ${jsonEncode(dataPesanan)}');
        
        final response = await http.post(
          Uri.parse(urlGAS), 
          body: jsonEncode(dataPesanan),
          headers: {'Content-Type': 'text/plain'},
        );
        
        print('🟢 Response status: ${response.statusCode}');
        print('🟢 Response body: ${response.body}');
        
        if (response.statusCode == 200 || response.statusCode == 302) {
          if (mounted) {
            widget.onSimpanRiwayat(dataPesanan);
            _showSuccessWithStrukDialog();
          }
        } else {
          throw Exception('Gagal mengirim pesanan: ${response.statusCode} - ${response.body}');
        }
      } catch (error) {
        print('🔴 ERROR: $error');
        print('🔴 Stacktrace: ${StackTrace.current}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red)
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _hapusItem(int index) {
    setState(() {
      _keranjangItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item berhasil dihapus!'),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  void _kurangiJumlah(int index) {
    setState(() {
      if (_keranjangItems[index]['jumlah'] > 1) {
        _keranjangItems[index]['jumlah'] = (_keranjangItems[index]['jumlah'] as int) - 1;
      } else {
        _keranjangItems.removeAt(index);
      }
    });
  }

  void _tambahJumlah(int index) {
    setState(() {
      _keranjangItems[index]['jumlah'] = (_keranjangItems[index]['jumlah'] as int) + 1;
    });
  }

  void _kosongkanKeranjang() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Semua?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua item dari keranjang?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _keranjangItems.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Keranjang dikosongkan!'),
                  duration: const Duration(milliseconds: 800),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.red[700],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  void _showSuccessWithStrukDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Color.fromARGB(255, 118, 13, 13), size: 60),
        content: Text(
          _metodePembayaran == 'QRIS'
              ? 'Pesanan Berhasil!\nSilahkan lakukan scan QRIS di kasir.'
              : 'Pesanan Berhasil!\nSilahkan bayar dengan Cash di kasir.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.home),
                label: const Text('Beranda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HalamanStruk(
                        pesanan: _pesananTerakhir!,
                        metodePembayaran: _metodePembayaran,
                      ),
                    ),
                  ).then((_) {
                    Navigator.pop(context, true);
                  });
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('Lihat Struk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalHarga = _keranjangItems.fold(0, (sum, item) => sum + (item['hargaInt'] as int) * (item['jumlah'] as int));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detail Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 156, 22, 13),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (_keranjangItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _kosongkanKeranjang,
              tooltip: 'Kosongkan Keranjang',
            ),
        ],
      ),
      body: _keranjangItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Keranjang Kosong',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan menu favoritmu!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali ke Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shopping_cart_checkout, color: Color.fromARGB(255, 225, 110, 106)),
                          SizedBox(width: 8),
                          Text('Menu yang Dipesan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          '${_keranjangItems.length} item',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _keranjangItems.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _keranjangItems[index];
                        return Dismissible(
                          key: Key(item['nama'] + index.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          onDismissed: (direction) {
                            _hapusItem(index);
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange[100],
                              child: Text(
                                '${item['jumlah']}x',
                                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              item['nama'],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(item['hargaLayar']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () => _kurangiJumlah(index),
                                  iconSize: 24,
                                ),
                                Text(
                                  '${item['jumlah']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                  onPressed: () => _tambahJumlah(index),
                                  iconSize: 24,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _hapusItem(index),
                                  iconSize: 24,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Rp ${item['hargaInt'] * item['jumlah']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color.fromARGB(255, 202, 135, 135),
                          const Color.fromARGB(255, 180, 100, 100),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.payments, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Rp $totalHarga',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Row(
                    children: [
                      Icon(Icons.payment, color: Color.fromARGB(255, 200, 114, 114)),
                      SizedBox(width: 8),
                      Text('Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Cash (Tunai)'),
                          secondary: const Icon(Icons.money, color: Colors.green),
                          value: 'Cash',
                          groupValue: _metodePembayaran,
                          onChanged: (value) {
                            setState(() {
                              _metodePembayaran = value!;
                            });
                          },
                        ),
                        const Divider(height: 1),
                        RadioListTile<String>(
                          title: const Text('QRIS (E-Wallet)'),
                          secondary: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                          value: 'QRIS',
                          groupValue: _metodePembayaran,
                          onChanged: (value) {
                            setState(() {
                              _metodePembayaran = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  const Row(
                    children: [
                      Icon(Icons.assignment_ind, color: Color.fromARGB(255, 200, 114, 114)),
                      SizedBox(width: 8),
                      Text('Data Pemesan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _namaController,
                          decoration: InputDecoration(
                            labelText: 'Nama Anda',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _mejaController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Nomor Meja',
                            prefixIcon: const Icon(Icons.table_bar),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) => v!.isEmpty ? 'Meja wajib diisi' : null,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : kirimPesananKeDatabase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 127, 13, 13),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                            ),
                            icon: _isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.send),
                            label: Text(
                              _isLoading ? 'MENGIRIM...' : 'PESAN SEKARANG',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ==========================================
// HALAMAN STRUK PEMBELIAN
// ==========================================
class HalamanStruk extends StatelessWidget {
  final Map<String, dynamic> pesanan;
  final String metodePembayaran;

  const HalamanStruk({
    super.key,
    required this.pesanan,
    required this.metodePembayaran,
  });

  String _formatWaktu(DateTime waktu) {
    return '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')} - ${waktu.day.toString().padLeft(2, '0')}/${waktu.month.toString().padLeft(2, '0')}/${waktu.year}';
  }

  @override
  Widget build(BuildContext context) {
    final items = pesanan['items'] as List<Map<String, dynamic>>;
    final total = pesanan['total'] as int;
    final DateTime waktuOrder = pesanan['waktu'] is DateTime 
        ? (pesanan['waktu'] as DateTime).toLocal() 
        : (pesanan['waktu'] != null ? (DateTime.tryParse(pesanan['waktu'].toString())?.toLocal() ?? DateTime.now()) : DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Struk Pembelian', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              _cetakStrukPDF(context);
            },
            tooltip: 'Cetak PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.restaurant_menu, size: 50, color: Colors.red),
                  const SizedBox(height: 8),
                  const Text(
                    'Jajanan Nusantara',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Jl. Raya Nusantara No. 123',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Telp: 0812-3456-7890',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Divider(height: 20),
                  Text(
                    '========= STRUK PEMBELIAN =========',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Nama Pelanggan', pesanan['nama']),
                  _buildInfoRow('Nomor Meja', pesanan['meja']),
                  _buildInfoRow('Pembayaran', metodePembayaran),
                  _buildInfoRow(
                    'Waktu', 
                    _formatWaktu(waktuOrder),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Pesanan:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Divider(),
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item['jumlah']}x ${item['nama']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Rp ${(item['hargaInt'] as int) * (item['jumlah'] as int)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Rp $total',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Terima kasih telah berbelanja!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Silahkan tunjukkan struk ini ke kasir',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '====================================',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _cetakStrukPDF(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final DateTime waktuOrder = pesanan['waktu'] is DateTime 
          ? (pesanan['waktu'] as DateTime).toLocal() 
          : (pesanan['waktu'] != null ? (DateTime.tryParse(pesanan['waktu'].toString())?.toLocal() ?? DateTime.now()) : DateTime.now());

      final pdf = pw.Document();
      
      final items = pesanan['items'] as List<Map<String, dynamic>>;
      final total = pesanan['total'] as int;
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Container(
                padding: pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'JAJANAN NUSANTARA',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Jl. Raya Nusantara No. 123',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                    ),
                    pw.Text(
                      'Telp: 0812-3456-7890',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      '========= STRUK PEMBELIAN =========',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 20),
                    
                    pw.Container(
                      padding: pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Column(
                        children: [
                          _buildPdfInfoRow('Waktu', _formatWaktu(waktuOrder)),
                          _buildPdfInfoRow('Metode Pembayaran', metodePembayaran),
                        ],
                      ),
                    ),
                    
                    pw.SizedBox(height: 20),
                    
                    pw.Container(
                      padding: pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Detail Pesanan (Menu):',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                          ),
                          pw.SizedBox(height: 5),
                          ...items.map((item) => pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('${item['jumlah']}x ${item['nama']}'),
                              pw.Text('Rp ${(item['hargaInt'] as int) * (item['jumlah'] as int)}'),
                            ],
                          )),
                          pw.Divider(),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'TOTAL',
                                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(
                                'Rp $total',
                                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    pw.SizedBox(height: 20),
                    
                    pw.Text(
                      'Terima kasih telah berbelanja!',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Silahkan tunjukkan struk ini ke kasir',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      
      Navigator.pop(context);
      
      final bytes = await pdf.save();
      
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'struk_pembelian.pdf',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
        pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }
}

// ==========================================
// HALAMAN RIWAYAT PESANAN
// ==========================================
class HalamanRiwayat extends StatefulWidget {
  final List<Map<String, dynamic>> riwayat;
  final Function(List<Map<String, dynamic>>) onPesanLagi;

  const HalamanRiwayat({
    super.key, 
    required this.riwayat,
    required this.onPesanLagi,
  });

  @override
  State<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends State<HalamanRiwayat> {
  List<Map<String, dynamic>> _semuaRiwayat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<List<Map<String, dynamic>>> _ambilDataDariGoogleSheets() async {
    try {
      final String url = URL_GOOGLE_SHEETS;
      
      print('🔵 Mengambil riwayat dari: $url');
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🟢 Data riwayat: ${data.length} item');
        if (data is List) {
          List<Map<String, dynamic>> pesanan = [];
          
          for (var row in data) {
            if (row is List && row.length >= 6) {
              try {
                String waktuString = row[0].toString().trim();
                DateTime waktu;
                try {
                  List<String> parts = waktuString.split(' ');
                  List<String> dateParts = parts[0].split('/');
                  List<String> timeParts = parts[1].split(':');
                  waktu = DateTime(
                    int.parse(dateParts[2]), // tahun
                    int.parse(dateParts[1]), // bulan
                    int.parse(dateParts[0]), // tanggal
                    int.parse(timeParts[0]), // jam
                    int.parse(timeParts[1]), // menit
                    int.parse(timeParts[2]), // detik
                  );
                } catch (e) {
                  waktu = DateTime.parse(waktuString).toLocal();
                }

                String nama = row[1].toString();
                String meja = row[2].toString();
                String menu = row[3].toString();
                int total = int.tryParse(row[4].toString()) ?? 0;
                String pembayaran = row[5].toString();
                
                List<Map<String, dynamic>> items = [];
                RegExp regExp = RegExp(r'(\d+)x\s+([^,]+)');
                Iterable<Match> matches = regExp.allMatches(menu);
                
                Map<String, int> daftarHarga = {
                  'Putu': 6000, 'onde-onde': 5000, 'lemper': 5000,
                  'Serabi': 3000, 'Cucur': 2000, 'Bakwan': 10000,
                  'Dadar Gulung': 4000, 'Risol': 2000, 'Cente Manis': 2000,
                  'Wingko': 2000, 'Getuk': 2000, 'Naga Sari': 3000,
                  'Kue Lumpur': 2000, 'Kue Talam': 2000, 'Gemblong': 2000,
                  'Panada': 2000, 'Kue Pancong': 1000, 'Kue Cubit': 3000,
                  'Kue Pukis': 2000, 'kue Sus': 2000, 'Lapis Legit': 3000,
                  'kue jadah': 1000, 'Lupis': 3000, 'Bugis Ketan': 1000,
                  'Wajik': 1000, 'kue Mangkok': 2000, 'kue Mata Roda': 1000,
                  'kue Puri Mandi': 2000, 'kerak Telor': 10000, 'kue Clorot': 5000,
                  'kue awuk awuk': 3000,
                };
                
                for (var match in matches) {
                  int jumlah = int.parse(match.group(1)!);
                  String namaMenu = match.group(2)!.trim();
                  int harga = daftarHarga[namaMenu] ?? 5000;
                  items.add({
                    'nama': namaMenu,
                    'jumlah': jumlah,
                    'hargaInt': harga,
                  });
                }
                
                pesanan.add({
                  'waktu': waktu,
                  'nama': nama,
                  'meja': meja,
                  'menu': menu,
                  'total': total,
                  'items': items,
                  'pembayaran': pembayaran,
                  'dariGoogleSheets': true,
                });
              } catch (e) {
                continue;
              }
            }
          }
          
          pesanan.sort((a, b) => b['waktu'].compareTo(a['waktu']));
          return pesanan;
        }
      }
      return [];
    } catch (e) {
      print('🔴 Error ambil riwayat: $e');
      return [];
    }
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final dataSheets = await _ambilDataDariGoogleSheets();
      
      List<Map<String, dynamic>> semua = [];
      
      for (var item in widget.riwayat) {
        var newItem = Map<String, dynamic>.from(item);
        newItem['dariGoogleSheets'] = false;
        semua.add(newItem);
      }
      
      semua.addAll(dataSheets);
      
      semua.sort((a, b) {
        DateTime waktuA = a['waktu'] is DateTime ? (a['waktu'] as DateTime).toLocal() : DateTime.parse(a['waktu'].toString()).toLocal();
        DateTime waktuB = b['waktu'] is DateTime ? (b['waktu'] as DateTime).toLocal() : DateTime.parse(b['waktu'].toString()).toLocal();
        return waktuB.compareTo(waktuA);
      });
      
      setState(() {
        _semuaRiwayat = semua;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _semuaRiwayat = List.from(widget.riwayat);
        _isLoading = false;
      });
    }
  }

  String _formatWaktu(DateTime waktu) {
    return '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')} - ${waktu.day.toString().padLeft(2, '0')}/${waktu.month.toString().padLeft(2, '0')}/${waktu.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Riwayat Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Mengambil data riwayat...'),
                ],
              ),
            )
          : _semuaRiwayat.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada riwayat pesanan',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pesanan dari semua pelanggan akan muncul di sini',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _semuaRiwayat.length,
                  itemBuilder: (context, index) {
                    final pesanan = _semuaRiwayat[index];
                    final items = pesanan['items'] as List<Map<String, dynamic>>? ?? [];
                    final waktu = pesanan['waktu'] is DateTime 
                        ? (pesanan['waktu'] as DateTime).toLocal() 
                        : DateTime.parse(pesanan['waktu'].toString()).toLocal();
                    final dariGoogle = pesanan['dariGoogleSheets'] ?? false;
                    
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      dariGoogle ? Icons.cloud_done : Icons.receipt,
                                      color: dariGoogle ? Colors.blue : Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pesanan #${_semuaRiwayat.length - index}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (dariGoogle)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Cloud',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Selesai',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  pesanan['nama'],
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.table_bar, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('Meja ${pesanan['meja']}'),
                                const SizedBox(width: 12),
                                const Icon(Icons.payment, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(pesanan['pembayaran'] ?? 'Cash'),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              _formatWaktu(waktu),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            
                            const Divider(),
                            
                            ...(items.isNotEmpty ? items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item['jumlah']}x ${item['nama']}'),
                                  Text('Rp ${(item['hargaInt'] as int) * (item['jumlah'] as int)}'),
                                ],
                              ),
                            )) : [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  pesanan['menu'] ?? 'Menu tidak tersedia',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                ),
                              )
                            ]),
                            
                            const Divider(),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Rp ${pesanan['total']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      widget.onPesanLagi(items);
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.repeat, size: 16),
                                    label: const Text('Pesan Lagi'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange[700],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Map<String, dynamic> dataStruk = {
                                        'waktu': pesanan['waktu'],
                                        'nama': pesanan['nama'],
                                        'meja': pesanan['meja'],
                                        'total': pesanan['total'],
                                        'items': items.isNotEmpty ? items : [],
                                        'menu': pesanan['menu'] ?? '',
                                      };
                                      
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HalamanStruk(
                                            pesanan: dataStruk,
                                            metodePembayaran: pesanan['pembayaran'] ?? 'Cash',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.receipt_long, size: 16),
                                    label: const Text('Lihat Struk'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red[800],
                                      side: BorderSide(color: Colors.red[800]!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ==========================================
// HALAMAN DASHBOARD OWNER
// ==========================================
class HalamanDashboardOwner extends StatefulWidget {
  final String namaAdmin;

  const HalamanDashboardOwner({
    super.key,
    required this.namaAdmin,
  });

  @override
  State<HalamanDashboardOwner> createState() => _HalamanDashboardOwnerState();
}

class _HalamanDashboardOwnerState extends State<HalamanDashboardOwner> {
  Map<String, dynamic> _dataHarian = {'omset': 'Loading...', 'transaksi': 'Loading...'};
  Map<String, dynamic> _dataMingguan = {'omset': 'Loading...', 'transaksi': 'Loading...'};
  Map<String, dynamic> _dataBulanan = {'omset': 'Loading...', 'transaksi': 'Loading...'};
  Map<String, dynamic> _dataTahunan = {'omset': 'Loading...', 'transaksi': 'Loading...'};
  List<Map<String, dynamic>> _dataLogin = [];
  bool _isLoading = true;
  bool _isLoadingLogin = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _loadLoginData();
  }

  Future<void> _loadLoginData() async {
    setState(() => _isLoadingLogin = true);
    try {
      final data = await _ambilDataLoginDariGoogleSheets();
      setState(() {
        _dataLogin = data;
        _isLoadingLogin = false;
      });
    } catch (e) {
      setState(() => _isLoadingLogin = false);
    }
  }

  Future<List<Map<String, dynamic>>> _ambilDataLoginDariGoogleSheets() async {
    try {
      final String url = '$URL_GOOGLE_SHEETS?action=getLogin';
      
      print('🔵 Mengambil data login dari: $url');
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🟢 Data login: ${data.length} item');
        if (data is List) {
          List<Map<String, dynamic>> loginData = [];
          for (var row in data) {
            if (row is List && row.length >= 4) {
              String waktuString = row[0].toString().trim();
              DateTime waktu;
              try {
                List<String> parts = waktuString.split(' ');
                List<String> dateParts = parts[0].split('/');
                List<String> timeParts = parts[1].split(':');
                waktu = DateTime(
                  int.parse(dateParts[2]), // tahun
                  int.parse(dateParts[1]), // bulan
                  int.parse(dateParts[0]), // tanggal
                  int.parse(timeParts[0]), // jam
                  int.parse(timeParts[1]), // menit
                  int.parse(timeParts[2]), // detik
                );
              } catch (e) {
                waktu = DateTime.parse(waktuString).toLocal();
              }

              loginData.add({
                'waktu': waktu,
                'nama': row[1].toString(),
                'peran': row[2].toString(),
                'status': row[3].toString(),
              });
            }
          }
          loginData.sort((a, b) => b['waktu'].compareTo(a['waktu']));
          return loginData;
        }
      }
      return [];
    } catch (e) {
      print('🔴 Error ambil login: $e');
      return [];
    }
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final harian = await _hitungLaporanPerPeriode('harian');
      final mingguan = await _hitungLaporanPerPeriode('mingguan');
      final bulanan = await _hitungLaporanPerPeriode('bulanan');
      final tahunan = await _hitungLaporanPerPeriode('tahunan');
      
      setState(() {
        _dataHarian = harian;
        _dataMingguan = mingguan;
        _dataBulanan = bulanan;
        _dataTahunan = tahunan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<List<List<dynamic>>> _ambilDataDariGoogleSheets() async {
    try {
      final String url = URL_GOOGLE_SHEETS;
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<List<dynamic>>();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  int _cariHargaMenu(String namaMenu) {
    final Map<String, int> daftarHarga = {
      'Putu': 6000, 'onde-onde': 5000, 'lemper': 5000,
      'Serabi': 3000, 'Cucur': 2000, 'Bakwan': 10000,
      'Dadar Gulung': 4000, 'Risol': 2000, 'Cente Manis': 2000,
      'Wingko': 2000, 'Getuk': 2000, 'Naga Sari': 3000,
      'Kue Lumpur': 2000, 'Kue Talam': 2000, 'Gemblong': 2000,
      'Panada': 2000, 'Kue Pancong': 1000, 'Kue Cubit': 3000,
      'Kue Pukis': 2000, 'kue Sus': 2000, 'Lapis Legit': 3000,
      'kue jadah': 1000, 'Lupis': 3000, 'Bugis Ketan': 1000,
      'Wajik': 1000, 'kue Mangkok': 2000, 'kue Mata Roda': 1000,
      'kue Puri Mandi': 2000, 'kerak Telor': 10000, 'kue Clorot': 5000,
      'kue awuk awuk': 3000,
    };
    return daftarHarga[namaMenu] ?? 5000;
  }

  Future<Map<String, dynamic>> _hitungLaporanPerPeriode(String periode) async {
    try {
      final data = await _ambilDataDariGoogleSheets();
      final dataPesanan = data.skip(1).toList();
      
      if (dataPesanan.isEmpty) {
        return {'omset': 'Rp 0', 'transaksi': '0 Transaksi', 'detail': []};
      }
      
      List<Map<String, dynamic>> pesanan = [];
      for (var row in dataPesanan) {
        if (row.length >= 6) {
          try {
            String waktuString = row[0].toString().trim();
            DateTime waktu;
            try {
              List<String> parts = waktuString.split(' ');
              List<String> dateParts = parts[0].split('/');
              List<String> timeParts = parts[1].split(':');
              waktu = DateTime(
                int.parse(dateParts[2]), // tahun
                int.parse(dateParts[1]), // bulan
                int.parse(dateParts[0]), // tanggal
                int.parse(timeParts[0]), // jam
                int.parse(timeParts[1]), // menit
                int.parse(timeParts[2]), // detik
              );
            } catch (e) {
              waktu = DateTime.parse(waktuString).toLocal();
            }

            String menu = row[3].toString();
            
            int totalHarga = 0;
            if (menu.isNotEmpty) {
              RegExp regExp = RegExp(r'(\d+)x\s+([^,]+)');
              Iterable<Match> matches = regExp.allMatches(menu);
              for (var match in matches) {
                int jumlah = int.parse(match.group(1)!);
                String namaMenu = match.group(2)!.trim();
                int harga = _cariHargaMenu(namaMenu);
                totalHarga += jumlah * harga;
              }
            }
            
            pesanan.add({
              'waktu': waktu,
              'nama': row[1].toString(),
              'meja': row[2].toString(),
              'menu': menu,
              'total': totalHarga,
              'pembayaran': row.length >= 6 ? row[5].toString() : 'Cash',
            });
          } catch (e) {
            continue;
          }
        }
      }
      
      DateTime now = DateTime.now();
      List<Map<String, dynamic>> filteredPesanan = [];
      
      if (periode == 'harian') {
        DateTime startOfDay = DateTime(now.year, now.month, now.day);
        filteredPesanan = pesanan.where((p) => p['waktu'].isAfter(startOfDay) || p['waktu'].isAtSameMomentAs(startOfDay)).toList();
      } else if (periode == 'mingguan') {
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        filteredPesanan = pesanan.where((p) => p['waktu'].isAfter(startOfWeek)).toList();
      } else if (periode == 'bulanan') {
        filteredPesanan = pesanan.where((p) => 
          p['waktu'].year == now.year && p['waktu'].month == now.month
        ).toList();
      } else if (periode == 'tahunan') {
        filteredPesanan = pesanan.where((p) => p['waktu'].year == now.year).toList();
      } else {
        filteredPesanan = pesanan;
      }
      
      int totalOmset = filteredPesanan.fold(0, (sum, p) => sum + (p['total'] as int));
      int totalTransaksi = filteredPesanan.length;
      
      String formattedOmset = 'Rp ${totalOmset.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
      String formattedTransaksi = '$totalTransaksi Transaksi';
      
      return {
        'omset': formattedOmset,
        'transaksi': formattedTransaksi,
        'detail': filteredPesanan,
      };
      
    } catch (e) {
      return {'omset': 'Rp 0', 'transaksi': '0 Transaksi', 'detail': []};
    }
  }

  Future<void> _cetakLaporanPerPeriodePDF(
    BuildContext context,
    String judul,
    String periode,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final data = await _hitungLaporanPerPeriode(periode);
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            final List<Map<String, dynamic>> details = List<Map<String, dynamic>>.from(data['detail'] ?? []);
            
            return [
              pw.Center(
                child: pw.Text(
                  'JAJANAN NUSANTARA',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'LAPORAN KEUANGAN TOKO',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  judul,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Tanggal Cetak: ${DateTime.now().toString().substring(0, 16).replaceAll('T', ' ')}',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 20),
              
              pw.Container(
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RINGKASAN:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Omset'),
                        pw.Text(data['omset'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Transaksi'),
                        pw.Text(data['transaksi'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'DETAIL TRANSAKSI:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
              ),
              pw.SizedBox(height: 10),
              
              details.isEmpty
                  ? pw.Text('Tidak ada detail transaksi untuk periode ini.')
                  : pw.Table.fromTextArray(
                      context: context,
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      headerDecoration: pw.BoxDecoration(color: PdfColors.grey100),
                      headerHeight: 25,
                      cellHeight: 25,
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                      cellStyle: const pw.TextStyle(fontSize: 9),
                      headers: ['No', 'Waktu', 'Pesanan', 'Total', 'Metode Pembayaran'],
                      data: List<List<String>>.generate(
                        details.length,
                        (index) {
                          final item = details[index];
                          final waktu = item['waktu'] is DateTime 
                              ? (item['waktu'] as DateTime).toLocal() 
                              : DateTime.parse(item['waktu'].toString()).toLocal();
                          final formattedWaktu = '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')} - ${waktu.day.toString().padLeft(2, '0')}/${waktu.month.toString().padLeft(2, '0')}/${waktu.year}';
                          final totalHarga = 'Rp ${item['total'].toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}';
                          final pembayaran = item['pembayaran']?.toString() ?? 'Cash';
                          return [
                            '${index + 1}',
                            formattedWaktu,
                            '${item['menu']}',
                            totalHarga,
                            pembayaran,
                          ];
                        },
                      ),
                    ),
            ];
          },
        ),
      );
      
      Navigator.pop(context);
      
      final bytes = await pdf.save();
      
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'laporan_${judul.toLowerCase().replaceAll(' ', '_')}.pdf',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan $judul berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cetakSemuaLaporanPDF(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final dataMingguan = await _hitungLaporanPerPeriode('mingguan');
      final dataBulanan = await _hitungLaporanPerPeriode('bulanan');
      final dataTahunan = await _hitungLaporanPerPeriode('tahunan');
      final dataKeseluruhan = await _hitungLaporanPerPeriode('semua');
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            final List<Map<String, dynamic>> details = List<Map<String, dynamic>>.from(dataKeseluruhan['detail'] ?? []);
            
            return [
              pw.Center(
                child: pw.Text(
                  'JAJANAN NUSANTARA',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'LAPORAN KEUANGAN LENGKAP',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Tanggal Cetak: ${DateTime.now().toString().substring(0, 16).replaceAll('T', ' ')}',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 20),
              
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                margin: pw.EdgeInsets.only(bottom: 10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '--- LAPORAN MINGGUAN ---',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Omset:'),
                        pw.Text(dataMingguan['omset'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Transaksi:'),
                        pw.Text(dataMingguan['transaksi'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                margin: pw.EdgeInsets.only(bottom: 10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '--- LAPORAN BULANAN ---',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Omset:'),
                        pw.Text(dataBulanan['omset'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Transaksi:'),
                        pw.Text(dataBulanan['transaksi'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                margin: pw.EdgeInsets.only(bottom: 10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '--- LAPORAN TAHUNAN ---',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Omset:'),
                        pw.Text(dataTahunan['omset'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Transaksi:'),
                        pw.Text(dataTahunan['transaksi'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.Divider(),
              
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RINGKASAN TOTAL KESELURUHAN:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Omset Keseluruhan:'),
                        pw.Text(dataKeseluruhan['omset'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Transaksi:'),
                        pw.Text(dataKeseluruhan['transaksi'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'DETAIL SEMUA TRANSAKSI PESANAN:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
              ),
              pw.SizedBox(height: 10),
              
              details.isEmpty
                  ? pw.Text('Tidak ada detail transaksi.')
                  : pw.Table.fromTextArray(
                      context: context,
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      headerDecoration: pw.BoxDecoration(color: PdfColors.grey100),
                      headerHeight: 25,
                      cellHeight: 25,
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                      cellStyle: const pw.TextStyle(fontSize: 9),
                      headers: ['No', 'Waktu', 'Pesanan', 'Total', 'Metode Pembayaran'],
                      data: List<List<String>>.generate(
                        details.length,
                        (index) {
                          final item = details[index];
                          final waktu = item['waktu'] is DateTime 
                              ? (item['waktu'] as DateTime).toLocal() 
                              : DateTime.parse(item['waktu'].toString()).toLocal();
                          final formattedWaktu = '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')} - ${waktu.day.toString().padLeft(2, '0')}/${waktu.month.toString().padLeft(2, '0')}/${waktu.year}';
                          final totalHarga = 'Rp ${item['total'].toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}';
                          final pembayaran = item['pembayaran']?.toString() ?? 'Cash';
                          return [
                            '${index + 1}',
                            formattedWaktu,
                            '${item['menu']}',
                            totalHarga,
                            pembayaran,
                          ];
                        },
                      ),
                    ),
            ];
          },
        ),
      );
      
      Navigator.pop(context);
      
      final bytes = await pdf.save();
      
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'laporan_keuangan_lengkap.pdf',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua laporan berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cetakMenuTerlarisPDF(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Container(
                padding: pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'JAJANAN NUSANTARA',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '3 MENU TERLARIS TERATAS',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Tanggal Cetak: ${DateTime.now().toString().substring(0, 16).replaceAll('T', ' ')}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 30),
                    
                    pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('1. Onde-onde', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text('140 porsi terjual', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('2. Bakwan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text('98 porsi terjual', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('3. Putu', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text('85 porsi terjual', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    pw.SizedBox(height: 30),
                    pw.Text(
                      'Terima kasih telah menggunakan',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'sistem manajemen Jajanan Nusantara',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      
      Navigator.pop(context);
      
      final bytes = await pdf.save();
      
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'menu_terlaris.pdf',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu terlaris berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getBulanTahun() {
    final now = DateTime.now();
    final List<String> bulan = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${bulan[now.month - 1]} ${now.year}';
  }

  String _formatWaktu(DateTime waktu) {
    return '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')} - ${waktu.day.toString().padLeft(2, '0')}/${waktu.month.toString().padLeft(2, '0')}/${waktu.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Dashboard Owner',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    widget.namaAdmin,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadAllData();
              _loadLoginData();
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              _cetakSemuaLaporanPDF(context);
            },
            tooltip: 'Cetak Semua Laporan PDF',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HalamanLogin()),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Mengambil data dari Google Sheets...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.red[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person_pin, size: 40, color: Colors.red),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat Datang, ${widget.namaAdmin}!',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'Data real-time dari Google Sheets',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    '📋 Riwayat Login User',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _isLoadingLogin
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _dataLogin.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: Text(
                                      'Belum ada data login',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    itemCount: _dataLogin.length > 5 ? 5 : _dataLogin.length,
                                    itemBuilder: (context, index) {
                                      final login = _dataLogin[index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: login['peran'] == 'Admin' 
                                              ? Colors.red[100] 
                                              : Colors.blue[100],
                                          child: Icon(
                                            login['peran'] == 'Admin' 
                                                ? Icons.admin_panel_settings 
                                                : Icons.person,
                                            size: 18,
                                            color: login['peran'] == 'Admin' 
                                                ? Colors.red[700] 
                                                : Colors.blue[700],
                                          ),
                                        ),
                                        title: Text(
                                          login['nama'],
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        subtitle: Text(
                                          '${login['peran']} - ${_formatWaktu(login['waktu'])}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            login['status'],
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ),
                  if (_dataLogin.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Menampilkan 5 dari ${_dataLogin.length} login terbaru',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('💰 Ringkasan Laporan Pendapatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        onPressed: () {
                          _cetakSemuaLaporanPDF(context);
                        },
                        tooltip: 'Cetak Semua Laporan PDF',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  _buildCardLaporan(
                    konteks: context,
                    judul: 'Laporan Harian',
                    rentangWaktu: 'Hari Ini',
                    omset: _dataHarian['omset'],
                    jumlahTransaksi: _dataHarian['transaksi'],
                    warnaTema: Colors.orange[700]!,
                    ikon: Icons.today,
                    onPrint: () {
                      _cetakLaporanPerPeriodePDF(
                        context,
                        'LAPORAN HARIAN',
                        'harian',
                      );
                    },
                  ),
                  _buildCardLaporan(
                    konteks: context,
                    judul: 'Laporan Mingguan',
                    rentangWaktu: 'Minggu Ini (Senin - Minggu)',
                    omset: _dataMingguan['omset'],
                    jumlahTransaksi: _dataMingguan['transaksi'],
                    warnaTema: Colors.blue[700]!,
                    ikon: Icons.date_range,
                    onPrint: () {
                      _cetakLaporanPerPeriodePDF(
                        context,
                        'LAPORAN MINGGUAN',
                        'mingguan',
                      );
                    },
                  ),
                  _buildCardLaporan(
                    konteks: context,
                    judul: 'Laporan Bulanan',
                    rentangWaktu: 'Bulan berjalan (${_getBulanTahun()})',
                    omset: _dataBulanan['omset'],
                    jumlahTransaksi: _dataBulanan['transaksi'],
                    warnaTema: Colors.green[700]!,
                    ikon: Icons.calendar_month,
                    onPrint: () {
                      _cetakLaporanPerPeriodePDF(
                        context,
                        'LAPORAN BULANAN',
                        'bulanan',
                      );
                    },
                  ),
                  _buildCardLaporan(
                    konteks: context,
                    judul: 'Laporan Tahunan',
                    rentangWaktu: 'Periode Tahun ${DateTime.now().year}',
                    omset: _dataTahunan['omset'],
                    jumlahTransaksi: _dataTahunan['transaksi'],
                    warnaTema: Colors.purple[700]!,
                    ikon: Icons.analytics,
                    onPrint: () {
                      _cetakLaporanPerPeriodePDF(
                        context,
                        'LAPORAN TAHUNAN',
                        'tahunan',
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('🏆 3 Jajanan Terlaris Teratas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf, size: 20, color: Colors.red),
                                onPressed: () {
                                  _cetakMenuTerlarisPDF(context);
                                },
                                tooltip: 'Cetak Menu Terlaris PDF',
                              ),
                            ],
                          ),
                          const Divider(),
                          const ListTile(
                            leading: Icon(Icons.star, color: Colors.amber),
                            title: Text('Onde-onde'),
                            trailing: Text('Porsi terjual: 140x', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const ListTile(
                            leading: Icon(Icons.star, color: Colors.amber),
                            title: Text('Bakwan'),
                            trailing: Text('Porsi terjual: 98x', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const ListTile(
                            leading: Icon(Icons.star, color: Colors.amber),
                            title: Text('Putu'),
                            trailing: Text('Porsi terjual: 85x', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCardLaporan({
    required BuildContext konteks,
    required String judul,
    required String rentangWaktu,
    required String omset,
    required String jumlahTransaksi,
    required Color warnaTema,
    required IconData ikon,
    required VoidCallback onPrint,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(width: 6, color: warnaTema)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Icon(ikon, size: 40, color: warnaTema),
          title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rentangWaktu, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 5),
              Text(jumlahTransaksi, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(omset, style: TextStyle(color: warnaTema, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, size: 20),
                onPressed: onPrint,
                tooltip: 'Cetak PDF',
              ),
            ],
          ),
        ),
      ),
    );
  }
}