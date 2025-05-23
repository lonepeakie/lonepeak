import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta
import random
import argparse
import os
import json

# Parse command-line arguments
parser = argparse.ArgumentParser(description='Add or clear dummy data in Firebase')
parser.add_argument('--estate_id', type=str, help='The ID of the estate to add data to')
parser.add_argument('--action', type=str, choices=['add', 'clear'], default='add', help='Action to perform (add or clear data)')
parser.add_argument('--type', type=str, choices=['all', 'transactions', 'notices', 'members', 'estates'], default='all', 
                    help='Type of data to generate (default: all)')
parser.add_argument('--count', type=int, default=0, 
                    help='Number of items to generate (default: 25 for members, 10 for notices, all transaction types)')
parser.add_argument('--estates_count', type=int, default=3, 
                    help='Number of estates to generate when generating estates (default: 3)')
parser.add_argument('--credentials_path', type=str, 
                    help='Path to Firebase credentials JSON file (alternatively, use FIREBASE_CREDENTIALS_PATH env variable)')
args = parser.parse_args()

# Initialize Firebase
try:
    # Try to get the default app if already initialized
    default_app = firebase_admin.get_app()
except ValueError:
    # If not initialized, get credentials from environment or args
    cred_path = args.credentials_path or os.environ.get('FIREBASE_CREDENTIALS_PATH')
    
    if not cred_path:
        # Try the default location as a fallback
        cred_path = "lonepeak-194b2-firebase-adminsdk-fbsvc-77fe11d61f.json"
        if not os.path.exists(cred_path):
            # If trying with environment variables
            cred_json = os.environ.get('FIREBASE_CREDENTIALS_JSON')
            if cred_json:
                # Create a temporary credentials file from the environment variable
                try:
                    cred_data = json.loads(cred_json)
                    cred = credentials.Certificate(cred_data)
                    firebase_admin.initialize_app(cred)
                    print("Initialized Firebase using credentials from environment variable")
                except json.JSONDecodeError:
                    print("ERROR: FIREBASE_CREDENTIALS_JSON environment variable contains invalid JSON")
                    exit(1)
                except Exception as e:
                    print(f"ERROR: Failed to initialize Firebase with credentials from environment: {e}")
                    exit(1)
            else:
                print("ERROR: No Firebase credentials provided. Please provide credentials using one of these methods:")
                print("  1. --credentials_path argument")
                print("  2. FIREBASE_CREDENTIALS_PATH environment variable pointing to a JSON file")
                print("  3. FIREBASE_CREDENTIALS_JSON environment variable containing the JSON content")
                print("  4. Default credentials file in the script directory")
                exit(1)
        else:
            print(f"Using default credentials file: {cred_path}")
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
    else:
        print(f"Using credentials file: {cred_path}")
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)

# Firestore client
db = firestore.client()

# Estate ID from command line
estate_id = args.estate_id

###############################################
# MEMBERS
###############################################

# Lists for generating random names
FIRST_NAMES = [
    "John", "Jane", "Michael", "Emily", "David", "Sarah", "Christopher", "Laura", 
    "Daniel", "Olivia", "William", "Sophia", "James", "Emma", "Alexander", "Megan", 
    "Robert", "Elizabeth", "Thomas", "Jennifer", "Steven", "Amanda", "Richard", "Jessica",
    "Charles", "Ashley", "Joseph", "Rebecca", "Matthew", "Nicole", "Anthony", "Stephanie",
    "Mark", "Hannah", "Paul", "Samantha", "George", "Catherine", "Kenneth", "Maria",
    "Andrew", "Rachel", "Edward", "Kelly", "Brian", "Lauren", "Kevin", "Lisa"
]

