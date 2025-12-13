# École Inscription App - Backend

FastAPI backend for school enrollment application with OCR document verification.

## Prerequisites

- Python 3.10+
- MySQL Server running
- Tesseract OCR installed

### Installing Tesseract (Windows)

1. Download from: https://github.com/UB-Mannheim/tesseract/wiki
2. Install to `C:\Program Files\Tesseract-OCR`
3. Add to system PATH
4. Install French language data during installation

## Setup

### 1. Create Python Virtual Environment

```bash
cd backend
python -m venv venv
venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Database

Create MySQL database:
```sql
CREATE DATABASE school_enrollment CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 4. Environment Variables

Copy `.env.example` to `.env` and update:

```env
DATABASE_URL=mysql+pymysql://root:your_password@localhost:3306/school_enrollment
SECRET_KEY=your-secret-key-min-32-characters-long
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### 5. Run Application

```bash
uvicorn app.main:app --reload
```

The API will be available at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login and get JWT token
- `GET /auth/me` - Get current user profile

### Offres
- `GET /offres` - List offres (filtered by role)
- `GET /offres/{id}` - Get offre details
- `POST /offres` - Create offre (RECRUTEUR)
- `PUT /offres/{id}` - Update offre
- `DELETE /offres/{id}` - Delete offre

### Candidatures
- `POST /candidatures` - Submit candidature with documents
- `POST /candidatures/verify` - Test OCR on document
- `GET /candidatures/me` - Get my candidatures (CANDIDAT)
- `GET /candidatures/offre/{id}` - Get candidatures for offre (RECRUTEUR/ADMIN)

### Admin
- `GET /admin/users` - List all users
- `PUT /admin/users/{id}/status` - Activate/deactivate user
- `GET /admin/offres/pending` - Get pending offres
- `PUT /admin/offres/{id}/validate` - Validate/reject offre
- `DELETE /admin/users/{id}` - Delete user

## Testing

### Using Swagger UI

1. Go to http://localhost:8000/docs
2. Register a user with POST /auth/register
3. Login with POST /auth/login
4. Click "Authorize" button and enter token
5. Test other endpoints

### Test Users

Create these users for testing different roles:

**Admin:**
```json
{
  "email": "admin@school.com",
  "username": "admin",
  "password": "admin123",
  "role": "admin"
}
```

**Recruteur:**
```json
{
  "email": "recruteur@school.com",
  "username": "recruteur",
  "password": "recruteur123",
  "role": "recruteur"
}
```

**Candidat:**
```json
{
  "email": "candidat@example.com",
  "username": "candidat",
  "password": "candidat123",
  "role": "candidat"
}
```

## Project Structure

```
backend/
├── app/
│   ├── main.py              # FastAPI application
│   ├── config.py            # Configuration
│   ├── database.py          # Database connection
│   ├── models/              # SQLAlchemy models
│   ├── schemas/             # Pydantic schemas
│   ├── routers/             # API routes
│   └── utils/               # Utilities (auth, OCR)
├── uploads/                 # Uploaded documents
├── requirements.txt
└── .env
```
