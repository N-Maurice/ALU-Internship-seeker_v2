class OpportunityModel {
  const OpportunityModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.workType,
    required this.description,
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final String workType;
  final String description;

  static const mockOpportunities = <OpportunityModel>[
    OpportunityModel(
      id: '1',
      title: 'Mobile Development Intern',
      company: 'Kigali Tech Labs',
      location: 'Kigali, Rwanda',
      workType: 'On-site',
      description: 'Build polished Flutter experiences with a product team.',
    ),
    OpportunityModel(
      id: '2',
      title: 'Product Design Intern',
      company: 'Impact Ventures',
      location: 'Remote',
      workType: 'Remote',
      description:
          'Support research and interface design for early-stage teams.',
    ),
    OpportunityModel(
      id: '3',
      title: 'Business Operations Intern',
      company: 'Green Horizon',
      location: 'Kigali, Rwanda',
      workType: 'Hybrid',
      description: 'Help a growing startup improve its internal operations.',
    ),
  ];
}