LAST_NAMES = [
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Miller", "Davis", "Garcia", 
    "Rodriguez", "Wilson", "Martinez", "Anderson", "Taylor", "Thomas", "Hernandez", 
    "Moore", "Martin", "Jackson", "Thompson", "White", "Lopez", "Lee", "Gonzalez", 
    "Harris", "Clark", "Lewis", "Robinson", "Walker", "Perez", "Hall", "Young", 
    "Allen", "Sanchez", "Wright", "King", "Scott", "Green", "Baker", "Adams", 
    "Nelson", "Hill", "Ramirez", "Campbell", "Mitchell", "Roberts", "Carter", "Phillips"
]

ROLES = ["resident", "admin", "board_member", "maintenance"]
ROLE_WEIGHTS = [0.85, 0.05, 0.05, 0.05]  # 85% residents, 5% each of other roles

def clear_members():
    """Clear all members for the specified estate"""
    try:
        collection_path = f"estates/{estate_id}/members"
        docs = db.collection(collection_path).stream()
        
        count = 0
        for doc in docs:
            doc.reference.delete()
            count += 1
        
        print(f"Successfully cleared {count} members from estate {estate_id}!")
        return count
    except Exception as e:
        print(f"Error clearing members: {e}")
        return 0

def generate_dummy_members(count=25):
    """Generate a list of dummy members"""
    members = []
    used_emails = set()  # Track used emails to avoid duplicates
    
    for _ in range(count):
        # Generate a random name
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        display_name = f"{first_name} {last_name}"
        
        # Generate a unique email
        email_base = f"{first_name.lower()}.{last_name.lower()}"
        email = f"{email_base}@example.com"
        
        # Ensure email is unique; if not, add a number
        if email in used_emails:
            email = f"{email_base}{random.randint(1, 999)}@example.com"
        used_emails.add(email)
        
        # Assign a role based on weighted probabilities
        role = random.choices(ROLES, weights=ROLE_WEIGHTS)[0]
        
        # Create the member
        member = {
            "email": email,
            "displayName": display_name,
            "role": role,
            "status": "active",
            "metadata": {
                "createdAt": datetime.now(),
                "updatedAt": datetime.now()
            }
        }
        
        # Add optional fields for some members
        if random.random() > 0.7:  # 30% chance to have a phone number
            member["phoneNumber"] = f"+1{random.randint(2000000000, 9999999999)}"
        
        if random.random() > 0.5:  # 50% chance to have a unit number
            member["unitNumber"] = f"{random.randint(1, 500)}"
        
        if random.random() > 0.7:  # 30% chance to have a profile picture URL
            member["photoURL"] = f"https://randomuser.me/api/portraits/{'men' if random.random() > 0.5 else 'women'}/{random.randint(1, 99)}.jpg"
        
        members.append(member)
    
    return members

def add_members(count=25):
    """Add dummy members to Firestore"""
    try:
        collection_path = f"estates/{estate_id}/members"
        members = generate_dummy_members(count)
        
        count = 0
        for member in members:
            # Use email as document ID for easy lookup
            db.collection(collection_path).document(member["email"]).set(member)
            count += 1
        
        print(f"Successfully added {count} dummy members to estate {estate_id}!")
        return count
    except Exception as e:
        print(f"Error adding members: {e}")
        return 0

###############################################
# NOTICES
###############################################

