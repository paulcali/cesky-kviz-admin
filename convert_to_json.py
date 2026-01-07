#!/usr/bin/env python3
"""
Convert CSV question batches to JSON format for offline iOS app.
"""

import csv
import json
import uuid
import os
from pathlib import Path

# Category ID mapping
CATEGORY_IDS = {
    "historie": "historie",
    "zemepis": "zemepis", 
    "osobnosti": "osobnosti",
    "kultura": "kultura",
    "sport": "sport"
}

def normalize_category(name):
    """Normalize category name to ID."""
    import unicodedata
    normalized = unicodedata.normalize('NFD', name.lower())
    normalized = ''.join(c for c in normalized if unicodedata.category(c) != 'Mn')
    normalized = ''.join(c for c in normalized if c.isalpha())
    return normalized

def parse_csv_file(filepath):
    """Parse a single CSV file and return list of questions."""
    questions = []
    
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.reader(f, delimiter=';')
        header = next(reader, None)
        
        for row in reader:
            if len(row) < 8:
                continue
                
            category = normalize_category(row[0])
            question_text = row[1].strip()
            answers = [row[2].strip(), row[3].strip(), row[4].strip(), row[5].strip()]
            correct_letter = row[6].strip().upper()
            difficulty = int(row[7]) if row[7].strip().isdigit() else 1
            fun_fact = row[8].strip() if len(row) > 8 else ""
            
            # Determine correct answer index
            correct_index = ['A', 'B', 'C', 'D'].index(correct_letter) if correct_letter in ['A', 'B', 'C', 'D'] else 0
            
            question = {
                "id": str(uuid.uuid4()),
                "categoryId": category,
                "questionText": question_text,
                "difficulty": difficulty,
                "funFact": fun_fact if fun_fact else None,
                "answers": [
                    {"text": answers[i], "isCorrect": i == correct_index}
                    for i in range(4)
                ]
            }
            questions.append(question)
    
    return questions

def main():
    admin_panel_dir = Path("/Users/superman/Desktop/ceskykvizhra2/admin-panel")
    output_dir = Path("/Users/superman/Desktop/ceskykvizhra2/ceskykviz2/ceskykviz2/Resources/Questions")
    
    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Find all batch files
    batch_files = sorted(admin_panel_dir.glob("questions_batch*.csv"))
    
    all_questions = []
    
    for batch_file in batch_files:
        print(f"Processing {batch_file.name}...")
        questions = parse_csv_file(batch_file)
        all_questions.extend(questions)
        print(f"  -> {len(questions)} questions")
    
    print(f"\nTotal questions: {len(all_questions)}")
    
    # Count by category
    categories = {}
    for q in all_questions:
        cat = q["categoryId"]
        categories[cat] = categories.get(cat, 0) + 1
    
    print("\nBy category:")
    for cat, count in sorted(categories.items()):
        print(f"  {cat}: {count}")
    
    # Count by difficulty
    difficulties = {}
    for q in all_questions:
        diff = q["difficulty"]
        difficulties[diff] = difficulties.get(diff, 0) + 1
    
    print("\nBy difficulty:")
    for diff, count in sorted(difficulties.items()):
        print(f"  {diff}: {count}")
    
    # Create output JSON
    output = {
        "packId": "free_base",
        "packName": "Základní balíček",
        "isPremium": False,
        "questions": all_questions
    }
    
    output_file = output_dir / "free_questions.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ Created {output_file}")
    print(f"   File size: {output_file.stat().st_size / 1024:.1f} KB")

if __name__ == "__main__":
    main()
