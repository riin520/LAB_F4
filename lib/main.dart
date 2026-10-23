import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F4_211a290018', // Thay bằng MSSV của ông
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF046807)),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: const ContactListPage(),
      // Named routes
      routes: {
        AboutPage.routeName: (context) => const AboutPage(),
      },
    );
  }
}

// --- MODEL DỮ LIỆU ---
class Contact {
  final String hoTen;
  final String dienThoai;
  final String email;

  const Contact({required this.hoTen, required this.dienThoai, this.email = ''});

  Contact copyWith({String? hoTen, String? dienThoai, String? email}) => Contact(
    hoTen: hoTen ?? this.hoTen,
    dienThoai: dienThoai ?? this.dienThoai,
    email: email ?? this.email,
  );
}

enum DetailAction { updated, deleted }

class DetailResult {
  final DetailAction action;
  final Contact? contact;

  const DetailResult(this.action, [this.contact]);
}

// --- MÀN HÌNH 1: DANH SÁCH ---
class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  final List<Contact> _danhBa = [
    const Contact(hoTen: 'Nguyễn Văn A', dienThoai: '0901234567', email: 'a@vhu.edu.vn'),
    const Contact(hoTen: 'Trần Thị B', dienThoai: '0912345678', email: 'b@vhu.edu.vn'),
    const Contact(hoTen: 'Lê Văn C', dienThoai: '0987654321'),
  ];

  Future<void> _moChiTiet(int viTri) async {
    final result = await Navigator.push<DetailResult>(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailPage(contact: _danhBa[viTri]),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      if (result.action == DetailAction.deleted) {
        _danhBa.removeAt(viTri);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa')));
      } else if (result.contact != null) {
        _danhBa[viTri] = result.contact!;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật')));
      }
    });
  }

  Future<void> _themMoi() async {
    final moi = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(builder: (context) => const ContactEditPage()),
    );
    if (moi == null || !mounted) return;
    setState(() => _danhBa.add(moi));
  }

  // NC1: Hàm mở màn hình tìm kiếm
  Future<void> _moTimKiem() async {
    final chon = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(builder: (context) => ContactSearchPage(danhBa: _danhBa)),
    );
    if (chon != null && mounted) {
      int idx = _danhBa.indexOf(chon);
      if (idx != -1) _moChiTiet(idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh bạ mini'),
        actions: [
          // Nút Tìm kiếm (NC1)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _moTimKiem,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, AboutPage.routeName),
          ),
        ],
      ),
      body: _danhBa.isEmpty
          ? const Center(child: Text('Danh bạ trống'))
          : ListView.builder(
        itemCount: _danhBa.length,
        itemBuilder: (context, i) {
          return ListTile(
            // NC2: Dùng Hero bọc Avatar
            leading: Hero(
              tag: 'avatar_${_danhBa[i].dienThoai}',
              child: CircleAvatar(child: Text(_danhBa[i].hoTen[0])),
            ),
            title: Text(_danhBa[i].hoTen),
            subtitle: Text(_danhBa[i].dienThoai),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _moChiTiet(i),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _themMoi,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- BÀI NÂNG CAO 1: MÀN HÌNH TÌM KIẾM ---
class ContactSearchPage extends StatefulWidget {
  final List<Contact> danhBa;
  const ContactSearchPage({super.key, required this.danhBa});

  @override
  State<ContactSearchPage> createState() => _ContactSearchPageState();
}

class _ContactSearchPageState extends State<ContactSearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ketQua = widget.danhBa.where((c) =>
    c.hoTen.toLowerCase().contains(_query.toLowerCase()) ||
        c.dienThoai.contains(_query)
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm tên hoặc số điện thoại...',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: ListView.builder(
        itemCount: ketQua.length,
        itemBuilder: (context, i) => ListTile(
          leading: CircleAvatar(child: Text(ketQua[i].hoTen[0])),
          title: Text(ketQua[i].hoTen),
          subtitle: Text(ketQua[i].dienThoai),
          onTap: () => Navigator.pop(context, ketQua[i]), // Trả về liên hệ được chọn
        ),
      ),
    );
  }
}

// --- MÀN HÌNH 2: CHI TIẾT ---
class ContactDetailPage extends StatelessWidget {
  final Contact contact;
  const ContactDetailPage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.hoTen)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              // NC2: Điểm đáp của hiệu ứng Hero
              child: Hero(
                tag: 'avatar_${contact.dienThoai}',
                child: CircleAvatar(
                  radius: 50,
                  child: Text(contact.hoTen[0], style: const TextStyle(fontSize: 40)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _dong(Icons.person, 'Họ tên', contact.hoTen),
            _dong(Icons.phone, 'Điện thoại', contact.dienThoai),
            _dong(Icons.email, 'Email', contact.email.isEmpty ? '(chưa có)' : contact.email),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Sửa'),
              onPressed: () async {
                final sua = await Navigator.push<Contact>(
                  context,
                  MaterialPageRoute(builder: (context) => ContactEditPage(banDau: contact)),
                );
                if (sua == null || !context.mounted) return;
                Navigator.pop(context, DetailResult(DetailAction.updated, sua));
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('Xóa'),
              onPressed: () => Navigator.pop(context, const DetailResult(DetailAction.deleted)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dong(IconData icon, String nhan, String giatri) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(nhan, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    subtitle: Text(giatri, style: const TextStyle(fontSize: 17, color: Colors.black87)),
  );
}

// --- MÀN HÌNH 3: THÊM / SỬA ---
class ContactEditPage extends StatefulWidget {
  final Contact? banDau;
  const ContactEditPage({super.key, this.banDau});

  @override
  State<ContactEditPage> createState() => _ContactEditPageState();
}

class _ContactEditPageState extends State<ContactEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ten;
  late final TextEditingController _sdt;
  late final TextEditingController _email;
  bool _daSua = false;

  @override
  void initState() {
    super.initState();
    _ten = TextEditingController(text: widget.banDau?.hoTen ?? '');
    _sdt = TextEditingController(text: widget.banDau?.dienThoai ?? '');
    _email = TextEditingController(text: widget.banDau?.email ?? '');
  }

  @override
  void dispose() {
    _ten.dispose();
    _sdt.dispose();
    _email.dispose();
    super.dispose();
  }

  void _luu() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Contact(
        hoTen: _ten.text.trim(),
        dienThoai: _sdt.text.trim(),
        email: _email.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_daSua, // Nếu đã sửa thì chặn pop (bắt buộc = false)
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final thoat = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Bỏ thay đổi?'),
            content: const Text('Dữ liệu bạn vừa nhập sẽ không được lưu.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ở lại')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Thoát')),
            ],
          ),
        );
        if (thoat == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.banDau == null ? 'Thêm liên hệ' : 'Sửa liên hệ')),
        body: Form(
          key: _formKey,
          onChanged: () => setState(() => _daSua = true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _ten,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sdt,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                validator: (v) => (v == null || v.trim().length < 9) ? 'Số điện thoại không hợp lệ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email (không bắt buộc)'),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _luu, child: const Text('Lưu')),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MÀN HÌNH PHỤ: GIỚI THIỆU ---
class AboutPage extends StatelessWidget {
  static const routeName = '/about';
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giới thiệu')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Lab F4\nĐiều hướng đa màn hình\nNguyễn Tuấn Thành - 211a290018',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}