# Notice templates
NOTICE_TEMPLATES = [
    {
        "title": "General Meeting",
        "message": "A general meeting will be held on Friday to discuss upcoming community projects, address resident concerns, and provide updates on estate management. Your participation is highly encouraged to ensure your voice is heard.",
        "type": "general",
    },
    {
        "title": "Urgent Maintenance",
        "message": "Please be informed that the water supply will be interrupted tomorrow due to urgent maintenance work on the main pipeline. We apologize for the inconvenience and appreciate your understanding as we work to resolve the issue promptly.",
        "type": "urgent",
    },
    {
        "title": "Community Event",
        "message": "Join us for a community BBQ this Saturday at the central park area. This is a great opportunity to meet your neighbors, enjoy delicious food, and participate in fun activities for all ages. We look forward to seeing you there!",
        "type": "event",
    },
    {
        "title": "Security Alert",
        "message": "We urge all residents to ensure that all doors and windows are securely locked at night following recent reports of suspicious activity in the area. Your cooperation is essential in maintaining the safety and security of our community.",
        "type": "urgent",
    },
    {
        "title": "Holiday Notice",
        "message": "Please note that the estate office will be closed on all public holidays. For any urgent matters during this time, you may contact the emergency hotline. We wish everyone a safe and enjoyable holiday season.",
        "type": "general",
    },
    {
        "title": "Fire Drill",
        "message": "A fire drill is scheduled for next Monday to ensure all residents are familiar with evacuation procedures. Please take this drill seriously and follow the instructions provided by the safety team. Your cooperation is greatly appreciated.",
        "type": "event",
    },
    {
        "title": "Parking Update",
        "message": "New parking rules will be effective from next week to improve the availability of parking spaces for all residents. Please review the updated guidelines and ensure compliance to avoid any inconvenience.",
        "type": "general",
    },
    {
        "title": "Pool Maintenance",
        "message": "The community pool will be closed for maintenance from Monday to Wednesday next week. We are conducting necessary repairs and cleaning to ensure a safe and enjoyable swimming experience for all residents.",
        "type": "general",
    },
    {
        "title": "Annual HOA Meeting",
        "message": "The annual HOA meeting is scheduled for June 15th at 7 PM in the community center. We will be discussing the budget for the next fiscal year and electing new board members. Your attendance is important.",
        "type": "general",
    },
    {
        "title": "Power Outage",
        "message": "There will be a scheduled power outage on Saturday from 1 PM to 5 PM due to electrical grid maintenance by the utility company. Please plan accordingly and ensure sensitive electronic equipment is properly shut down before the outage.",
        "type": "urgent",
    },
    {
        "title": "Neighborhood Watch",
        "message": "We are looking for volunteers to join our neighborhood watch program. If you are interested in helping keep our community safe, please attend the information session on Thursday at 8 PM in the community center.",
        "type": "event",
    },
    {
        "title": "Gardening Competition",
        "message": "The annual gardening competition will begin next month. Residents are encouraged to start preparing their gardens. Prizes will be awarded for most beautiful flower garden, best vegetable garden, and most creative landscaping.",
        "type": "event",
    },
    {
        "title": "Pest Control",
        "message": "Pest control services will be conducted in common areas on Tuesday starting at 9 AM. The treatment is pet-friendly, but we recommend keeping pets indoors during the application process as a precaution.",
        "type": "general",
    },
    {
        "title": "New Amenities",
        "message": "We are pleased to announce that the new fitness center is now open and available to all residents. The facility is equipped with state-of-the-art exercise equipment and is open daily from 5 AM to 11 PM.",
        "type": "general",
    },
    {
        "title": "Guest Parking Reminder",
        "message": "Please remember that guest parking spaces are limited to 48-hour use. Guests staying longer must register with the management office to avoid having their vehicles towed at the owner's expense.",
        "type": "general",
    },
]

def clear_notices():
    """Clear all notices for the specified estate"""
    try:
        collection_path = f"estates/{estate_id}/notices"
        docs = db.collection(collection_path).stream()
        
        count = 0
        for doc in docs:
            doc.reference.delete()
            count += 1
        
        print(f"Successfully cleared {count} notices from estate {estate_id}!")
        return count
    except Exception as e:
        print(f"Error clearing notices: {e}")
        return 0

def generate_dummy_notices(count=10):
    """Generate a list of dummy notices"""
    notices = []
    now = datetime.now()
    
    # Use all templates or subset based on count
    templates_to_use = NOTICE_TEMPLATES.copy()
    if count < len(templates_to_use):
        templates_to_use = random.sample(templates_to_use, count)
    else:
        # If we need more than we have templates, repeat some with slight variations
        while len(templates_to_use) < count:
            template = random.choice(NOTICE_TEMPLATES)
            templates_to_use.append(template)
    
    # Generate notices from templates
    for template in templates_to_use[:count]:
        # Generate a random timestamp within the last 30 days
        random_days = random.randint(0, 30)
        random_seconds = random.randint(0, 86400)  # Number of seconds in a day
        random_time = now - timedelta(days=random_days, seconds=random_seconds)
        
        # Create a notice from the template
        notice = template.copy()
        notice["metadata"] = {
            "createdAt": random_time,
            "updatedAt": random_time
        }
        
        notices.append(notice)
    
    return notices

