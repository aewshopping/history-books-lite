# Automated Data Processing and Querying Pipeline

## What This Repository Does

This repository defines an automated pipeline to:
1.  Fetch raw data from various online sources.
2.  Clean and process this data into standardized CSV and TSV files, stored on the `main` branch.
3.  Build a SQLite database (`data.db`) from these files. This database is stored on a separate orphan branch named `data-output` to prevent repository bloat.
4.  Run predefined SQL queries against the database and save the results as JSON files, also on the `data-output` branch.

The entire process is managed by a series of GitHub Actions workflows. A key feature is the use of the `data-output` orphan branch for all generated data products (`data.db` and query results), ensuring the `main` branch remains lightweight and focused on code and configuration.

## How It Works: The Automated Workflows

There are four main automated workflows (GitHub Actions) that constitute the pipeline:

1.  **Process Multiple Remote Files with Miller (`process-multiple-remote-files.yml`)**
    *   **Trigger:** Manual (workflow_dispatch). *Future: Intended to be triggered by a remote webhook when source CSVs are updated.*
    *   **What it does:** Downloads data from URLs specified in `config.json`.
    *   **Configuration (`config.json`):** Located on the `main` branch, this file dictates data sources, output filenames (e.g., `data/books.csv`), and any column manipulations (delete/select).
    *   **Processing:** Uses "Miller" to clean and transform the downloaded data.
    *   **Output:** Cleaned data is saved as CSV or TSV files in the `data/` directory.
    *   **Committing:** Changes to these data files are committed to the `main` branch.

2.  **Recreate Orphan Data Output Branch (`create-orphan-data-output-branch.yml`)**
    *   **Trigger:** Manual (workflow_dispatch).
    *   **What it does:** This crucial workflow prepares the `data-output` branch. It first deletes the existing `data-output` branch (if present, both locally and remotely) and then creates a new, empty orphan branch with the same name.
    *   **Purpose:** Using an orphan branch for data outputs (`data.db`, query results) prevents the main repository history from becoming excessively large due to frequent updates of potentially large data files. Each recreation gives the branch a fresh, clean history.
    *   **Committing:** Creates an initial empty commit on the new `data-output` branch and pushes it.

3.  **data-output branch - build and commit sqlite db (`build-commit-sqlite-db-data-output-branch.yml`)**
    *   **Trigger:** Manual (workflow_dispatch). *Future: Intended to be triggered upon completion of `process-multiple-remote-files.yml` (or its future webhook trigger).*
    *   **Prerequisite:** The `data-output` branch must exist (can be created by the "Recreate Orphan Data Output Branch" workflow).
    *   **What it does:** Builds (or rebuilds) the `data.db` SQLite database.
    *   **Inputs:**
        *   Cleaned CSV/TSV files from the `data/` directory on the `main` branch.
        *   The `build-db.sh` script from the `main` branch.
    *   **Processing:** Executes `build-db.sh`, which uses "sqlite-utils" to create tables, define schemas, and set up full-text search.
    *   **Output:** The `data.db` file.
    *   **Committing:** The generated `data.db` is committed to the root of the `data-output` branch.

4.  **Run sql queries (`run-sql-queries.yml`)**
    *   **Trigger:** Manual (workflow_dispatch). *Future: Intended to be triggered upon completion of `build-commit-sqlite-db-data-output-branch.yml`.*
    *   **Prerequisite:** `data.db` must exist on the `data-output` branch.
    *   **What it does:** Executes predefined SQL queries against the `data.db`.
    *   **Inputs:**
        *   The `data.db` file from the `data-output` branch.
        *   SQL query files (e.g., `latest100.sql`) from the `sql-query/` directory on the `main` branch.
    *   **Output:** Query results are saved as JSON files (e.g., `sql-query/result/latest100.json`).
    *   **Committing:** The resulting JSON files are committed to the `sql-query/result/` directory on the `data-output` branch.

## Key Files and Directories

*   **`.github/workflows/`**: Contains the YAML files that define the GitHub Actions workflows (on `main` branch).
*   **`config.json`**: Configuration for the "Process Multiple Remote Files" workflow (on `main` branch). Edit this to change data sources or initial processing.
*   **`data/`**: Stores the cleaned CSV and TSV data files after processing by the first workflow (on `main` branch). These are the inputs for database construction.
*   **`build-db.sh`**: Shell script detailing the steps for building `data.db` (on `main` branch).
*   **`sql-query/`**: Contains SQL query files (on `main` branch).
*   **`requirements.txt`**: Lists necessary Python tools like `sqlite-utils` (on `main` branch).

*   **`data-output` branch**:
    *   **`data.db`**: The SQLite database file. This is the primary output of the "build and commit sqlite db" workflow.
    *   **`sql-query/result/`**: Stores the JSON output files from the "Run sql queries" workflow.
    *   **Purpose:** This is an **orphan branch**. It's used to store generated data products. It is periodically recreated by the "Recreate Orphan Data Output Branch" workflow to keep the main repository's history clean and lightweight, avoiding bloat from large or frequently changing data files.

## Typical Order of Operations

While workflows can be run independently (useful for development or specific updates), the intended sequential pipeline is:

1.  **(Optional/As Needed) Recreate Orphan Data Output Branch**: Run this first if you want to ensure a completely fresh start for your data outputs on the `data-output` branch, or if the branch doesn't exist.
2.  **Process Multiple Remote Files with Miller**: Fetches the latest raw data and saves cleaned CSV/TSV files to the `data/` directory on the `main` branch.
3.  **data-output branch - build and commit sqlite db**: Takes the processed data from `main` and builds/updates `data.db` on the `data-output` branch.
4.  **Run sql queries**: Executes queries against `data.db` on the `data-output` branch and saves the results (JSON files) back to the `data-output` branch.

