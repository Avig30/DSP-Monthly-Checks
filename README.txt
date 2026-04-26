================================================================
 DSP Monthly Compliance Checks — Setup & Operations Guide
================================================================

WHAT IT DOES
------------
On the 1st of every month at 8:00 AM the script automatically:

  1. Pulls every Active and Onboarding DSP from the Smartsheet
     sheet "Master DSP Applications" (Full Name + Status columns).

  2. Finds each DSP's folder under:
       C:\Users\AviGoldschmied\ASG Home Care\
         Internal Share - Documents\DSPs\<First Last>\

  3. Creates the folder + a "Monthly Checks" subfolder for any
     new DSP who doesn't have one yet.

  4. For each DSP, runs three checks and saves a dated PDF to
     their Monthly Checks folder:

       YYYY-MM-DD_NJ_Debarment.pdf   — NJ Treasury Debarment List
       YYYY-MM-DD_OIG_Exclusions.pdf — OIG LEIE exclusions database
       YYYY-MM-DD_NJ_DORES.pdf       — NJ Treasury DORES (njstart.gov)

  5. Emails a pass/fail summary to hr@asghomecare.com.

================================================================
 ONE-TIME SETUP (do this first)
================================================================

  1. Copy this entire folder to your computer, for example:
       C:\DSP-Monthly-Checks\

  2. Right-click setup.bat → "Run as administrator"
     This will:
       - Install Python (if not already installed)
       - Install all required Python packages
       - Install the Chromium browser for automation
       - Register the Windows Scheduled Task

  3. When prompted "Do you want to allow this app to make changes?"
     click Yes.

  4. Done. The script will run automatically every 1st of the month.

================================================================
 RUN MANUALLY (any time)
================================================================

  Double-click run_checks.bat
  — or —
  Open Command Prompt, cd to the folder, and run:
    python dsp_monthly_checks.py

================================================================
 IMPORTANT: ROTATE YOUR SMARTSHEET API TOKEN
================================================================

  Your Smartsheet API token was shared in this conversation.
  Please regenerate it immediately:

    1. Log in to Smartsheet
    2. Click your avatar (top-right) → Account → Personal Settings
    3. Click "API Access"
    4. Delete the current token and generate a new one
    5. Paste the new token into config.py where it says:
         SMARTSHEET_TOKEN = "..."

================================================================
 CONFIGURATION (config.py)
================================================================

  All settings live in config.py. Edit that file to:

  • Change the Smartsheet token (see above)
  • Change the DSP folder path (DSP_BASE_PATH)
  • Change the Gmail address or app password
  • Change the report recipient email (REPORT_TO_EMAIL)
  • Adjust which statuses count as "active" (ACTIVE_STATUSES)

================================================================
 TROUBLESHOOTING
================================================================

  Problem: Script runs but DORES check always errors
  ──────────────────────────────────────────────────
  The NJStart.gov website may have changed its layout. To find
  the correct URL:
    1. Open Chrome and manually navigate to njstart.gov
    2. Do one search manually, copying the URL from the address bar
    3. Paste that URL into config.py as NJSTART_DORES_URL
       (you may need to add this variable and update the script)

  Problem: OIG check fails or shows wrong results
  ────────────────────────────────────────────────
  The OIG site (exclusions.oig.hhs.gov) is publicly accessible.
  If automation breaks, check for a CAPTCHA or site update.
  You can also search manually at https://exclusions.oig.hhs.gov/

  Problem: NJ Debarment PDF not found
  ─────────────────────────────────────
  The script looks for the PDF link on:
    https://www.nj.gov/treasury/purchase/debarment.shtml
  If the URL changes, update NJ_TREASURY_DEBARMENT_PAGE in config.py.

  Problem: Email not sending
  ───────────────────────────
  1. Make sure 2-Step Verification is ON for asghcnj@gmail.com
  2. Confirm the App Password in config.py (GMAIL_APP_PASSWORD)
     is the 16-character code without spaces.
  3. Check the log file: dsp_checks.log

  Problem: Wrong DSP name / folder not found
  ────────────────────────────────────────────
  The script matches names from Smartsheet (Full Name column) to
  folder names under the DSPs directory. If the Smartsheet name
  and folder name differ (e.g., "William" vs "Bill"), the script
  will create a new folder. Rename one to match the other.

================================================================
 VERIFYING THE SCHEDULED TASK
================================================================

  1. Press Win + R, type: taskschd.msc, press Enter
  2. In the left panel, click "Task Scheduler Library"
  3. Find "DSP Monthly Compliance Checks"
  4. Right-click → "Run" to test it immediately

================================================================
 LOG FILE
================================================================

  Every run appends to: dsp_checks.log (in the same folder)
  Open it in Notepad to see what happened on each run.

================================================================
 FILE LAYOUT
================================================================

  DSP-Monthly-Checks\
  ├── dsp_monthly_checks.py  ← main script (do not edit)
  ├── config.py              ← all settings (edit this)
  ├── requirements.txt       ← Python package list
  ├── setup.bat              ← one-time setup (run as admin)
  ├── run_checks.bat         ← run manually anytime
  ├── schedule_task.ps1      ← Task Scheduler registration
  ├── README.txt             ← this file
  ├── dsp_checks.log         ← run log (auto-created)
  └── temp\                  ← temporary downloads (auto-created)

================================================================
