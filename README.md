# 🎓 Université - Portail Étudiant

Système moderne d'inscription universitaire avec gestion des notes par semestre, design UCA-inspired, et dashboard admin complet.

---

## 🚀 Démarrage Rapide

### Backend

```bash
cd backend

# Installer dépendances
pip install -r requirements.txt

# Lancer serveur
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Accessible sur http://localhost:8000
# Documentation API : http://localhost:8000/docs
```

**Compte admin** : `admin@school.com` / `admin123`

### Frontend Web

```bash
cd frontend

# Installer dépendances
flutter pub get

# Lancer en mode web
flutter run -d web-server --web-port 3000

# Accessible sur http://localhost:3000
```

### Frontend Mobile (Android)

```bash
cd frontend

# Vérifier émulateur
flutter devices

# Modifier API URL dans lib/services/api_service.dart
# Ligne 8: baseUrl = 'http://10.0.2.2:8000'

# Lancer
flutter run
```

---

## ✨ Fonctionnalités

### Backend ✅

- **Notes par semestre** : Support Licence (S1-S6), Master, DEUST, DUT, Doctorat
- **Filtrage avancé** : Diplôme, moyenne, statut de profil
- **Analytics** : Statistiques globales et par diplôme
- **OCR** : Extraction automatique (CIN, BAC)
- **Rôles** : ETUDIANT et ADMIN 

### Frontend ✅

- **Thème moderne** : Bleu universitaire #003D7A, glassmorphism
- **Dashboard Admin** :
  - Vue d'ensemble avec 4 stat cards
  - Table étudiants avec filtres
  - NavigationRail moderne
- **Registration** : Inscription étudiant uniquement
- **Profile** : Wizard 4 étapes 

---

## 📊 Endpoints API Principaux

### Authentification
```http
POST /auth/register
POST /auth/login
```

### Admin
```http
GET /admin/students?diploma=licence&min_average=14
GET /admin/students/{id}/grades
GET /admin/statistics
```

### Profil Étudiant
```http
POST /profile/complete
GET /profile/me
GET /profile/status
```

---

## 🏗️ Architecture

```
project/
├── backend/
│   ├── app/
│   │   ├── models/        # SQLAlchemy (User, StudentProfile, SemesterGrade, Offre)
│   │   ├── schemas/       # Pydantic
│   │   ├── routers/       # Endpoints (auth, admin, profile, offres)
│   │   └── utils/         # Auth, OCR, dependencies
│   └── school_enrollment.db  # SQLite
│
└── frontend/
    ├── lib/
    │   ├── core/theme/    # Colors, AppTheme
    │   ├── features/      # Admin, Student features
    │   ├── screens/       # Auth, Admin, Candidat
    │   ├── models/        # User, Offre, Candidature
    │   └── providers/     # State management
```

---

## 🎨 Design System

### Palette 
- **Primary Blue** : `#003D7A`
- **Accent Cyan** : `#00A3E0`
- **Success** : `#10B981`
- **Warning** : `#F59E0B`
- **Error** : `#EF4444`

### Widgets
- `ModernCard` : Glassmorphism effect
- `StatCard` : Dashboard statistics

---

## 📝 Données Modèle

### SemesterGrade
```json
{
  "diploma_type": "licence",
  "semester_number": 1,
  "academic_year": "2023-2024",
  "average": 14.5,
  "grades_detail": {
    "Math": 15.0,
    "Physique": 14.0
  }
}
```

### StudentProfile
```json
{
  "nom": "Dupont",
  "prenom": "Marie",
  "current_diploma": "licence",
  "profile_status": "verified",
  "semester_grades": [...]
}
```

---


3. **Tests**
   - Flow étudiant complet
   - Flow admin complet

---

## 🧪 Tester le Système

### 1. Login Admin
```
URL: http://localhost:3000
Email: admin@school.com
Password: admin123
```

Vous verrez :
- Dashboard avec 4 stat cards
- NavigationRail (Dashboard, Étudiants, Offres, Stats)
- Activity feed

### 2. Onglet Étudiants
- Table avec mock data (3 étudiants)
- Filtres par diplôme et statut
- Actions (voir/modifier)

### 3. API Swagger
```
URL: http://localhost:8000/docs
```
- Tester tous les endpoints
- Login pour obtenir JWT
- Appeler /admin/students avec token

---

## 🛠️ Technologies

### Backend
- **FastAPI** : Framework web moderne
- **SQLAlchemy** : ORM
- **SQLite** : Base de données (dev)
- **Argon2** : Hachage mots de passe
- **Tesseract** : OCR

### Frontend
- **Flutter** : Framework UI
- **Provider** : State management
- **Material 3** : Design system
- **Dio** : HTTP client

---



## 👥 Contributeurs
LAHROUF HIBA
CHAIRA HAJAR 
BOUDHIH HAJAR 


