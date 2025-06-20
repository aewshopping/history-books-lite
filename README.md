# Automated Data Processing and Querying Pipeline

## What This Repository Does

This repository automatically fetches data from various online sources, cleans it up, stores it in simple text files (CSV and TSV), builds a searchable database from this data, and then runs predefined queries to generate useful reports.

The whole process is managed by GitHub Actions, which are like automated scripts that run specific tasks.

## How It Works: The Automated Workflows

There are three main automated workflows (GitHub Actions) you can run:

1.  **Fetch and Clean Raw Data (`process-multiple-remote-files.yml`)**
    *   **What it does:** This workflow downloads data from URLs listed in the `config.json` file.
    *   **Configuration (`config.json`):** This file tells the workflow where to get each data file, what to name the output file (e.g., `data/books.csv`), and if any specific columns of data should be removed or kept.
    *   **Processing:** It uses a tool called "Miller" to clean up the downloaded files (like removing unnecessary columns).
    *   **Output:** The cleaned data is saved as CSV (comma-separated values) or TSV (tab-separated values) files in the `data/` directory.
    *   **Committing:** Changes to these data files are automatically saved back to the repository.

2.  **Build the Database (`build-commit-sqlite-db.yml`)**
    *   **What it does:** This workflow takes all the clean CSV and TSV files from the `data/` directory and uses them to build (or update) a SQLite database file called `data.db`.
    *   **How it works:** It runs a script (`build-db.sh`) which uses "sqlite-utils" (a tool for working with SQLite databases) to:
        *   Create tables in the database for each data file.
        *   Make sure data is stored in the correct format (e.g., numbers as numbers, dates as dates).
        *   Set up full-text search for some data, making it easier to find things.
    *   **Output:** The main output is the `data.db` file.
    *   **Committing:** The updated `data.db` is automatically saved back to the repository.

3.  **Run SQL Queries (`run-sql-queries.yml`)**
    *   **What it does:** This workflow runs specific questions (written in SQL, the language for databases) against the `data.db` database.
    *   **SQL Queries:** The SQL questions are stored in files within the `sql-query/` directory (e.g., `latest100.sql` to get the 100 newest books).
    *   **Output:** The answers (results) from these queries are saved as JSON files (a common data format) in the `sql-query/result/` directory (e.g., `sql-query/result/latest100.json`).
    *   **Committing:** These JSON result files are automatically saved back to the repository.

## Key Files and Directories

*   **`.github/workflows/`**: Contains the YAML files that define the GitHub Actions workflows.
*   **`config.json`**: Configuration for the "Fetch and Clean Raw Data" workflow. Edit this file to change data sources or how they are initially processed.
*   **`data/`**: Stores the cleaned CSV and TSV data files. These are the input for the database.
*   **`data.db`**: The SQLite database file. This is created and updated by the "Build the Database" workflow.
*   **`build-db.sh`**: The shell script that details the steps for building `data.db`.
*   **`sql-query/`**: Contains the SQL query files.
*   **`sql-query/result/`**: Stores the JSON output from the "Run SQL Queries" workflow.
*   **`requirements.txt`**: Lists necessary Python tools (like `sqlite-utils`).

## Typical Order of Operations

While you can run these workflows independently, the typical order would be:

1.  Run **Fetch and Clean Raw Data** to get the latest data into the `data/` directory.
2.  Run **Build the Database** to update `data.db` with the new data.
3.  Run **Run SQL Queries** to generate new reports based on the updated database.

## How to Run the Workflows

1.  Go to the "Actions" tab of this repository on GitHub.
2.  In the left sidebar, you'll see the names of the workflows (e.g., "Fetch and Clean Raw Data").
3.  Click on the workflow you want to run.
4.  You'll see a "Run workflow" button or dropdown on the right. Click it and then confirm to start the workflow.

## Main Technologies Used

*   **GitHub Actions:** For automation.
*   **Miller:** For processing CSV/TSV files.
*   **sqlite-utils:** For creating and managing the SQLite database.
*   **jq:** For handling JSON data in the workflows.
*   **SQLite:** The database system used.

This README aims to provide a clear and simple guide to how this repository works.