def add_notices(count=10):
    """Add dummy notices to Firestore"""
    try:
        collection_path = f"estates/{estate_id}/notices"
        notices = generate_dummy_notices(count)
        
        count = 0
        for notice in notices:
            db.collection(collection_path).add(notice)
            count += 1
        
        print(f"Successfully added {count} dummy notices to estate {estate_id}!")
        return count
    except Exception as e:
        print(f"Error adding notices: {e}")
        return 0

###############################################
# TRANSACTIONS
###############################################

# Transaction type enum values (matching your Dart enum)
TRANSACTION_TYPES = [
    "TransactionType.maintenance",
    "TransactionType.insurance",
    "TransactionType.utilities",
    "TransactionType.rental",
    "TransactionType.fees",
    "TransactionType.other"
]

def clear_transactions():
    """Clear all transactions for the specified estate"""
    try:
        collection_path = f"estates/{estate_id}/transactions"
        docs = db.collection(collection_path).stream()
        
        count = 0
        for doc in docs:
            doc.reference.delete()
            count += 1
        
        print(f"Successfully cleared {count} transactions from estate {estate_id}!")
        return count
    except Exception as e:
        print(f"Error clearing transactions: {e}")
        return 0

def generate_dummy_transactions():
    """Generate a list of dummy treasury transactions"""
    transactions = []
    now = datetime.now()
    
    # Helper function to safely calculate past dates
    def get_past_date(current_date, months_ago, day):
        year = current_date.year
        month = current_date.month - months_ago
        
        # Adjust year and month if month becomes invalid
        while month < 1:
            month += 12
            year -= 1
        while month > 12:
            month -= 12
            year += 1
            
        # Make sure day is valid for the month
        max_day = 28  # Safe default for all months
        if month in [1, 3, 5, 7, 8, 10, 12]:
            max_day = 31
        elif month in [4, 6, 9, 11]:
            max_day = 30
        elif month == 2:
            # Simple leap year check
            max_day = 29 if (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0) else 28
            
        day = min(day, max_day)
        
        return datetime(year, month, day)
    
    # Add some income transactions
    
    # Monthly HOA fee income (for the past 5 months)
    for i in range(5):
        date = get_past_date(now, i, 15)
        transactions.append({
            "title": "Monthly HOA Fees",
            "type": "TransactionType.fees",
            "amount": 5000.0,
            "date": date,
            "description": "Monthly HOA fees collection from 25 units",
            "isIncome": True,
            "metadata": {
                "createdAt": firestore.SERVER_TIMESTAMP,
                "updatedAt": firestore.SERVER_TIMESTAMP
            }
        })
    
    # Special assessment
    transactions.append({
        "title": "Special Assessment",
        "type": "TransactionType.fees",
        "amount": 12500.0,
        "date": get_past_date(now, 2, 10),
        "description": "Special assessment for roof repairs",
        "isIncome": True,
        "metadata": {
            "createdAt": firestore.SERVER_TIMESTAMP,
            "updatedAt": firestore.SERVER_TIMESTAMP
        }
    })
    
    # Rental income from common areas
    transactions.append({
        "title": "Clubhouse Rental",
        "type": "TransactionType.rental",
        "amount": 750.0,
        "date": get_past_date(now, 1, 5),
        "description": "Clubhouse rental for private event",
        "isIncome": True,
        "metadata": {
            "createdAt": firestore.SERVER_TIMESTAMP,
            "updatedAt": firestore.SERVER_TIMESTAMP
        }
    })
    
    # Add expense transactions
    
    # Maintenance expenses
    maintenance_items = [
        {"title": "Pool Maintenance", "amount": 450.0, "months_ago": 1},
        {"title": "Landscaping", "amount": 1200.0, "months_ago": 0},
        {"title": "Elevator Repair", "amount": 2750.0, "months_ago": 3},
        {"title": "Snow Removal", "amount": 800.0, "months_ago": 2},
        {"title": "Plumbing Repairs", "amount": 1150.0, "months_ago": 1},
    ]
    
    for item in maintenance_items:
        day = min(max(1, now.day - 5), 28)  # Just offset a few days from current date
        transactions.append({
            "title": item["title"],
            "type": "TransactionType.maintenance",
            "amount": item["amount"],
            "date": get_past_date(now, item["months_ago"], day),
            "description": f"Regular maintenance: {item['title']}",
            "isIncome": False,
            "metadata": {
                "createdAt": firestore.SERVER_TIMESTAMP,
                "updatedAt": firestore.SERVER_TIMESTAMP
            }
        })
    
    # Utilities expenses
    utilities_items = [
        {"title": "Electricity", "amount": 950.0, "months_ago": 0},
        {"title": "Water", "amount": 750.0, "months_ago": 0},
        {"title": "Gas", "amount": 380.0, "months_ago": 1},
        {"title": "Internet", "amount": 120.0, "months_ago": 1},
        {"title": "Electricity", "amount": 890.0, "months_ago": 2},
        {"title": "Water", "amount": 820.0, "months_ago": 2},
    ]
    
    for item in utilities_items:
        transactions.append({
            "title": item["title"],
            "type": "TransactionType.utilities",
            "amount": item["amount"],
            "date": get_past_date(now, item["months_ago"], 5),
            "description": f"{item['title']} bill for common areas",
            "isIncome": False,
            "metadata": {
                "createdAt": firestore.SERVER_TIMESTAMP,
                "updatedAt": firestore.SERVER_TIMESTAMP
            }
        })
    
    # Insurance
    transactions.append({
        "title": "Property Insurance",
        "type": "TransactionType.insurance",
        "amount": 3500.0,
        "date": get_past_date(now, 3, 15),
        "description": "Quarterly property insurance premium",
        "isIncome": False,
        "metadata": {
            "createdAt": firestore.SERVER_TIMESTAMP,
            "updatedAt": firestore.SERVER_TIMESTAMP
        }
    })
    
    # Other expenses
    other_items = [
        {"title": "Legal Fees", "amount": 2000.0, "months_ago": 2, "day": 12},
        {"title": "Office Supplies", "amount": 150.0, "months_ago": 1, "day": 8},
        {"title": "Management Fee", "amount": 1800.0, "months_ago": 0, "day": 1},
        {"title": "Security System", "amount": 250.0, "months_ago": 3, "day": 22},
    ]
    
    for item in other_items:
        transactions.append({
            "title": item["title"],
            "type": "TransactionType.other",
            "amount": item["amount"],
            "date": get_past_date(now, item["months_ago"], item["day"]),
            "description": f"{item['title']} expense",
            "isIncome": False,
            "metadata": {
                "createdAt": firestore.SERVER_TIMESTAMP,
                "updatedAt": firestore.SERVER_TIMESTAMP
            }
        })
    
    return transactions

