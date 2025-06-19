# Data Processing Repository

## Repository Overview

This repository is designed to automatically fetch, process, and store various data files from remote sources. It uses a GitHub Actions workflow to manage these tasks, with the processed files being saved into the `data/` directory.

## How it Works

The core of this repository is a GitHub Actions workflow defined in `.github/workflows/process-multiple-remote-files.yml`, which is configured through the `config.json` file.

### GitHub Actions Workflow (`.github/workflows/process-multiple-remote-files.yml`)

The workflow performs the following steps:

1.  **Manual Trigger:** The workflow is initiated manually through the GitHub Actions tab in the repository (`on: workflow_dispatch`).
2.  **Checkout Repository:** It first checks out the current state of the repository.
3.  **Install Dependencies:**
    *   **Miller:** A powerful command-line tool for querying, shaping, and processing structured data formats like CSV, TSV, and JSON.
    *   **jq:** A lightweight and flexible command-line JSON processor, used here to parse the `config.json` file.
4.  **Process Files from `config.json`:** This is the main operational step. The workflow reads `config.json` and iterates through each entry defined within it.
    *   For each entry, it extracts details such as the file URL, desired output filename, columns to be deleted, and the file format.
    *   **Per-File Operations:**
        1.  **Download:** The remote file is downloaded from the specified `url` to a temporary location.
        2.  **Process with Miller:** Miller (`mlr`) is used to process the downloaded file. The primary operation performed is deleting specified columns (defined in `columns_to_delete`). If no columns are specified for deletion, the original file is copied as is. The `miller_format` flag (e.g., `--csv`, `--tsv`) ensures correct handling of the file type.
        3.  **Save Output:** The processed data is saved to the `data/` directory with the specified `output_filename`.
5.  **Commit and Push Changes:**
    *   After all files in `config.json` have been processed, the workflow stages all new or modified `*.csv` and `*.tsv` files (primarily those in the `data/` directory).
    *   It then commits these changes with a timestamp as the commit message.
    *   Finally, it pulls the latest changes from the remote repository (with rebase) and pushes the new commit.

### Configuration File (`config.json`)

The `config.json` file is a JSON array that acts as a manifest, defining each file to be fetched and processed. Each object in the array represents one file and has the following structure:

*   `url` (string): The direct URL to the raw remote data file.
*   `output_filename` (string): The desired path and filename for the processed file, which will be stored in the `data/` directory (e.g., `data/books.csv`).
*   `columns_to_delete` (array of strings): A list of column names that should be removed from the data file. If no columns need to be deleted, this should be an empty array `[]`.
*   `miller_format` (string): A flag indicating the format of the file for Miller processing (e.g., `"--csv"` for CSV files, `"--tsv"` for TSV files).

**Example Entry:**

```json
{
  "url": "https://raw.githubusercontent.com/aewshopping/history_books/refs/heads/main/data_csv/popular-history-books.csv",
  "output_filename": "data/books.csv",
  "columns_to_delete": ["tags", "tags_bespoke"],
  "miller_format": "--csv"
}
```

In this example:
*   The workflow will download `popular-history-books.csv` from the specified URL.
*   It will remove the "tags" and "tags_bespoke" columns.
*   The resulting CSV file will be saved as `data/books.csv`.

### The `data/` Directory

*   This directory contains the final output of the GitHub Actions workflow.
*   **Important:** The files in this directory are automatically generated and updated by the workflow. Any manual changes made directly to files within the `data/` directory are likely to be overwritten the next time the workflow runs.

## Key Technologies

*   **GitHub Actions:** For orchestrating the automated fetching, processing, and committing of data.
*   **Miller:** For command-line data manipulation of structured text files.
*   **jq:** For parsing the `config.json` file within the shell script environment of the workflow.

## How to Use/Run

1.  **Triggering the Workflow:**
    *   Navigate to the "Actions" tab of this repository on GitHub.
    *   Under "Workflows", find "Process Multiple Remote Files with Miller".
    *   Click the "Run workflow" button. This will manually trigger the workflow.

2.  **Modifying Processing Logic:**
    *   **To add a new file, remove a file, or change which columns are deleted for an existing file:** Edit the `config.json` file.
        *   Add a new JSON object to the array for a new file.
        *   Remove an existing JSON object to stop processing a file.
        *   Modify the `url`, `output_filename`, `columns_to_delete`, or `miller_format` fields for an existing file as needed.
    *   Commit and push your changes to `config.json` to the main branch. The next time the workflow runs, it will use the updated configuration.

## Note on `data/` Directory

As mentioned previously, the `data/` directory is strictly for output files generated by the automated workflow. Please do not commit files directly to this directory, as they will be overwritten. All data processing should be managed by updating `config.json` and letting the GitHub Action handle the file generation.