**Future Enhancement:** The plan is to automate this sequence. Ideally, an update to remote CSVs would trigger the "Process Multiple Remote Files" workflow via a webhook. Subsequent workflows (`build...db`, `run...queries`) would then be triggered automatically upon the successful completion of their preceding step.

## How to Run the Workflows

1.  Navigate to the "Actions" tab of this repository on GitHub.
2.  In the left sidebar, you'll find the names of the workflows (e.g., "Process Multiple Remote Files with Miller").
3.  Click on the desired workflow.
4.  A "Run workflow" button or dropdown will appear (usually on the right). Click it.
5.  You may need to select the branch to run the workflow on (typically `main` for the initial processing, or ensure you understand the context if running others directly).
6.  Confirm to start the workflow.

You can monitor the progress of the workflow in the Actions tab. To access the outputs like `data.db` or the JSON results, you will need to switch to the `data-output` branch.

## Main Technologies Used

*   **GitHub Actions:** For workflow automation.
*   **Miller:** For robust CSV/TSV processing.
*   **sqlite-utils:** For creating and interacting with the SQLite database.
*   **jq:** For handling JSON data within the workflows.
*   **SQLite:** The file-based database system used.

This README aims to provide a clear and comprehensive guide to understanding and operating this data processing pipeline.

## Running Datasette in GitHub Codespaces

You can browse `data.db` locally with [Datasette](https://datasette.io/). Anonymous visitors can browse tables, rows, filters, and search freely — but running raw/arbitrary SQL (the `?sql=` query parameter and the "Custom SQL query" box) requires a secret token, via the [datasette-auth-tokens](https://datasette.io/plugins/datasette-auth-tokens) plugin. This stops scraping via crafted SQL while keeping the normal browsing UI open to real users. Datasette is installed with [pipx](https://pipx.pypa.io/) rather than plain `pip`: pipx installs it into its own isolated environment and — unlike a bare `pip install`, which can leave the command unreachable if `~/.local/bin` isn't already on your `$PATH` — automatically makes the `datasette` command available in your terminal. Run these commands in the Codespaces terminal, from the repo root:

```bash
# 1. Install sqlite-utils (needed to build the database)
pip install -r requirements.txt

# 2. Install Datasette as a standalone CLI tool via pipx
pipx install datasette

# 3. Add the auth-tokens, codespaces, and rate-limit plugins into Datasette's pipx environment
pipx inject datasette datasette-auth-tokens datasette-codespaces datasette-ip-rate-limit

# 4. Build the database from the data/ files
bash build-db.sh

# 5. Launch Datasette with the auth-tokens config
datasette data.db -m metadata.json
```

If `pipx` isn't available yet, install it first with `pip install --user pipx && pipx ensurepath`, then open a new terminal (or `source ~/.bashrc`) before continuing. If `pipx install datasette` complains about needing a newer `uv`, rerun it as `pipx install --backend pip datasette`.

Codespaces will prompt you to forward port 8001 (the default Datasette port) — the `datasette-codespaces` plugin (injected in step 3) makes Datasette generate correct links for that forwarded URL automatically.

`metadata.json` currently has a **hardcoded test token** (`password1`) rather than reading one from an environment variable — fine for throwaway testing, but replace it with a real random value (or switch back to `{"$env": "DATASETTE_AUTH_TOKEN"}`) before this is anything but disposable, since a committed token is visible in git history. `metadata.json`'s `"allow_sql"` block restricts SQL execution to whichever actor holds that token; browsing (`view-instance`/`view-database`/`view-table`) is left open by default so anonymous humans don't need it at all. To run SQL yourself, append the token to the forwarded URL as a query parameter:

```
https://<your-forwarded-codespaces-url>/data.json?sql=select+*+from+books+limit+1&_auth_token=password1
```

The token can also be sent as an `Authorization: Bearer password1` header if you prefer not to put it in the URL.

`metadata.json` also configures [datasette-ip-rate-limit](https://github.com/datasette/datasette-ip-rate-limit) to throttle aggressive per-IP request volume (e.g. a bot hammering the site), independent of the SQL/token gating above — it applies to everyone, token or not. The default rule caps each IP at 120 requests per 60-second window, blocking it for 5 minutes if exceeded; static assets (`/-/static/*`) are exempt so the UI doesn't break for a blocked visitor. Verified locally (with a temporarily lowered limit): the 6th request within the window got a `429 Too Many Requests`.

It deliberately does **not** set the plugin's `header` option (e.g. to `X-Forwarded-For`) to read the client IP through a proxy. Testing locally showed that if `header` is set but the named header isn't actually present on a request, the plugin **silently stops rate-limiting entirely** rather than falling back — worse than doing nothing. Leaving `header` unset uses the real ASGI connection address, which is known to correctly trigger 429s. The tradeoff: if Codespaces' port-forwarding proxy fans requests through one internal address, all visitors could be lumped into a single rate-limit bucket — a real but far safer failure mode than protection silently vanishing. If you want to try enabling `header` for finer-grained limiting, verify it's actually working first with the plugin's `debug: true` option (exposes `/-/ip-rate-limit-debug`) rather than assuming it's active. Adjust `window_seconds`/`max_requests`/`block_seconds` in `metadata.json` if these defaults are too strict or too loose for real usage.