def add_transactions():
    """Add dummy transactions to Firestore"""
    try:
        collection_path = f"estates/{estate_id}/transactions"
        transactions = generate_dummy_transactions()
        
        count = 0
        for transaction in transactions:
            db.collection(collection_path).add(transaction)
            count += 1
        
        print(f"Successfully added {count} dummy transactions to estate {estate_id}!")
        return count
    except Exception as e:
        print(f"Error adding transactions: {e}")
        return 0

###############################################
# ESTATES
###############################################

# Lists for generating realistic estate data
ESTATE_NAME_PREFIXES = ["Oak", "Maple", "Pine", "Cedar", "Willow", "Birch", "Aspen", "Elm", "Spruce", "Cypress", 
                        "Royal", "Grand", "Highland", "Green", "Blue", "Golden", "Silver", "Crystal", "Emerald", "Ruby"]
ESTATE_NAME_SUFFIXES = ["Park", "Gardens", "Heights", "Hills", "Meadows", "Estates", "Terrace", "Village", "Plaza", 
                        "Commons", "Square", "Court", "Place", "View", "Ridge", "Grove", "Manor", "Woods", "Valley"]

COUNTIES = ["Dublin", "Cork", "Galway", "Mayo", "Kerry", "Waterford", "Limerick", "Clare", "Tipperary", "Wexford", 
           "Wicklow", "Kildare", "Meath", "Louth", "Donegal", "Sligo", "Roscommon", "Westmeath", "Offaly", "Kilkenny"]

