class AppConstants {
  static const String appName = 'AU Fix';
  static const String appVersion = '1.0.0';

  // Collection Names (Firestore)
  static const String usersCollection = 'users';
  static const String complaintsCollection = 'complaints';
  static const String complaintClustersCollection = 'complaint_clusters';
  static const String notificationsCollection = 'notifications';
  static const String ideasCollection = 'ideas';

  static const List<String> ideaCategories = [
    'Campus Life',
    'Academics & Study Spaces',
    'Sustainability & Green',
    'Technology & Wi-Fi',
    'Hostel & Dining',
    'Sports & Recreation',
    'Events & Culture',
    'Others'
  ];

  static const List<String> complaintCategories = [
    'Hostel',
    'Electrical',
    'Water Supply',
    'Wi-Fi & IT Support',
    'Classroom',
    'Laboratory',
    'Library',
    'Transport',
    'Security',
    'Sanitation & Housekeeping',
    'Furniture & Equipment',
    'Infrastructure & Civil Works',
    'Others'
  ];

  static const Map<String, List<String>> categoryIssueTypes = {
    'Hostel': [
      'Fan Not Working',
      'AC Not Working',
      'Water Leakage',
      'Washroom Issue',
      'Power Issue',
      'Furniture Damage',
      'Pest Control Issue',
      'Other Hostel Issue'
    ],
    'Electrical': [
      'Light Not Working',
      'Power Failure',
      'Socket Damage',
      'Wiring Issue',
      'Electrical Hazard',
      'Generator Issue',
      'Other Electrical Issue'
    ],
    'Water Supply': [
      'Water Cooler Not Working',
      'No Water Supply',
      'Water Leakage',
      'Poor Water Quality',
      'Low Water Pressure',
      'Other Water Issue'
    ],
    'Wi-Fi & IT Support': [
      'No Internet',
      'Slow Internet',
      'Wi-Fi Access Issue',
      'Computer Not Working',
      'Printer Issue',
      'Projector Issue',
      'Smart Board Issue',
      'Other IT Issue'
    ],
    'Classroom': [
      'Damaged Furniture',
      'Projector Not Working',
      'Smart Board Issue',
      'Fan Not Working',
      'Lighting Problem',
      'Cleanliness Issue',
      'Other Classroom Issue'
    ],
    'Laboratory': [
      'Equipment Not Working',
      'Computer Issue',
      'Network Issue',
      'Electrical Issue',
      'Safety Concern',
      'Other Laboratory Issue'
    ],
    'Library': [
      'Computer Issue',
      'Internet Issue',
      'Seating Issue',
      'Lighting Issue',
      'Water Facility Issue',
      'Cleanliness Issue',
      'Other Library Issue'
    ],
    'Transport': [
      'Bus Delay',
      'Bus Breakdown',
      'Route Issue',
      'Driver Complaint',
      'Safety Concern',
      'Other Transport Issue'
    ],
    'Security': [
      'Unauthorized Access',
      'Security Threat',
      'CCTV Issue',
      'Emergency Situation',
      'Safety Concern',
      'Other Security Issue'
    ],
    'Sanitation & Housekeeping': [
      'Garbage Overflow',
      'Washroom Cleaning',
      'Water Stagnation',
      'Unclean Area',
      'Pest Issue',
      'Other Sanitation Issue'
    ],
    'Furniture & Equipment': [
      'Broken Chair',
      'Broken Table',
      'Damaged Equipment',
      'Missing Equipment',
      'Other Furniture Issue'
    ],
    'Infrastructure & Civil Works': [
      'Road Damage',
      'Building Damage',
      'Wall Crack',
      'Ceiling Damage',
      'Drainage Problem',
      'Construction Issue',
      'Other Infrastructure Issue'
    ],
    'Others': [
      'General Complaint',
      'Miscellaneous Issue'
    ]
  };

  static const List<String> departments = [
    'Computer Science',
    'Electronics',
    'Mechanical',
    'Civil',
    'Electrical',
    'Administration',
    'Hostel Management'
  ];
}
