# Système de Gestion des Candidatures - État d'Implémentation

## ✅ Backend COMPLET

### Modifications des Modèles

1. **Candidature** (`models/candidature.py`)
   - ✅ Ajout du statut `INCOMPLETE` 
   - ✅ Modification du statut par défaut: `INCOMPLETE` (au lieu de `SUBMITTED`)
   - ✅ Ajout de la relation `semester_grades`
   - **Workflow des statuts:**
     - `INCOMPLETE` → Candidature créée, notes pas remplies
     - `SUBMITTED` → Toutes les notes remplies, attend validation admin
     - `IN_REVIEW` → En cours de révision par l'admin
     - `ACCEPTED` → Accepté par l'admin
     - `REJECTED` → Refusé par l'admin

2. **SemesterGrade** (`models/semester_grade.py`)
   - ✅ Modification du foreign key: `student_profile_id` → `candidature_id`
   - ✅ Relation avec `Candidature` au lieu de `StudentProfile`

### Nouveaux Endpoints

**1. Endpoints Étudiant** (`routers/candidatures_grades.py`)
   
   - `GET /candidatures/my-candidatures`
     - Récupère toutes les candidatures de l'utilisateur connecté
     - Retourne: statut, nombre de notes, détails de chaque note
   
   - `POST /candidatures/{id}/grades`
     - Ajoute ou modifie une note de semestre
     - Paramètres: semester_number, diploma_type, academic_year, average
   
   - `POST /candidatures/{id}/submit-grades`
     - Change le statut de `INCOMPLETE` à `SUBMITTED`
     - Validation: au moins 1 note doit être remplie
   
   - `DELETE /candidatures/grades/{grade_id}`
     - Supprime une note de semestre

**2. Endpoints Admin** (`routers/admin.py` - ajouts)
   
   - `GET /admin/candidatures?status_filter=submitted`
     - Liste toutes les candidatures avec filtrage par statut
     - Retourne: infos candidat, moyenne totale, vérifications OCR
   
   - `GET /admin/candidatures/{id}`
     - Détails complets d'une candidature 
     - Inclut: toutes les notes, vérifications OCR
   
   - `PUT /admin/candidatures/{id}/status`
     - Accepter ou refuser une candidature
     - Paramètres: new_status (accepted/rejected/in_review), commentaire

## ❌ Frontend À IMPLÉMENTER

### Vue Étudiant

**1. Écran "Mes Candidatures"** (`screens/candidat/my_candidatures_screen.dart`)
```dart
// Liste des candidatures avec:
// - Titre de l'offre
// - Statut (badge coloré)
// - Nombre de notes remplies
// - Bouton "Remplir les notes" si status = INCOMPLETE
// - Bouton "Voir détails" si status != INCOMPLETE
```

**2. Écran "Remplir les Notes"** (`screens/candidat/fill_grades_screen.dart`)
```dart
// Formulaire pour ajouter des notes de semestre:
// - Liste dynamique de semestres (S1, S2, S3...)
// - Pour chaque semestre: Année académique + Moyenne
// - Bouton "Ajouter un semestre"
// - Bouton "Soumettre" (change statut à SUBMITTED)
```

**3. Provider** (`providers/candidatures_provider.dart`)
```dart
// Méthodes à ajouter:
// - fetchMyCandidatures()
// - addGrade(candidatureId, gradeData)
// - submitGrades(candidatureId)
// - deleteGrade(gradeId)
```

**4. API Service** (`services/api_service.dart`)
```dart
// Méthodes à ajouter:
// -  getMyCandidatures()
// - addCandidatureGrade(...)
// - submitCandidatureGrades(id)
// - deleteCandidatureGrade(id)
```

### Vue Admin

**5. Onglet Candidatures** (`features/admin/candidatures_view.dart`)
```dart
// Liste des candidatures avec filtres:
// - Filtre par statut (Incomplète, Soumise, En révision, Accepté, Refusé)
// - Tableau avec: Nom, Offre, Statut, Moyenne, Actions
// - Pour chaque candidature: boutons "Voir détails", "Accepter", "Refuser"
```

**6. Écran Détails Candidature Admin** (`screens/admin/candidature_details_screen.dart`)
```dart
// Détails complets:
// - Infos candidat
// - Toutes les notes de semestre
// - Résultats de vérification OCR (CIN + BAC)
// - Boutons "Accepter" / "Refuser" avec champ commentaire
```

## 📋 Instructions de Test (une fois frontend terminé)

### Test Workflow Complet

1. **En tant qu'étudiant:**
   - Postuler à une offre
   - Aller dans "Mes Candidatures"
   - Voir statut "Incomplète"
   - Cliquer "Remplir les notes"
   - Ajouter S1 (moyenne 14), S2 (moyenne 15), etc.
   - Cliquer "Soumettre"
   - Voir statut changé à "En cours de traitement"

2. **En tant qu'admin:**
   - Aller dans l'onglet "Candidatures"
   - Filtrer par "Soumises"
   - Voir la candidature de l'étudiant
   - Cliquer "Voir détails"
   - Examiner les notes + vérifications OCR
   - Accepter ou refuser avec commentaire

3. **Retour étudiant:**
   - Voir statut "Accepté" ou "Refusé"
   - Lire le commentaire de l'admin

## 🚀 Prochaine Étape

**Vu la taille de l'implémentation frontend, vous avez 2 options:**

**Option 1:** Je crée les fichiers frontend maintenant (long, ~500 lignes de code)

**Option 2:** Vous utilisez ce document comme spécification et implémentez progressivement:
   1. Commencez par le provider et API service
   2. Créez écran "Mes Candidatures" (simple liste)
   3. Créez formulaire de notes
   4. Puis partie admin

**Fichiers Backend Modifiés/Créés:**
- ✅ `backend/app/models/candidature.py`
- ✅ `backend/app/models/semester_grade.py`
- ✅ `backend/app/routers/candidatures_grades.py` (NOUVEAU)
- ✅ `backend/app/routers/admin.py` (ajouts)
- ✅ `backend/app/main.py` (Import du nouveau router)

**Le backend est 100% fonctionnel et peut être testé via Swagger API (`/docs`)**

## 🔄 Après Implémentation Frontend

N'oubliez pas de **supprimer et recréer la base de données** car les modèles ont changé:
```bash
rm backend/school_enrollment.db
# Le backend recréera la DB au démarrage
```