CITY_BY_COUNTY = {
    "Dublin": ["Dublin", "Swords", "Tallaght", "Dún Laoghaire", "Blanchardstown"],
    "Cork": ["Cork", "Carrigaline", "Cobh", "Midleton", "Mallow"],
    "Galway": ["Galway", "Tuam", "Ballinasloe", "Loughrea", "Oranmore"],
    "Mayo": ["Castlebar", "Ballina", "Westport", "Claremorris", "Ballinrobe"],
    "Kerry": ["Tralee", "Killarney", "Dingle", "Listowel", "Kenmare"],
    "Waterford": ["Waterford", "Dungarvan", "Tramore", "Lismore", "Portlaw"],
    "Limerick": ["Limerick", "Newcastle West", "Abbeyfeale", "Kilmallock", "Adare"],
    "Clare": ["Ennis", "Shannon", "Kilrush", "Sixmilebridge", "Newmarket-on-Fergus"],
    "Tipperary": ["Clonmel", "Nenagh", "Thurles", "Carrick-on-Suir", "Roscrea"],
    "Wexford": ["Wexford", "Enniscorthy", "Gorey", "New Ross", "Bunclody"],
    "Wicklow": ["Bray", "Greystones", "Arklow", "Wicklow", "Blessington"],
    "Kildare": ["Naas", "Newbridge", "Leixlip", "Maynooth", "Athy"],
    "Meath": ["Navan", "Ashbourne", "Trim", "Laytown", "Ratoath"],
    "Louth": ["Drogheda", "Dundalk", "Ardee", "Termonfeckin", "Clogherhead"],
    "Donegal": ["Letterkenny", "Buncrana", "Ballybofey", "Donegal", "Bundoran"],
    "Sligo": ["Sligo", "Strandhill", "Ballymote", "Tubbercurry", "Enniscrone"],
    "Roscommon": ["Roscommon", "Boyle", "Castlerea", "Ballaghaderreen", "Strokestown"],
    "Westmeath": ["Athlone", "Mullingar", "Moate", "Kilbeggan", "Castlepollard"],
    "Offaly": ["Tullamore", "Birr", "Edenderry", "Clara", "Banagher"],
    "Kilkenny": ["Kilkenny", "Callan", "Castlecomer", "Thomastown", "Graiguenamanagh"]
}

ADDRESSES = ["Park Avenue", "Main Street", "Oak Road", "Maple Drive", "Pine Lane", 
             "Willow Way", "Cedar Street", "Birch Road", "Aspen Drive", "Elm Street",
             "Garden Avenue", "Hill Road", "Meadow Lane", "River Drive", "Lake Road",
             "Forest Avenue", "Valley Lane", "Mountain View", "Sunset Drive", "Sunrise Lane"]

