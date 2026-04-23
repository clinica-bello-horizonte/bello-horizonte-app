class MockData {
  MockData._();

  static List<Map<String, dynamic>> get specialties => [
        {
          'id': 'sp_001',
          'name': 'Cardiología',
          'description':
              'Diagnóstico y tratamiento de enfermedades del corazón y sistema circulatorio. Contamos con los mejores especialistas y tecnología de punta.',
          'icon': 'heart',
          'color': '#1565C0',
        },
        {
          'id': 'sp_002',
          'name': 'Medicina General',
          'description':
              'Atención médica integral para toda la familia. Primera línea de atención para diagnóstico, tratamiento y prevención.',
          'icon': 'stethoscope',
          'color': '#00897B',
        },
        {
          'id': 'sp_003',
          'name': 'Ginecología y Obstetricia',
          'description':
              'Atención especializada en salud femenina, embarazo, parto y período postparto. Cuidamos a la madre y al bebé.',
          'icon': 'baby',
          'color': '#AD1457',
        },
        {
          'id': 'sp_004',
          'name': 'Neurología',
          'description':
              'Diagnóstico y tratamiento de enfermedades del sistema nervioso central y periférico. Migraña, epilepsia, Parkinson y más.',
          'icon': 'brain',
          'color': '#6A1B9A',
        },
        {
          'id': 'sp_005',
          'name': 'Traumatología y Ortopedia',
          'description':
              'Atención de lesiones y enfermedades del sistema músculo-esquelético. Huesos, articulaciones, músculos y tendones.',
          'icon': 'bone',
          'color': '#E65100',
        },
        {
          'id': 'sp_006',
          'name': 'Dermatología',
          'description':
              'Diagnóstico y tratamiento de enfermedades de la piel, cabello y uñas. Acné, psoriasis, alergias y más.',
          'icon': 'skin',
          'color': '#F06292',
        },
        {
          'id': 'sp_007',
          'name': 'Pediatría',
          'description':
              'Atención médica especializada para niños desde el nacimiento hasta la adolescencia. Crecimiento, desarrollo y vacunas.',
          'icon': 'child',
          'color': '#2E7D32',
        },
        {
          'id': 'sp_008',
          'name': 'Oftalmología',
          'description':
              'Diagnóstico y tratamiento de enfermedades de los ojos. Miopía, cataratas, glaucoma y más.',
          'icon': 'eye',
          'color': '#00838F',
        },
        {
          'id': 'sp_009',
          'name': 'Urología',
          'description':
              'Atención de enfermedades del aparato urinario y sistema reproductor masculino.',
          'icon': 'kidney',
          'color': '#558B2F',
        },
        {
          'id': 'sp_010',
          'name': 'Gastroenterología',
          'description':
              'Diagnóstico y tratamiento de enfermedades del sistema digestivo: estómago, intestinos, hígado y páncreas.',
          'icon': 'stomach',
          'color': '#4E342E',
        },
        {
          'id': 'sp_011',
          'name': 'Endocrinología',
          'description':
              'Atención de trastornos hormonales y metabólicos. Diabetes, tiroides, obesidad y más.',
          'icon': 'hormone',
          'color': '#283593',
        },
        {
          'id': 'sp_012',
          'name': 'Odontología',
          'description':
              'Atención dental integral: limpieza, caries, ortodoncia, implantes y más. Sonrisas saludables para toda la familia.',
          'icon': 'tooth',
          'color': '#00796B',
        },
      ];

  static List<Map<String, dynamic>> get doctors => [
        // Cardiology
        {
          'id': 'dr_001',
          'first_name': 'Deivis',
          'last_name': 'Jaime Rodríguez',
          'specialty_id': 'sp_001',
          'description':
              'Cardiólogo con más de 15 años de experiencia en el tratamiento de enfermedades cardiovasculares. Especialista en ecocardiografía y arritmias.',
          'photo_url': '',
          'rating': 4.9,
          'years_experience': 15,
          'consultation_fee': 120.0,
          'available_days': '1,2,3,4,5',
        },
        {
          'id': 'dr_002',
          'first_name': 'Jorge',
          'last_name': 'Juárez Herrera',
          'specialty_id': 'sp_001',
          'description':
              'Especialista en cardiología intervencionista. Amplia experiencia en cateterismo cardíaco y angioplastia.',
          'photo_url': '',
          'rating': 4.8,
          'years_experience': 12,
          'consultation_fee': 110.0,
          'available_days': '1,3,5',
        },
        {
          'id': 'dr_003',
          'first_name': 'Robert',
          'last_name': 'Rivas Salcedo',
          'specialty_id': 'sp_001',
          'description':
              'Cardiólogo clínico con enfoque en prevención cardiovascular y rehabilitación cardíaca.',
          'photo_url': '',
          'rating': 4.7,
          'years_experience': 10,
          'consultation_fee': 100.0,
          'available_days': '2,4,6',
        },
        // General Medicine
        {
          'id': 'dr_004',
          'first_name': 'María Elena',
          'last_name': 'Torres Vásquez',
          'specialty_id': 'sp_002',
          'description':
              'Médico general con amplia experiencia en atención primaria. Especializada en medicina familiar y preventiva.',
          'photo_url': '',
          'rating': 4.8,
          'years_experience': 8,
          'consultation_fee': 80.0,
          'available_days': '1,2,3,4,5,6',
        },
        {
          'id': 'dr_005',
          'first_name': 'Carlos',
          'last_name': 'Mendoza Ríos',
          'specialty_id': 'sp_002',
          'description':
              'Médico general con formación en emergencias y medicina interna. Atiende a pacientes de todas las edades.',
          'photo_url': '',
          'rating': 4.6,
          'years_experience': 6,
          'consultation_fee': 80.0,
          'available_days': '1,2,3,4,5',
        },
        // Gynecology
        {
          'id': 'dr_006',
          'first_name': 'Daniel',
          'last_name': 'Valera Campos',
          'specialty_id': 'sp_003',
          'description':
              'Ginecólogo obstetra con más de 20 años de experiencia. Especialista en embarazos de alto riesgo y cirugía ginecológica.',
          'photo_url': '',
          'rating': 4.9,
          'years_experience': 20,
          'consultation_fee': 130.0,
          'available_days': '1,2,3,4,5',
        },
        {
          'id': 'dr_007',
          'first_name': 'Wilder',
          'last_name': 'Córdova Zapata',
          'specialty_id': 'sp_003',
          'description':
              'Especialista en ginecología endocrinológica y reproducción asistida. Amplia experiencia en laparoscopía.',
          'photo_url': '',
          'rating': 4.7,
          'years_experience': 14,
          'consultation_fee': 120.0,
          'available_days': '2,4,6',
        },
        // Neurology
        {
          'id': 'dr_008',
          'first_name': 'Patricia',
          'last_name': 'Luna Castillo',
          'specialty_id': 'sp_004',
          'description':
              'Neuróloga especialista en cefaleas, epilepsia y enfermedades neurodegenerativas. 12 años de experiencia clínica.',
          'photo_url': '',
          'rating': 4.8,
          'years_experience': 12,
          'consultation_fee': 140.0,
          'available_days': '1,3,5',
        },
        // Traumatology
        {
          'id': 'dr_009',
          'first_name': 'Ricardo',
          'last_name': 'Castro Villanueva',
          'specialty_id': 'sp_005',
          'description':
              'Traumatólogo cirujano especialista en cirugía artroscópica de rodilla y hombro. Experto en lesiones deportivas.',
          'photo_url': '',
          'rating': 4.9,
          'years_experience': 18,
          'consultation_fee': 130.0,
          'available_days': '1,2,3,4,5',
        },
        // Dermatology
        {
          'id': 'dr_010',
          'first_name': 'Lucía',
          'last_name': 'Paredes Soto',
          'specialty_id': 'sp_006',
          'description':
              'Dermatóloga con especialización en dermatología estética y cosmética. Experta en tratamiento de acné y envejecimiento.',
          'photo_url': '',
          'rating': 4.7,
          'years_experience': 9,
          'consultation_fee': 110.0,
          'available_days': '2,4,6',
        },
        // Pediatrics
        {
          'id': 'dr_011',
          'first_name': 'Ana Rosa',
          'last_name': 'Gutiérrez Polo',
          'specialty_id': 'sp_007',
          'description':
              'Pediatra con subespecialidad en neonatología. Amplia experiencia en atención de recién nacidos y niños hasta 18 años.',
          'photo_url': '',
          'rating': 4.9,
          'years_experience': 16,
          'consultation_fee': 90.0,
          'available_days': '1,2,3,4,5,6',
        },
        // Ophthalmology
        {
          'id': 'dr_012',
          'first_name': 'Fernando',
          'last_name': 'Reyes Morales',
          'specialty_id': 'sp_008',
          'description':
              'Oftalmólogo especialista en cirugía refractiva y tratamiento del glaucoma. Más de 10 años de experiencia.',
          'photo_url': '',
          'rating': 4.8,
          'years_experience': 10,
          'consultation_fee': 120.0,
          'available_days': '1,3,5',
        },
        // Gastroenterology
        {
          'id': 'dr_013',
          'first_name': 'Miguel',
          'last_name': 'Chávez Ramírez',
          'specialty_id': 'sp_010',
          'description':
              'Gastroenterólogo con experiencia en endoscopía digestiva. Especialista en enfermedades inflamatorias intestinales.',
          'photo_url': '',
          'rating': 4.7,
          'years_experience': 13,
          'consultation_fee': 130.0,
          'available_days': '2,4',
        },
        // Endocrinology
        {
          'id': 'dr_014',
          'first_name': 'Gloria',
          'last_name': 'Sánchez Flores',
          'specialty_id': 'sp_011',
          'description':
              'Endocrinóloga especialista en diabetes mellitus, enfermedades tiroideas y trastornos metabólicos.',
          'photo_url': '',
          'rating': 4.8,
          'years_experience': 11,
          'consultation_fee': 120.0,
          'available_days': '1,2,3,4,5',
        },
        // Dentistry
        {
          'id': 'dr_015',
          'first_name': 'Jorge Luis',
          'last_name': 'Alva Peña',
          'specialty_id': 'sp_012',
          'description':
              'Odontólogo general con especialidad en ortodoncia y estética dental. Implantes dentales y blanqueamiento.',
          'photo_url': '',
          'rating': 4.6,
          'years_experience': 7,
          'consultation_fee': 90.0,
          'available_days': '1,2,3,4,5,6',
        },
      ];

  static List<Map<String, dynamic>> get patientRecords => [
        {
          'id': 'pr_001',
          'user_id': 'demo_user',
          'appointment_id': null,
          'diagnosis': 'Hipertensión arterial leve',
          'treatment': 'Se prescribe losartán 50mg una vez al día. Dieta baja en sodio y ejercicio regular.',
          'notes': 'Paciente refiere cefalea ocasional. Presión arterial: 145/90 mmHg. Control en 30 días.',
          'record_date': '2024-08-15',
          'doctor_name': 'Dr. Deivis Jaime Rodríguez',
          'specialty_name': 'Cardiología',
        },
        {
          'id': 'pr_002',
          'user_id': 'demo_user',
          'appointment_id': null,
          'diagnosis': 'Infección respiratoria aguda',
          'treatment': 'Amoxicilina 500mg cada 8 horas por 7 días. Ibuprofeno 400mg si hay fiebre.',
          'notes': 'Tos productiva y fiebre de 38.5°C. Rx tórax normal. Reposo relativo.',
          'record_date': '2024-10-03',
          'doctor_name': 'Dra. María Elena Torres Vásquez',
          'specialty_name': 'Medicina General',
        },
        {
          'id': 'pr_003',
          'user_id': 'demo_user',
          'appointment_id': null,
          'diagnosis': 'Esguince de tobillo grado II',
          'treatment': 'Vendaje compresivo, RICE (reposo, hielo, compresión, elevación). Diclofenaco 50mg.',
          'notes': 'Lesión durante práctica deportiva. No fractura en Rx. Fisioterapia recomendada.',
          'record_date': '2024-11-20',
          'doctor_name': 'Dr. Ricardo Castro Villanueva',
          'specialty_name': 'Traumatología y Ortopedia',
        },
      ];

  static List<Map<String, dynamic>> healthTips = [
    {
      'id': 'ht_001',
      'title': 'Hidratación diaria',
      'body': 'Bebe al menos 8 vasos de agua al día para mantener tu cuerpo hidratado y favorecer el funcionamiento óptimo de tus órganos.',
      'icon': '💧',
      'color': '#0288D1',
    },
    {
      'id': 'ht_002',
      'title': 'Sueño reparador',
      'body': 'Duerme entre 7 y 8 horas cada noche. El buen descanso refuerza el sistema inmunológico y mejora la salud mental.',
      'icon': '😴',
      'color': '#6A1B9A',
    },
    {
      'id': 'ht_003',
      'title': 'Ejercicio regular',
      'body': 'Realiza al menos 30 minutos de actividad física moderada 5 días a la semana. Caminar, nadar o bailar son excelentes opciones.',
      'icon': '🏃',
      'color': '#2E7D32',
    },
    {
      'id': 'ht_004',
      'title': 'Alimentación balanceada',
      'body': 'Incluye frutas, verduras, proteínas y granos enteros en tu dieta. Reduce el azúcar, sal y alimentos ultraprocesados.',
      'icon': '🥗',
      'color': '#558B2F',
    },
    {
      'id': 'ht_005',
      'title': 'Chequeos preventivos',
      'body': 'Realiza tus controles médicos anuales aunque te sientas bien. La detección temprana salva vidas.',
      'icon': '🏥',
      'color': '#1565C0',
    },
    {
      'id': 'ht_006',
      'title': 'Salud mental',
      'body': 'Dedica tiempo a actividades que te generen bienestar. La meditación, la lectura o pasar tiempo con seres queridos reduce el estrés.',
      'icon': '🧘',
      'color': '#AD1457',
    },
  ];
}
