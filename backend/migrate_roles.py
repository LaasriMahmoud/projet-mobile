"""
Migration script to update user roles from old naming to new naming
ETUDIANT -> CANDIDAT
"""

from app.database import SessionLocal, engine
from sqlalchemy import text

def migrate_user_roles():
    """Update existing user roles from ETUDIANT to CANDIDAT"""
    db = SessionLocal()
    try:
        # Update users table - change role from 'ETUDIANT' to 'CANDIDAT'
        result = db.execute(
            text("UPDATE users SET role = 'CANDIDAT' WHERE role = 'ETUDIANT'")
        )
        db.commit()
        
        print(f"Successfully updated {result.rowcount} user(s) from 'etudiant' to 'candidat'")
        
        # Show current role distribution
        roles = db.execute(text("SELECT role, COUNT(*) as count FROM users GROUP BY role")).fetchall()
        print("\nCurrent role distribution:")
        for role, count in roles:
            print(f"   - {role}: {count}")
            
    except Exception as e:
        print(f"Error during migration: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    print("Starting user role migration...")
    migrate_user_roles()
    print("\nMigration complete!")
