import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ALU Venture Connect',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Arial',
          scaffoldBackgroundColor: const Color(0xfff5f8fe),
          colorScheme: ColorScheme.fromSeed(seedColor: _navy),
        ),
        home: const VentureConnectApp(),
      );
}

const _navy = Color(0xff003e7e);
const _red = Color(0xffed1939);
const _ink = Color(0xff20242a);
const _canvas = Color(0xfff5f8fe);

class VentureConnectApp extends StatefulWidget {
  const VentureConnectApp({super.key});
  @override
  State<VentureConnectApp> createState() => _VentureConnectAppState();
}

class _VentureConnectAppState extends State<VentureConnectApp> {
  String _page = 'welcome';
  int _tab = 0;
  void _open(String page) => setState(() => _page = page);
  void _selectTab(int index) => setState(() {
        _page = 'app';
        _tab = index;
      });

  @override
  Widget build(BuildContext context) {
    if (_page == 'welcome')
      return _Welcome(
          onStart: () => _open('signup'), onLogin: () => _open('login'));
    if (_page == 'login' || _page == 'signup')
      return _AuthPage(
          signup: _page == 'signup',
          onDone: () => _open('app'),
          onSwitch: () => _open(_page == 'login' ? 'signup' : 'login'));
    if (_page == 'detail') return _DetailPage(onBack: () => _selectTab(1));
    return Scaffold(
        body: SafeArea(child: _tabBody()),
        bottomNavigationBar: _NavBar(index: _tab, onTap: _selectTab));
  }

  Widget _tabBody() {
    switch (_tab) {
      case 0:
        return _Dashboard(onExplore: () => _selectTab(1));
      case 1:
        return _Explore(onDetail: () => _open('detail'));
      case 2:
        return const _Applications();
      case 3:
        return const _Messages();
      default:
        return const _Profile();
    }
  }
}

class _Logo extends StatelessWidget {
  const _Logo({this.size = 44});
  final double size;
  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/images/ALU logo.png',
          width: size, height: size, fit: BoxFit.contain);
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onStart, required this.onLogin});
  final VoidCallback onStart, onLogin;
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 92, 28, 28),
                      child: Column(children: [
                        const Spacer(),
                        const _Logo(size: 76),
                        const SizedBox(height: 35),
                        const Text('ALU Venture Connect',
                            style: TextStyle(
                                color: _navy,
                                fontSize: 29,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 14),
                        const Text(
                            'Connecting ALU talent with high-\nimpact ventures.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xff454b55),
                                height: 1.45)),
                        const SizedBox(height: 46),
                        Container(
                            height: 125,
                            decoration: BoxDecoration(
                                color: const Color(0xffe7edf7),
                                borderRadius: BorderRadius.circular(3)),
                            child: const Center(
                                child: Icon(Icons.groups_rounded,
                                    color: _navy, size: 60))),
                        const SizedBox(height: 48),
                        _PrimaryButton(
                            label: 'Get Started  →', onPressed: onStart),
                        TextButton(
                            onPressed: onLogin,
                            child: const Text('I already have an account',
                                style: TextStyle(color: _red))),
                        const Spacer(),
                        const Text('PART OF THE ALU ECOSYSTEM',
                            style: TextStyle(
                                color: Color(0xff9ca3af),
                                letterSpacing: 1.5,
                                fontSize: 11)),
                      ]))))));
}