<img width="371" height="825" alt="28" src="https://github.com/user-attachments/assets/8e80c520-224a-4efe-9692-b48d635f87f0" />
<img width="957" height="72" alt="27" src="https://github.com/user-attachments/assets/8e239654-62ed-40bf-a1b5-47c4a46069cc" />
<img width="372" height="835" alt="26" src="https://github.com/user-attachments/assets/fd8cb2da-6bca-4175-b83b-8fc2c8a79b55" />
<img width="848" height="97" alt="25" src="https://github.com/user-attachments/assets/120dab78-ed8a-4a84-8b54-4106c1931f5d" />
<img width="372" height="840" alt="24" src="https://github.com/user-attachments/assets/cfffa199-4939-474f-9ccf-3c9dd311bae4" />
<img width="845" height="110" alt="23" src="https://github.com/user-attachments/assets/36c7c93c-eed0-4a0c-bc64-17b48c5d289f" />
<img width="376" height="832" alt="22" src="https://github.com/user-attachments/assets/7d9ca789-0786-4bbc-b928-e0d552b570c3" />
<img width="893" height="65" alt="21" src="https://github.com/user-attachments/assets/68b96f8d-98c7-43f2-a1d4-3de56f9b44f8" />
<img width="371" height="832" alt="20" src="https://github.com/user-attachments/assets/c0bfdfd7-74d6-432f-9afb-b3e74efcfec3" />
<img width="850" height="71" alt="19" src="https://github.com/user-attachments/assets/6dac8742-45ed-42f7-9b5c-4a880595d2c1" />
<img width="370" height="827" alt="18" src="https://github.com/user-attachments/assets/e226a06f-c3fb-4762-827f-8f841639f116" />
<img width="372" height="836" alt="17" src="https://github.com/user-attachments/assets/51032428-d2d4-43f2-8e56-ccc478b5bb9d" />
<img width="1096" height="100" alt="16" src="https://github.com/user-attachments/assets/c531d572-4c62-4d2b-9180-440e07466049" />
<img width="1452" height="92" alt="15" src="https://github.com/user-attachments/assets/5a2d11f1-c1e7-4fe1-ae69-9162ecceead5" />
<img width="374" height="816" alt="14" src="https://github.com/user-attachments/assets/6bc1ad3d-06c1-4718-a95d-66689d4b2a93" />
<img width="378" height="837" alt="13" src="https://github.com/user-attachments/assets/26a74bfd-2707-427a-b8e9-42d9a05d8372" />
<img width="362" height="848" alt="12" src="https://github.com/user-attachments/assets/75d18758-0d47-403f-ba0b-3df33b368898" />
<img width="1096" height="66" alt="11" src="https://github.com/user-attachments/assets/14fef3a2-3dd2-4dd6-9747-25925f4a0f59" />
<img width="373" height="826" alt="10" src="https://github.com/user-attachments/assets/6badb52d-cfd5-456e-9541-9375300220e8" />
<img width="971" height="102" alt="9" src="https://github.com/user-attachments/assets/69edf9ac-1615-4801-b2fd-21315616e2c0" />
<img width="377" height="835" alt="8" src="https://github.com/user-attachments/assets/b8c4c5ae-5fc3-4da7-835e-1075c841a747" />
<img width="368" height="837" alt="7" src="https://github.com/user-attachments/assets/887b9dda-fa98-4d8b-868f-a2e22d57c6e0" />
<img width="377" height="842" alt="6" src="https://github.com/user-attachments/assets/bd197d3b-c516-4722-bf00-84d4e1de1b30" />
<img width="372" height="832" alt="5" src="https://github.com/user-attachments/assets/6921c065-8419-43cf-a8fa-3d387633c6e9" />
<img width="806" height="98" alt="4" src="https://github.com/user-attachments/assets/a77a595b-5298-44ba-bdc1-06061f627fad" />
<img width="1065" height="81" alt="3" src="https://github.com/user-attachments/assets/2fd01a6c-b762-4d16-96aa-50ccc441be63" />
<img width="373" height="835" alt="2" src="https://github.com/user-attachments/assets/ac881b72-a819-41a4-b9b8-d410911ca827" />
<img width="368" height="828" alt="1" src="https://github.com/user-attachments/assets/5dafec92-bdcb-433d-9ac3-784ce87e8f34" />
<img width="1427" height="106" alt="32" src="https://github.com/user-attachments/assets/29ed6501-19f8-4a81-be25-d3084eb02074" />
<img width="373" height="837" alt="31" src="https://github.com/user-attachments/assets/6cd4613e-ffa4-4065-b75e-8e99b109db59" />
<img width="362" height="840" alt="30" src="https://github.com/user-attachments/assets/7561c584-7024-4ab6-b2e3-2cadfc2f9012" />
<img width="955" height="53" alt="29" src="https://github.com/user-attachments/assets/5acd3e20-ec44-4fc5-8b2c-45a9b848f594" />

