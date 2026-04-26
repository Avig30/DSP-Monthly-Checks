# config.py — DSP Monthly Checks
# Edit this file to update credentials, paths, or settings.
# Keep this file private — it contains API keys and passwords.

# ── Smartsheet ────────────────────────────────────────────────────────────────
SMARTSHEET_TOKEN = "9Q5PYGCNlpfNam4NUrkWhUH66bQh2knY0YjLZ"
SMARTSHEET_SHEET_NAME = "Master DSP Applications"
SMARTSHEET_NAME_COLUMN = "Full Name"
SMARTSHEET_STATUS_COLUMN = "Status"
ACTIVE_STATUSES = ["Active", "Onboarding"]   # case-insensitive match

# ── File paths ────────────────────────────────────────────────────────────────
DSP_BASE_PATH = r"C:\Users\AviGoldschmied\ASG Home Care\Internal Share - Documents\DSPs"
MONTHLY_CHECKS_FOLDER = "Monthly Checks"     # subfolder name inside each DSP folder

# ── Email (Gmail) ─────────────────────────────────────────────────────────────
GMAIL_ADDRESS = "asghcnj@gmail.com"
GMAIL_APP_PASSWORD = "oszmrdpipqssuswr"      # 16-char App Password, spaces removed
REPORT_TO_EMAIL = "hr@asghomecare.com"
GMAIL_SMTP_HOST = "smtp.gmail.com"
GMAIL_SMTP_PORT = 587

# ── Check URLs ────────────────────────────────────────────────────────────────
NJ_TREASURY_DEBARMENT_PAGE = "https://www.nj.gov/treasury/purchase/debarment.shtml"
NJ_DEBARMENT_PDF_FALLBACK = "https://www.nj.gov/treasury/purchase/pdf/debarmentlist.pdf"
OIG_URL = "https://exclusions.oig.hhs.gov/"
NJSTART_URL = "https://www.njstart.gov"

# ── Internal ──────────────────────────────────────────────────────────────────
LOG_FILE = "dsp_checks.log"
TEMP_DIR = "temp"
REQUEST_DELAY_SECONDS = 3    # pause between DSPs to be polite to external sites
BROWSER_TIMEOUT_MS = 45_000  # 45 s per page load
