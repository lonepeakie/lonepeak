# Data Generation Scripts

This directory contains scripts for generating test data in Firebase for your LonePeak application.

## Main Script: `generate_data.py`

This is the primary script for adding and clearing test data in your Firebase database. The script can generate four types of dummy data:
- Estates (housing communities)
- Treasury transactions (incomes and expenses)
- Community notices
- Estate members

## Prerequisites

1. Make sure you have Python 3.x installed on your system
2. Install the Firebase Admin SDK:
   ```
   pip install firebase-admin
   ```
3. Set up Firebase credentials (see "Managing Credentials" section below)

## Managing Credentials Securely

The script requires Firebase Admin SDK credentials to authenticate with your Firebase project. To manage these credentials securely:

### Option 1: Environment Variables (Recommended)

You can provide credentials using environment variables:

```bash
# Set the path to your credentials file
export FIREBASE_CREDENTIALS_PATH="/path/to/your/credentials.json"

# OR include the entire JSON content in an environment variable
export FIREBASE_CREDENTIALS_JSON='{"type": "service_account", "project_id": "..."}'
```

### Option 2: Command Line Argument

Provide the path to your credentials file as a command-line argument:

```bash
python scripts/generate_data.py --estate_id YOUR_ESTATE_ID --credentials_path "/path/to/your/credentials.json"
```

### Option 3: Default Location

Place your credentials file named `lonepeak-48a17-firebase-adminsdk-fbsvc-67ece634c6.json` in the scripts directory.

### Security Best Practices

1. **Never commit credential files to version control**
   - The `.gitignore` file is configured to exclude Firebase credential files
   - Use `firebase-credentials-template.json` as a reference for creating your own credentials file

2. **For local development:**
   - Copy `firebase-credentials-template.json` to a new file with your actual credentials
   - Name it something that matches the pattern in `.gitignore` (e.g., `firebase-credentials.json`)

3. **For CI/CD pipelines:**
   - Use environment variables or secrets management

## How to Run the Script

The script can either create new estates or work with an existing estate ID.

### Creating Estates

To generate new estates (no estate ID required):

```bash
python scripts/generate_data.py --type estates --estates_count 5
```

This will create 5 estates with realistic Irish names and locations. The script will output the generated estate IDs that you can use for adding more data.

You can also automatically populate the first created estate with data:

```bash
python scripts/generate_data.py --type estates --estates_count 3 --count 20
```

This creates 3 estates and populates the first one with 20 members, 20 notices, and a set of transactions.

### Working with Existing Estates

For operations on existing estates, an estate ID is required:

```bash
python scripts/generate_data.py --estate_id YOUR_ESTATE_ID [OPTIONS]
```

### Common Usage Examples

1. **Add all types of dummy data** (transactions, notices, members):
   ```bash
   python scripts/generate_data.py --estate_id ypVMiIGnd7ZmL1MzAoQo
   ```

2. **Add only one type of data** (transactions, notices, or members):
   ```bash
   python scripts/generate_data.py --estate_id ypVMiIGnd7ZmL1MzAoQo --type transactions
   python scripts/generate_data.py --estate_id ypVMiIGnd7ZmL1MzAoQo --type notices
   python scripts/generate_data.py --estate_id ypVMiIGnd7ZmL1MzAoQo --type members
   ```

3. **Specify the number of items to generate** (for notices and members):
   ```bash
   python scripts/generate_data.py --estate_id ypVMiIGnd7ZmL1MzAoQo --type notices --count 15
   python scripts/generate_data.py --estate_id ypVMiIGnd7ZmL1MzAoQo --type members --count 30
   ```

4. **Clear data** instead of adding it:
   ```bash
   # Clear all data types
   python scripts/generate_data.py --estate_id ypVMiIGnd7ZmL1MzAoQo --action clear
   
   # Clear only one data type
   python scripts/generate_data.py --estate_id ypVMiIGnd7ZmL1MzAoQo --action clear --type transactions
   ```

## Command Line Options

The script accepts the following command-line arguments:

| Argument             | Description                                                                         | Required?            | Default                                  |
| -------------------- | ----------------------------------------------------------------------------------- | -------------------- | ---------------------------------------- |
| `--estate_id`        | The ID of the estate to add data to                                                 | For existing estates | N/A                                      |
| `--action`           | Action to perform: `add` or `clear`                                                 | No                   | `add`                                    |
| `--type`             | Type of data to generate: `all`, `estates`, `transactions`, `notices`, or `members` | No                   | `all`                                    |
| `--count`            | Number of items to generate                                                         | No                   | 25 for members, 10 for notices           |
| `--estates_count`    | Number of estates to generate when using `--type estates`                           | No                   | 3                                        |
| `--credentials_path` | Path to Firebase credentials JSON file                                              | No                   | Environment variable or default location |

## Data Generated

### Estates
- Housing communities with realistic names (e.g., "Oak Gardens", "Maple Heights")
- Irish locations with matching counties and cities
- Complete with addresses and descriptions

### Transactions
- Monthly HOA fees (income)
- Special assessments (income)
- Rental income
- Maintenance expenses
- Utility bills
- Insurance premiums
- Various other expenses

### Notices
- General community announcements
- Urgent maintenance alerts
- Event notifications
- Security alerts

### Members
- Estate residents with realistic names and emails
- Various roles (residents, admins, board members, maintenance staff)
- Optional attributes like phone numbers, unit numbers, and profile pictures

## Legacy Scripts

This directory also contains older scripts that might be used for specific purposes:
- `generate.py` - Original data generation script with various functions

When in doubt, use `generate_data.py` as it provides a unified interface for all data generation needs.