class _AuthPage extends StatelessWidget {
  const _AuthPage(
      {required this.signup, required this.onDone, required this.onSwitch});
  final bool signup;
  final VoidCallback onDone, onSwitch;
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: signup ? Colors.white : _canvas,
      body: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!signup) const SizedBox(height: 72),
                        Row(
                            mainAxisAlignment: signup
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.center,
                            children: [
                              const _Logo(),
                              Text('ALU Venture Connect',
                                  style: TextStyle(
                                      color: _navy,
                                      fontWeight: FontWeight.w700,
                                      fontSize: signup ? 23 : 24))
                            ]),
                        SizedBox(height: signup ? 26 : 28),
                        if (signup) ...[
                          const Text('Create Account',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          const Text(
                              'Enter your details to join the ALU Venture community.'),
                          const SizedBox(height: 26)
                        ] else ...[
                          const Center(
                              child: Text(
                                  'Connecting student ambition with startup opportunities.')),
                          const SizedBox(height: 25)
                        ],
                        Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: const Color(0xffc5cdc3)),
                                borderRadius: BorderRadius.circular(7)),
                            child: Column(children: [
                              if (signup) ...[
                                _Field('Full Name', 'John Doe',
                                    Icons.person_outline),
                                _Field('ALU Email', 'j.doe@alustudent.com',
                                    Icons.mail_outline),
                                _Field('Graduation Year', 'Select Year',
                                    Icons.school_outlined)
                              ],
                              _Field(
                                  'Email Address',
                                  'student@alueducation.com',
                                  Icons.mail_outline),
                              _Field('Password', '••••••••', Icons.lock_outline,
                                  suffix: 'Forgot Password?'),
                              const SizedBox(height: 10),
                              Row(children: [
                                const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                        value: false, onChanged: null)),
                                const SizedBox(width: 8),
                                Text(signup
                                    ? 'I agree to the Terms of Service and Privacy Policy.'
                                    : 'Remember this device')
                              ]),
                              const SizedBox(height: 24),
                              _PrimaryButton(
                                  label:
                                      signup ? 'Create Account  →' : 'Sign In',
                                  onPressed: onDone),
                              const SizedBox(height: 18),
                              const Row(children: [
                                Expanded(child: Divider()),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('New to the community?',
                                        style: TextStyle(fontSize: 12))),
                                Expanded(child: Divider())
                              ]),
                              const SizedBox(height: 15),
                              OutlinedButton(
                                  onPressed: onSwitch,
                                  style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(46),
                                      foregroundColor: _navy),
                                  child: Text(signup
                                      ? 'Sign In instead'
                                      : 'Create an account')),
                            ])),
                        const SizedBox(height: 26),
                        const Center(
                            child: Text(
                                'Privacy Policy     Terms of Service     Help Center',
                                style: TextStyle(
                                    color: Color(0xff6b7280), fontSize: 12))),
                      ])))));
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.hint, this.icon, {this.suffix});
  final String label, hint;
  final IconData icon;
  final String? suffix;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label),
          const Spacer(),
          if (suffix != null)
            Text(suffix!, style: const TextStyle(color: _navy))
        ]),
        const SizedBox(height: 7),
        TextField(
            obscureText: label == 'Password',
            decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(icon),
                suffixIcon: label == 'Password'
                    ? const Icon(Icons.visibility_outlined)
                    : null,
                filled: true,
                fillColor: const Color(0xfffbfcff),
                border: const OutlineInputBorder()))
      ]));
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.onExplore});
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) => _Page(
          child: ListView(children: [
        const _TopBar(),
        const SizedBox(height: 30),
        const Text('Hello, Student Name ✹',
            style: TextStyle(fontSize: 29, fontWeight: FontWeight.w700)),
        const Text(
            'Welcome back to the ALU career hub. You\nhave 3 new updates to your applications.',
            style: TextStyle(fontSize: 16, height: 1.45)),
        const SizedBox(height: 20),
        const _StatusCard(),
        const SizedBox(height: 24),
        const _SectionCard(
            title: 'Recent Alerts',
            child: Column(children: [
              _Alert(Icons.mail_outline, 'Interview request from\nPayStack',
                  '2 hours ago'),
              const Divider(),
              _Alert(Icons.bookmark_border, 'Match: UX Design at\nFlutterwave',
                  'Yesterday')
            ])),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Upcoming',
            child: Column(children: [
              _Event('OCT\n24', 'Zindi Africa', 'Technical Round • 14:00'),
              const SizedBox(height: 14),
              _Event('OCT\n27', 'Kuda Bank', 'Final Selection • 10:30'),
              const SizedBox(height: 14),
              OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      foregroundColor: _navy),
                  child: const Text('Sync Calendar'))
            ])),
        const SizedBox(height: 24),
        _SectionCard(
            title: 'Recommended Opportunities',
            child: _MiniOpportunity(onTap: onExplore)),
        const SizedBox(height: 20)
      ]));
}

