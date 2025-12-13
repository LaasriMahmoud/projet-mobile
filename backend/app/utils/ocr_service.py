import pytesseract
from PIL import Image
import os
from typing import Dict, Any
import re


class OCRService:
    """Service for extracting text from images using Tesseract OCR"""
    
    def __init__(self):
        # Configure Tesseract path for Windows if needed
        # Check standard installation paths
        tesseract_paths = [
            r'C:\Program Files\Tesseract-OCR\tesseract.exe',
            r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe',
            r'C:\Users\Mahmoud\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'
        ]
        
        for path in tesseract_paths:
            if os.path.exists(path):
                pytesseract.pytesseract.tesseract_cmd = path
                break
    
    def extract_text(self, image_path: str, lang: str = 'fra') -> Dict[str, Any]:
        """
        Extract text from an image using OCR
        
        Args:
            image_path: Path to the image file
            lang: Language for OCR (default: 'fra' for French)
            
        Returns:
            Dictionary with extracted text and metadata
        """
        try:
            if not os.path.exists(image_path):
                return {
                    "success": False,
                    "error": "Image file not found",
                    "extracted_text": "",
                    "confidence": 0.0
                }
            
            # Open and process image
            image = Image.open(image_path)
            
            # Extract text
            text = pytesseract.image_to_string(image, lang=lang)
            
            # Get confidence data
            data = pytesseract.image_to_data(image, lang=lang, output_type=pytesseract.Output.DICT)
            confidences = [int(conf) for conf in data['conf'] if int(conf) > 0]
            avg_confidence = sum(confidences) / len(confidences) if confidences else 0
            
            return {
                "success": True,
                "extracted_text": text.strip(),
                "confidence": round(avg_confidence, 2),
                "error": None
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "extracted_text": "",
                "confidence": 0.0
            }
    
    def verify_cin(self, image_path: str) -> Dict[str, Any]:
        """
        Verify CIN (Carte d'Identité Nationale) and extract information
        
        Returns:
            Dictionary with verified fields
        """
        ocr_result = self.extract_text(image_path)
        
        if not ocr_result["success"]:
            return {
                "success": False,
                "verified_fields": {},
                **ocr_result
            }
        
        text = ocr_result["extracted_text"]
        
        # Extract common CIN fields using regex patterns
        verified_fields = {}
        
        # Try to extract name (usually after "Nom" or "NOM")
        nom_match = re.search(r'(?:Nom|NOM)[\s:]+([A-ZÀ-Ÿ\s]+)', text, re.IGNORECASE)
        if nom_match:
            verified_fields["nom"] = nom_match.group(1).strip()
        
        # Try to extract first name
        prenom_match = re.search(r'(?:Prénom|Prenom|PRENOM)[\s:]+([A-ZÀ-Ÿ\s]+)', text, re.IGNORECASE)
        if prenom_match:
            verified_fields["prenom"] = prenom_match.group(1).strip()
        
        # Try to extract date of birth
        date_match = re.search(r'(\d{2}[/-]\d{2}[/-]\d{4})', text)
        if date_match:
            verified_fields["date_naissance"] = date_match.group(1)
        
        # Try to extract CIN number
        cin_match = re.search(r'([A-Z]{1,2}\d{5,8})', text)
        if cin_match:
            verified_fields["cin_number"] = cin_match.group(1)
        
        return {
            "success": True,
            "verified_fields": verified_fields,
            "extracted_text": text,
            "confidence": ocr_result["confidence"]
        }
    
    def verify_baccalaureat(self, image_path: str) -> Dict[str, Any]:
        """
        Verify Baccalauréat certificate and extract information including CNE
        
        Returns:
            Dictionary with verified fields
        """
        ocr_result = self.extract_text(image_path)
        
        if not ocr_result["success"]:
            return {
                "success": False,
                "verified_fields": {},
                **ocr_result
            }
        
        text = ocr_result["extracted_text"]
        
        # Extract common Baccalauréat fields
        verified_fields = {}
        
        # Check if it contains "baccalauréat" keyword
        if re.search(r'baccalaur[eé]at', text, re.IGNORECASE):
            verified_fields["is_bac"] = True
        
        # Try to extract name
        nom_match = re.search(r'(?:Nom|NOM)[\s:]+([A-ZÀ-Ÿ\s]+)', text, re.IGNORECASE)
        if nom_match:
            verified_fields["nom"] = nom_match.group(1).strip()
        
        # Try to extract prenom
        prenom_match = re.search(r'(?:Prénom|Prenom|PRENOM)[\s:]+([A-ZÀ-Ÿ\s]+)', text, re.IGNORECASE)
        if prenom_match:
            verified_fields["prenom"] = prenom_match.group(1).strip()
        
        # Try to extract CNE (various patterns)
        cne_patterns = [
            r'CNE[\s:]*([A-Z]\d{9})',  # CNE: K123456789
            r'Code[\s:]*([A-Z]\d{9})',  # Code: K123456789
            r'([A-Z]\d{9})',  # Just K123456789
        ]
        for pattern in cne_patterns:
            cne_match = re.search(pattern, text, re.IGNORECASE)
            if cne_match:
                verified_fields["cne"] = cne_match.group(1).upper()
                break
        
        # Try to extract year
        year_match = re.search(r'(19|20)\d{2}', text)
        if year_match:
            verified_fields["annee"] = year_match.group(0)
        
        # Try to extract mention
        mention_patterns = r'(Très bien|Bien|Assez bien|Passable)'
        mention_match = re.search(mention_patterns, text, re.IGNORECASE)
        if mention_match:
            verified_fields["mention"] = mention_match.group(1)
        
        return {
            "success": True,
            "verified_fields": verified_fields,
            "extracted_text": text,
            "confidence": ocr_result["confidence"]
        }
    
    def _calculate_similarity(self, str1: str, str2: str) -> float:
        """
        Calculate similarity between two strings (0-100)
        Uses simple character matching
        """
        if not str1 or not str2:
            return 0.0
        
        str1 = str1.lower().strip()
        str2 = str2.lower().strip()
        
        if str1 == str2:
            return 100.0
        
        # Check if one contains the other
        if str1 in str2 or str2 in str1:
            return 85.0
        
        # Simple character overlap
        set1 = set(str1)
        set2 = set(str2)
        intersection = set1.intersection(set2)
        union = set1.union(set2)
        
        if not union:
            return 0.0
        
        return (len(intersection) / len(union)) * 100
    
    def verify_candidature_data(
        self, 
        provided_data: Dict[str, str],
        cin_ocr: Dict[str, Any],
        bac_ocr: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Verify provided candidature data against OCR extracted data
        
        Args:
            provided_data: Data provided by candidate (nom, prenom, cne, mention)
            cin_ocr: OCR result from CIN
            bac_ocr: OCR result from Baccalauréat
            
        Returns:
            Verification report with match status for each field
        """
        cin_fields = cin_ocr.get("verified_fields", {})
        bac_fields = bac_ocr.get("verified_fields", {})
        
        verification_report = {
            "cin_verification": {},
            "bac_verification": {},
            "overall_status": "unknown"
        }
        
        # Verify CIN fields
        if "nom" in cin_fields:
            similarity = self._calculate_similarity(cin_fields["nom"], provided_data.get("nom", ""))
            verification_report["cin_verification"]["nom"] = {
                "match": similarity >= 80,
                "similarity": round(similarity, 2),
                "extracted": cin_fields["nom"],
                "provided": provided_data.get("nom", "")
            }
        
        if "prenom" in cin_fields:
            similarity = self._calculate_similarity(cin_fields["prenom"], provided_data.get("prenom", ""))
            verification_report["cin_verification"]["prenom"] = {
                "match": similarity >= 80,
                "similarity": round(similarity, 2),
                "extracted": cin_fields["prenom"],
                "provided": provided_data.get("prenom", "")
            }
        
        # Verify Baccalauréat fields
        if "nom" in bac_fields:
            similarity = self._calculate_similarity(bac_fields["nom"], provided_data.get("nom", ""))
            verification_report["bac_verification"]["nom"] = {
                "match": similarity >= 80,
                "similarity": round(similarity, 2),
                "extracted": bac_fields["nom"],
                "provided": provided_data.get("nom", "")
            }
        
        if "prenom" in bac_fields:
            similarity = self._calculate_similarity(bac_fields["prenom"], provided_data.get("prenom", ""))
            verification_report["bac_verification"]["prenom"] = {
                "match": similarity >= 80,
                "similarity": round(similarity, 2),
                "extracted": bac_fields["prenom"],
                "provided": provided_data.get("prenom", "")
            }
        
        if "cne" in bac_fields:
            similarity = self._calculate_similarity(bac_fields["cne"], provided_data.get("cne", ""))
            verification_report["bac_verification"]["cne"] = {
                "match": similarity >= 90,  # Higher threshold for CNE
                "similarity": round(similarity, 2),
                "extracted": bac_fields["cne"],
                "provided": provided_data.get("cne", "")
            }
        
        if "mention" in bac_fields:
            similarity = self._calculate_similarity(bac_fields["mention"], provided_data.get("mention", ""))
            verification_report["bac_verification"]["mention"] = {
                "match": similarity >= 80,
                "similarity": round(similarity, 2),
                "extracted": bac_fields["mention"],
                "provided": provided_data.get("mention", "")
            }
        
        # Determine overall status
        all_matches = []
        for field_verif in verification_report["cin_verification"].values():
            if isinstance(field_verif, dict) and "match" in field_verif:
                all_matches.append(field_verif["match"])
        
        for field_verif in verification_report["bac_verification"].values():
            if isinstance(field_verif, dict) and "match" in field_verif:
                all_matches.append(field_verif["match"])
        
        if not all_matches:
            verification_report["overall_status"] = "no_data"
        elif all(all_matches):
            verification_report["overall_status"] = "full_match"
        elif any(all_matches):
            verification_report["overall_status"] = "partial_match"
        else:
            verification_report["overall_status"] = "no_match"
        
        return verification_report
    
    # Alias for backward compatibility
    def verify_bac(self, image_path: str) -> Dict[str, Any]:
        """Alias for verify_baccalaureat"""
        return self.verify_baccalaureat(image_path)


# Singleton instance
ocr_service = OCRService()