def generate_dummy_estates(count=3):
    """Generate a list of dummy estates"""
    estates = []
    
    for _ in range(count):
        # Generate a unique estate name
        prefix = random.choice(ESTATE_NAME_PREFIXES)
        suffix = random.choice(ESTATE_NAME_SUFFIXES)
        name = f"{prefix} {suffix}"
        
        # Generate location
        county = random.choice(COUNTIES)
        city = random.choice(CITY_BY_COUNTY[county])
        address = f"{random.randint(1, 100)} {random.choice(ADDRESSES)}"
        
        # Generate optional description
        descriptions = [
            f"A beautiful {suffix.lower()} community in the heart of {city}.",
            f"Modern living in the prestigious {name} development.",
            f"Experience luxury community living at {name}.",
            f"A peaceful {suffix.lower()} retreat in {county}.",
            f"Family-friendly community in the scenic area of {city}."
        ]
        
        estate = {
            "name": name,
            "description": random.choice(descriptions),
            "address": address,
            "city": city,
            "county": county,
            "metadata": {
                "createdAt": datetime.now(),
                "updatedAt": datetime.now()
            }
        }
        
        # Add optional logo URL for some estates
        if random.random() > 0.6:  # 40% chance to have a logo
            estate["logoUrl"] = f"https://example.com/logos/{prefix.lower()}_{suffix.lower()}.png"
        
        estates.append(estate)
    
    return estates

def add_estates(count=3):
    """Add dummy estates to Firestore and optionally populate them with data"""
    try:
        collection_path = "estates"
        estates = generate_dummy_estates(count)
        
        created_estates = []
        for estate in estates:
            # Add the estate
            doc_ref = db.collection(collection_path).add(estate)
            estate_id = doc_ref[1].id
            print(f"Created estate: {estate['name']} with ID: {estate_id}")
            created_estates.append((estate_id, estate['name']))
        
        print(f"Successfully added {len(created_estates)} dummy estates!")
        
        # Print summary information for the user
        print("\nCreated estates:")
        for idx, (id, name) in enumerate(created_estates):
            print(f"{idx+1}. {name} (ID: {id})")
        
        print("\nTo add data to these estates, use the --estate_id parameter:")
        for idx, (id, name) in enumerate(created_estates):
            print(f"python generate_data.py --estate_id={id} --type=all  # Adds data to {name}")
            
        return created_estates
    except Exception as e:
        print(f"Error adding estates: {e}")
        return []

def setup_estate(estate_id_param, members_count=25, notices_count=10):
    """Set up a complete estate with members, notices and transactions"""
    # We need to use the global variable to communicate with other functions
    global estate_id
    # Now assign the parameter value to the global variable
    estate_id = estate_id_param
    
    add_members(members_count)
    add_notices(notices_count)
    add_transactions()
    
    print(f"Estate {estate_id} has been successfully set up with data!")

###############################################
# MAIN EXECUTION
###############################################

if __name__ == "__main__":
    # Handle the estates generation case separately since it doesn't require an estate_id
    if args.type == "estates":
        count = args.estates_count if args.estates_count > 0 else 3
        created_estates = add_estates(count)
        if len(created_estates) > 0 and args.count > 0:
            # If estates were created and user specified a count for other data, generate data for the first estate
            first_estate_id = created_estates[0][0]
            print(f"\nSetting up the first estate ({created_estates[0][1]}) with sample data...")
            setup_estate(first_estate_id, args.count, args.count)
        exit(0)
    
    # For all other operations, an estate_id is required
    if not estate_id:
        print("Error: --estate_id is required for operations other than creating estates")
        print("Use: python generate_data.py --type=estates --estates_count=3 to create new estates")
        exit(1)
        
    print(f"Working with estate ID: {estate_id}")
    
    if args.action == "clear":
        if args.type == "all" or args.type == "transactions":
            clear_transactions()
        if args.type == "all" or args.type == "notices":
            clear_notices()
        if args.type == "all" or args.type == "members":
            clear_members()
    else:  # add
        if args.type == "all":
            # For "all", set up the estate with appropriate counts
            count = args.count if args.count > 0 else 25
            setup_estate(estate_id, count, min(count, 10))
        else:
            if args.type == "transactions":
                add_transactions()
            if args.type == "notices":
                count = args.count if args.count > 0 else 10
                add_notices(count)
            if args.type == "members":
                count = args.count if args.count > 0 else 25
                add_members(count)