class _Explore extends StatelessWidget {
  const _Explore({required this.onDetail});
  final VoidCallback onDetail;
  @override
  Widget build(BuildContext context) => _Page(
          child: Column(children: [
        const _TopBar(title: 'Venture Connect'),
        const SizedBox(height: 24),
        TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search opportunities...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder())),
        const SizedBox(height: 15),
        const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _Filter('Industry', true),
              _Filter('Role', false),
              _Filter('Remote', false),
              _Filter('Duration', false)
            ])),
        const SizedBox(height: 25),
        Expanded(
            child: ListView(children: [
          _OpportunityCard(
              'Software\nEngineering Intern',
              'Zuri Tech Solutions',
              'Product Team',
              'Remote\n(Kigali base)',
              '3 Months',
              'Posted 2d ago',
              ['React.js', 'Node.js', 'TypeScript'],
              onDetail),
          _OpportunityCard(
              'Product Design\nAssociate',
              'PayFlow Africa',
              'UX/UI Team',
              'Hybrid\n(Nairobi)',
              '6 Months',
              'Posted 5h ago',
              ['Figma', 'User Research', 'Prototyping'],
              onDetail),
          _OpportunityCard(
              'Data Analyst Intern',
              'EcoFarm AI',
              'Operations',
              'Remote',
              '4 Months',
              'Posted 1d ago',
              ['Python', 'SQL', 'Tableau'],
              onDetail)
        ]))
      ]));
}

class _Applications extends StatelessWidget {
  const _Applications();
  @override
  Widget build(BuildContext context) => _Page(
          child: ListView(children: [
        const _TopBar(title: 'My Applications'),
        const SizedBox(height: 17),
        const Row(children: [
          _Pill('Applied', true),
          _Pill('Interview', false),
          _Pill('Accepted', false),
          _Pill('Rejected', false)
        ]),
        const SizedBox(height: 24),
        _Application('Flutter Developer', 'Learnify • Tech Education',
            'Applied 3 days ago', 'UNDER REVIEW'),
        _Application('UX Research Volunteer', 'EduBridge • Social Impact',
            'Applied 1 week ago', 'SHORTLISTED'),
        _Application('Social Media Assistant', 'GreenLoop • Sustainability',
            'Applied 2 weeks ago', 'CLOSED'),
        _Application('Backend Intern', 'FinFlow • Fintech', 'Applied yesterday',
            'SUBMITTED'),
        const SizedBox(height: 15),
        const _SectionCard(
            title: 'Application Insight',
            child: Text(
                "You've applied to 4 ventures this month. Your profile is 20% more active than average.\n\nView matching trends  →"))
      ]));
}

class _Messages extends StatelessWidget {
  const _Messages();
  @override
  Widget build(BuildContext context) => _Page(
          child: ListView(children: [
        const _TopBar(title: 'Venture Connect'),
        const SizedBox(height: 26),
        const Text('NETWORK',
            style: TextStyle(color: _navy, letterSpacing: 2, fontSize: 11)),
        const Text('Messages',
            style: TextStyle(fontSize: 31, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search startups or founders...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder())),
        const SizedBox(height: 23),
        const Text('ACTIVE VENTURES',
            style: TextStyle(letterSpacing: 2, fontSize: 11)),
        const SizedBox(height: 15),
        const _SectionCard(
            title: '',
            child: Column(children: [
              _Message('Nexus Logistics',
                  'Great meeting today! I\'ve sent over...', '10:42 AM'),
              _Message(
                  'Dr. Amina Jaleel',
                  'Thanks for the feedback on the health-tech proposal...',
                  '9:15 AM'),
              _Message(
                  'Solaris Energy',
                  'Your application for the Venture Connect internship has been moved...',
                  'Yesterday'),
              _Message('Marc Henderson',
                  "I've seen the deck. Can we talk about it?", 'Tuesday')
            ]))
      ]));
}

