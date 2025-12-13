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
- **OCR** : Extraction automatique (CIN, BAC, Relevé de notes)
- **Rôles** : ETUDIANT et ADMIN (RECRUTEUR supprimé)

### Frontend ✅

- **Thème moderne UCA** : Bleu universitaire #003D7A, glassmorphism
- **Dashboard Admin** :
  - Vue d'ensemble avec 4 stat cards
  - Table étudiants avec filtres
  - NavigationRail moderne
- **Registration** : Inscription étudiant uniquement
- **Profile** : Wizard 4 étapes (à compléter côté API)

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

### Palette UCA
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

## ✅ Ce qui est terminé

### Backend (95%)
- [x] Modèles complets (User, StudentProfile, SemesterGrade, Offre)
- [x] Rôles simplifiés (ETUDIANT, ADMIN)
- [x] Endpoints admin analytics
- [x] Filtrage et pagination
- [x] Service OCR (CIN, BAC, Relevé)

### Frontend (70%)
- [x] Thème moderne UCA
- [x] Dashboard admin avec stats
- [x] Vue étudiants avec table et filtres
- [x] Registration simplifié (étudiant uniquement)
- [x] Profile completion wizard
- [ ] Intégration API complète
- [ ] Upload documents réel
- [ ] Vue détails étudiant

---

## 🔜 À Compléter

### Court terme (2-4h)
1. **Connecter API au frontend**
   - StudentsView → GET /admin/students
   - Dashboard stats → GET /admin/statistics
   
2. **Upload documents**
   - Implémenter image picker
   - POST vers /profile/complete

3. **Navigation profil**
   - Rediriger vers ProfileCompletionScreen si profil incomplet
   - Vérifier statut avant candidatures

### Moyen terme (4-6h)
1. **Vue détails étudiant**
   - Notes par semestre
   - Graphiques d'évolution
   
2. **Gestion offres admin**
   - Création/édition offres
   - CRUD complet

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

## 📚 Documentation

- **API** : http://localhost:8000/docs (Swagger UI)
- **Implementation Plan** : `brain/implementation_plan.md`
- **Walkthrough** : `brain/walkthrough.md`
- **Tasks** : `brain/task.md`

---

## 👥 Contributeurs

Développé pour transformer une application scolaire basique en système universitaire moderne.

## 📄 Licence

MIT
