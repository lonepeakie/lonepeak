# Estate Management App

## Project Overview
This is a flutter project to create a simple estate management app. Below are the high level features of the app

* Splash Screen
* Authentication
    * Sign Up / Sign In
    * OAuth via Google/Apple
* Choose Path
    * Option 1: Join an Existing Estate
    * Option 2: Create a New Estate
* Create New Estate where the user can register their estate
    * Creater becomes the admin
* Join Existing Estate where the user can search for an estate and request to join
    * Request is sent to the estate admin for approval
* Estate Home Page
    * Documents (Estate Drive)
        * Create folders (e.g., Legal Docs, AGM Minutes, Insurance, Notices)
        * Upload PDFs, images, Word, Excel
        * Permission-based access (View/Edit/Upload/Delete)
        * Auto-backup to cloud
    * Notifications & Notices
        * Post community-wide announcements
        * Filter by category: General, Urgent, Financial, Social
        * Push and in-app notifications
    * Members List
        * Searchable list of all residents
        * Role tagging: Admin, Secretary, Treasurer, Resident
        * Contact info (controlled visibility)
    * Treasury (Financials)
        * Dashboard view:
            * Income / Expense Graphs
            * Account Balance Summary
            * Bank Statement Upload or Sync
            * Manual entry or automated integrations (via APIs where allowed)
            * Record Incomings:
                * Annual Fees
                * Donations
                * Rentals (community hall etc.)
            * Record Outgoings:
                * Maintenance
                * Gardening
                * Insurance
            * Attach receipts to each transaction
            * Export Reports (PDF/Excel)
            * Statements View:
                * Filter by Weekly / Monthly / Quarterly / Yearly
                * Auto-generate reports with download & print options

## Project Structure
```plaintext
lonepeak/
├── android
├── ios
├── lib
│   ├── main.dart
│   ├── data
│   │   ├── repositories
│   │   └── services
│   ├── domain
│   │   ├── models
│   │   └── features
│   ├── providers
│   ├── router
│   ├── scripts
│   ├── ui
│   │   ├── core
│   │   │   ├── themes
│   │   │   ├── widgets
│   │   ├── <folder for each screen>
│   │   │   ├── view_model
│   │   │   ├── widgets

## Coding Standards
* Use Dart's built-in formatting tools (dartfmt) to ensure consistent code style.
* Follow the Dart language guidelines for naming conventions, code structure, and documentation.
* Use meaningful names for variables, classes, and methods.
* Write clear and concise comments to explain complex logic or decisions. Do no write comments otherwise