class _Profile extends StatelessWidget {
  const _Profile();
  @override
  Widget build(BuildContext context) => _Page(
          child: ListView(children: [
        const _TopBar(title: 'Venture Connect'),
        const SizedBox(height: 42),
        const Center(
            child: CircleAvatar(
                radius: 46,
                backgroundColor: Color(0xffdce6f4),
                child: Icon(Icons.person, size: 52, color: _navy))),
        const SizedBox(height: 17),
        const Center(
            child: Text('Amina Hassan',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700))),
        const Center(child: Text('⌾ Kigali, Rwanda')),
        const SizedBox(height: 28),
        const Row(children: [
          _Metric('12', 'APPLICATIONS'),
          _Metric('6', 'SHORTLISTED'),
          _Metric('3', 'ACCEPTED')
        ]),
        const SizedBox(height: 4),
        const _SectionCard(
            title: '',
            child: Column(children: [
              _ProfileRow(Icons.person_outline, 'My Profile'),
              _ProfileRow(Icons.star_border, 'Skills & Interests'),
              _ProfileRow(Icons.bookmark_border, 'Saved Opportunities'),
              _ProfileRow(Icons.notifications_none, 'Notifications'),
              _ProfileRow(Icons.help_outline, 'Help & Support'),
              _ProfileRow(Icons.logout, 'Logout', red: true)
            ])),
        Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: _navy, borderRadius: BorderRadius.circular(7)),
            child: const Text(
                '♧  Boost your visibility\n    Adding 3 more skills to your profile increases\n    your chance of being shortlisted by 40%.',
                style: TextStyle(color: Colors.white)))
      ]));
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Scaffold(
          body: SafeArea(
              child: Column(children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: _navy)),
              const Spacer(),
              const Icon(Icons.share_outlined),
              const SizedBox(width: 20),
              const Icon(Icons.bookmark_border)
            ])),
        Expanded(
            child: ListView(padding: const EdgeInsets.all(32), children: [
          const _Logo(size: 62),
          const SizedBox(height: 18),
          const Text('Product Design Fellow',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
          const Text('Nexus Analytics Group',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff4c594e))),
          const SizedBox(height: 24),
          const Row(children: [
            _DetailMetric(
                Icons.location_on_outlined, 'Location', 'Kigali, Rwanda'),
            _DetailMetric(Icons.business_center_outlined, 'Type', 'Full-time')
          ]),
          const SizedBox(height: 8),
          const Row(children: [
            _DetailMetric(Icons.schedule_outlined, 'Duration', '6 Months'),
            _DetailMetric(
                Icons.calendar_today_outlined, 'Deadline', 'Oct 12, 2023')
          ]),
          const SizedBox(height: 38),
          const Text('About the Role',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const Text(
              'As a Product Design Fellow at Nexus, you will bridge the gap between user needs and technical feasibility. We are looking for an ambitious ALU student who is passionate about building data-driven interfaces that feel human.',
              style: TextStyle(height: 1.6)),
          const SizedBox(height: 28),
          const Text('Responsibilities',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...[
            'Develop high-fidelity prototypes and wireframes for new mobile features.',
            'Conduct user research sessions with Kigali-based startup founders.',
            'Collaborate with the engineering team to ensure design handoff is seamless.'
          ].map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_circle_outline, color: _navy),
                const SizedBox(width: 12),
                Expanded(child: Text(e))
              ]))),
          const SizedBox(height: 20),
          const Text('Requirements & Skills',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
          const Wrap(spacing: 7, children: [
            Chip(label: Text('Figma Expert')),
            Chip(label: Text('UI/UX Design')),
            Chip(label: Text('User Research'))
          ])
        ])),
        Padding(
            padding: const EdgeInsets.all(16),
            child: _PrimaryButton(label: 'Apply Now  ▷', onPressed: () {}))
      ])));
}

class _Page extends StatelessWidget {
  const _Page({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22), child: child);
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.title});
  final String? title;
  @override
  Widget build(BuildContext context) => Row(children: [
        const _Logo(),
        const SizedBox(width: 10),
        if (title != null)
          Text(title!,
              style: const TextStyle(
                  fontSize: 23, fontWeight: FontWeight.w700, color: _navy)),
        const Spacer(),
        const Icon(Icons.notifications_none, color: _ink)
      ]);
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
          child: Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))));
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) => NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onTap,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xffe7edf6),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Explore'),
            NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'Apps'),
            NavigationDestination(
                icon: Icon(Icons.message_outlined),
                selectedIcon: Icon(Icons.message),
                label: 'Messages'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile')
          ]);
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();
  @override
  Widget build(BuildContext context) => const _SectionCard(
      title: 'Application Status    View All →',
      child: Row(children: [
        _Metric('12', 'APPLIED'),
        _Metric('4', 'INTERVIEWS', selected: true),
        _Metric('2', 'OFFERS', red: true)
      ]));
}

class _Metric extends StatelessWidget {
  const _Metric(this.number, this.label,
      {this.selected = false, this.red = false});
  final String number, label;
  final bool selected, red;
  @override
  Widget build(BuildContext context) => Expanded(
      child: Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: selected ? _navy : Colors.white,
              border: Border.all(color: const Color(0xffd9dfe8)),
              borderRadius: BorderRadius.circular(5)),
          child: Column(children: [
            Text(number,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : red
                            ? _red
                            : _ink)),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    color: selected ? Colors.white : _ink))
          ])));
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffdce1e8))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title.isNotEmpty)
          Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700))),
        child
      ]));
}

class _Alert extends StatelessWidget {
  const _Alert(this.icon, this.title, this.time);
  final IconData icon;
  final String title, time;
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
                color: const Color(0xffffe8ee),
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: _red)),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(time,
              style: const TextStyle(fontSize: 12, color: Color(0xff606975)))
        ]))
      ]);
}

class _Event extends StatelessWidget {
  const _Event(this.date, this.name, this.detail);
  final String date, name, detail;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: _canvas,
          border: Border.all(color: const Color(0xffcbd4e1)),
          borderRadius: BorderRadius.circular(5)),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xffcbd4e1)),
                borderRadius: BorderRadius.circular(5)),
            child: Text(date,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _red, fontWeight: FontWeight.w700, fontSize: 12))),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text(detail, style: const TextStyle(fontSize: 12))
        ])
      ]));
}

class _MiniOpportunity extends StatelessWidget {
  const _MiniOpportunity({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Data Analyst Intern',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19)),
        const Text('SolarRise Energy • Remote'),
        const Wrap(
            spacing: 5,
            children: [Chip(label: Text('Python')), Chip(label: Text('SQL'))]),
        _PrimaryButton(label: 'Quick Apply', onPressed: onTap)
      ]);
}

class _Filter extends StatelessWidget {
  const _Filter(this.label, this.selected);
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
              backgroundColor: selected ? _navy : Colors.transparent,
              foregroundColor: selected ? Colors.white : _ink,
              side: const BorderSide(color: Color(0xffbdc7d6))),
          child: Text('$label⌄')));
}

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard(this.title, this.company, this.role, this.location,
      this.duration, this.posted, this.tags, this.onTap);
  final String title, company, role, location, duration, posted;
  final List<String> tags;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          margin: const EdgeInsets.only(bottom: 17),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xffe0e4eb))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: _navy,
                          fontSize: 23,
                          fontWeight: FontWeight.w700))),
              const Icon(Icons.bookmark_border, color: _navy)
            ]),
            const SizedBox(height: 7),
            Text(company, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: Text('▦  $role')),
              Expanded(child: Text('⌖  $location'))
            ]),
            const SizedBox(height: 13),
            Row(children: [
              Expanded(child: Text('◷  $duration')),
              Expanded(child: Text('▣  $posted'))
            ]),
            const SizedBox(height: 15),
            Wrap(
                spacing: 6,
                runSpacing: 4,
                children: tags
                    .map((e) => Chip(
                        label: Text(e), visualDensity: VisualDensity.compact))
                    .toList())
          ])));
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.selected);
  final String text;
  final bool selected;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
          label: Text(text),
          backgroundColor: selected ? _navy : const Color(0xffe5e8e1),
          labelStyle: TextStyle(color: selected ? Colors.white : _ink)));
}

class _Application extends StatelessWidget {
  const _Application(this.title, this.company, this.date, this.status);
  final String title, company, date, status;
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffcbd3c5)),
          borderRadius: BorderRadius.circular(5)),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.rocket_launch_outlined, color: _navy),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                Text(company, style: const TextStyle(fontSize: 12))
              ])),
          const Icon(Icons.bookmark_border)
        ]),
        const Divider(height: 26),
        Row(children: [
          Text('◷  $date', style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Chip(label: Text(status), visualDensity: VisualDensity.compact)
        ])
      ]));
}

class _Message extends StatelessWidget {
  const _Message(this.name, this.preview, this.time);
  final String name, preview, time;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(children: [
        const CircleAvatar(
            backgroundColor: Color(0xffe7edf6),
            child: Icon(Icons.business, color: _navy)),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text(preview, style: const TextStyle(color: Color(0xff697386)))
        ])),
        Text(time,
            style: const TextStyle(fontSize: 11, color: Color(0xff697386)))
      ]));
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.icon, this.text, {this.red = false});
  final IconData icon;
  final String text;
  final bool red;
  @override
  Widget build(BuildContext context) => Column(children: [
        ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: red ? _red : _navy),
            title: Text(text,
                style: TextStyle(
                    color: red ? _red : _ink, fontWeight: FontWeight.w500)),
            trailing:
                Icon(Icons.chevron_right, color: red ? _red : Colors.grey)),
        const Divider()
      ]);
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Expanded(
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xffedf2f8),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: const Color(0xffdbe1e8))),
          child: Column(children: [
            Icon(icon, color: _navy),
            const SizedBox(height: 7),
            Text(label, style: const TextStyle(color: Color(0xff4e5a50))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500))
          ])));
}
