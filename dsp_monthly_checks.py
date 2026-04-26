#!/usr/bin/env python3
"""
DSP Monthly Compliance Checks
------------------------------
Pulls all Active/Onboarding DSPs from Smartsheet, then for each person:
  1. Searches the NJ Treasury Debarment List PDF
  2. Searches the OIG Exclusions database (exclusions.oig.hhs.gov)
  3. Searches NJ Treasury DORES on njstart.gov (Criminal Offense filter)

Results are saved as dated PDFs inside each DSP's Monthly Checks folder
and a summary report is emailed to hr@asghomecare.com.

Run automatically via Windows Task Scheduler on the 1st of every month.
"""

import datetime
import logging
import os
import re
import smtplib
import sys
import time
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from pathlib import Path

import pdfplumber
import requests
import smartsheet as smartsheet_sdk
from bs4 import BeautifulSoup
from playwright.sync_api import TimeoutError as PlaywrightTimeout
from playwright.sync_api import sync_playwright
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

from config import (
    ACTIVE_STATUSES,
    BROWSER_TIMEOUT_MS,
    DSP_BASE_PATH,
    GMAIL_ADDRESS,
    GMAIL_APP_PASSWORD,
    GMAIL_SMTP_HOST,
    GMAIL_SMTP_PORT,
    LOG_FILE,
    MONTHLY_CHECKS_FOLDER,
    NJ_DEBARMENT_PDF_FALLBACK,
    NJ_TREASURY_DEBARMENT_PAGE,
    NJSTART_URL,
    OIG_URL,
    REPORT_TO_EMAIL,
    REQUEST_DELAY_SECONDS,
    SMARTSHEET_NAME_COLUMN,
    SMARTSHEET_SHEET_NAME,
    SMARTSHEET_STATUS_COLUMN,
    SMARTSHEET_TOKEN,
    TEMP_DIR,
)

# ── Logging ───────────────────────────────────────────────────────────────────

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE, encoding="utf-8"),
        logging.StreamHandler(sys.stdout),
    ],
)
log = logging.getLogger(__name__)


# ── Smartsheet ────────────────────────────────────────────────────────────────

def get_active_dsps():
    """Return list of dicts {name, first_name, last_name} for Active/Onboarding DSPs."""
    log.info("Connecting to Smartsheet …")
    ss = smartsheet_sdk.Smartsheet(SMARTSHEET_TOKEN)
    ss.errors_as_exceptions(True)

    # Find the sheet by name
    sheet_id = None
    for sheet in ss.Sheets.list_sheets(include_all=True).data:
        if sheet.name.strip().lower() == SMARTSHEET_SHEET_NAME.strip().lower():
            sheet_id = sheet.id
            break

    if not sheet_id:
        raise ValueError(f"Sheet '{SMARTSHEET_SHEET_NAME}' not found in Smartsheet account.")

    sheet = ss.Sheets.get_sheet(sheet_id)

    # Map column titles to IDs
    col_ids = {}
    for col in sheet.columns:
        col_ids[col.title.strip()] = col.id

    name_col_id = col_ids.get(SMARTSHEET_NAME_COLUMN)
    status_col_id = col_ids.get(SMARTSHEET_STATUS_COLUMN)

    if not name_col_id or not status_col_id:
        raise ValueError(
            f"Could not find columns '{SMARTSHEET_NAME_COLUMN}' and/or "
            f"'{SMARTSHEET_STATUS_COLUMN}' in sheet. Available: {list(col_ids.keys())}"
        )

    dsps = []
    for row in sheet.rows:
        name = status = None
        for cell in row.cells:
            if cell.column_id == name_col_id:
                name = (cell.value or "").strip()
            elif cell.column_id == status_col_id:
                status = (cell.value or "").strip()

        if not name or not status:
            continue
        if status.lower() not in [s.lower() for s in ACTIVE_STATUSES]:
            continue

        parts = name.split()
        first_name = parts[0] if parts else name
        last_name = " ".join(parts[1:]) if len(parts) > 1 else ""

        dsps.append({"name": name, "first_name": first_name, "last_name": last_name})

    log.info(f"Found {len(dsps)} Active/Onboarding DSPs.")
    return dsps


# ── Folder management ─────────────────────────────────────────────────────────

def get_monthly_checks_folder(full_name: str, new_folders_log: list) -> Path:
    """
    Return the Monthly Checks path for a DSP, creating the folder if needed.
    Tries exact match, then case-insensitive match, then creates a new folder.
    """
    base = Path(DSP_BASE_PATH)

    # 1. Exact match
    candidate = base / full_name
    if candidate.is_dir():
        mc = candidate / MONTHLY_CHECKS_FOLDER
        mc.mkdir(exist_ok=True)
        return mc

    # 2. Case-insensitive match
    full_name_lower = full_name.lower()
    for entry in base.iterdir():
        if entry.is_dir() and entry.name.lower() == full_name_lower:
            mc = entry / MONTHLY_CHECKS_FOLDER
            mc.mkdir(exist_ok=True)
            return mc

    # 3. Name-parts match (handles middle initials or slight differences)
    target_parts = set(full_name_lower.split())
    for entry in base.iterdir():
        if entry.is_dir():
            entry_parts = set(entry.name.lower().split())
            if target_parts == entry_parts:
                mc = entry / MONTHLY_CHECKS_FOLDER
                mc.mkdir(exist_ok=True)
                return mc

    # 4. No match — create new folder matching the standard layout
    new_dir = base / full_name
    new_dir.mkdir(exist_ok=True)
    mc = new_dir / MONTHLY_CHECKS_FOLDER
    mc.mkdir(exist_ok=True)
    new_folders_log.append(str(new_dir))
    log.info(f"Created new DSP folder: {new_dir}")
    return mc


# ── PDF utilities ─────────────────────────────────────────────────────────────

def _styles():
    s = getSampleStyleSheet()
    return s


def create_result_pdf(output_path: Path, dsp_name: str, check_name: str,
                      date: datetime.date, passed: bool, details: list[str]):
    """Create a clean result PDF for one compliance check."""
    doc = SimpleDocTemplate(
        str(output_path),
        pagesize=letter,
        leftMargin=inch,
        rightMargin=inch,
        topMargin=inch,
        bottomMargin=inch,
    )
    styles = _styles()

    title_style = ParagraphStyle(
        "Title", parent=styles["Heading1"], fontSize=18, spaceAfter=6
    )
    sub_style = ParagraphStyle(
        "Sub", parent=styles["Normal"], fontSize=11, textColor=colors.grey, spaceAfter=4
    )
    result_style = ParagraphStyle(
        "Result",
        parent=styles["Heading2"],
        fontSize=28,
        textColor=colors.green if passed else colors.red,
        spaceAfter=12,
    )
    detail_style = ParagraphStyle(
        "Detail", parent=styles["Normal"], fontSize=10, spaceAfter=4, fontName="Courier"
    )

    story = [
        Paragraph(f"DSP Compliance Check — {check_name}", title_style),
        Paragraph(f"DSP: <b>{dsp_name}</b>", styles["Normal"]),
        Paragraph(f"Date: {date.strftime('%B %d, %Y')}", sub_style),
        Spacer(1, 0.2 * inch),
        Paragraph("PASS" if passed else "FAIL", result_style),
        Spacer(1, 0.1 * inch),
    ]

    for line in details:
        story.append(Paragraph(line.replace("<", "&lt;").replace(">", "&gt;"), detail_style))

    story.append(Spacer(1, 0.3 * inch))
    story.append(
        Paragraph(
            f"Generated by DSP Monthly Checks script on {datetime.datetime.now():%Y-%m-%d %H:%M}",
            styles["Italic"],
        )
    )

    doc.build(story)


# ── NJ Debarment Check ────────────────────────────────────────────────────────

def _download_nj_debarment_pdf() -> Path:
    """Download the current NJ Treasury Debarment List PDF."""
    temp = Path(TEMP_DIR)
    temp.mkdir(exist_ok=True)
    dest = temp / "nj_debarment.pdf"

    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
        )
    }

    # Try to find the PDF link on the Treasury debarment page
    pdf_url = NJ_DEBARMENT_PDF_FALLBACK
    try:
        resp = requests.get(NJ_TREASURY_DEBARMENT_PAGE, headers=headers, timeout=30)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "html.parser")
        for a in soup.find_all("a", href=True):
            href = a["href"]
            if href.lower().endswith(".pdf"):
                pdf_url = href if href.startswith("http") else "https://www.nj.gov" + href
                log.info(f"Found debarment PDF link on Treasury page: {pdf_url}")
                break
    except Exception as e:
        log.warning(f"Could not scrape Treasury page for PDF link ({e}); using fallback URL.")

    log.info(f"Downloading NJ Debarment PDF from: {pdf_url}")
    resp = requests.get(pdf_url, headers=headers, timeout=60)
    resp.raise_for_status()
    dest.write_bytes(resp.content)
    log.info(f"Saved debarment PDF to: {dest} ({len(resp.content):,} bytes)")
    return dest


def _search_pdf_for_name(pdf_path: Path, first_name: str, last_name: str):
    """
    Search the debarment PDF for a person's name.
    Returns (found: bool, detail_lines: list[str]).
    """
    patterns = []
    if last_name:
        patterns += [
            f"{last_name} {first_name}".upper(),
            f"{first_name} {last_name}".upper(),
            f"{last_name}, {first_name}".upper(),
        ]
    else:
        patterns = [first_name.upper()]

    try:
        full_text_upper = ""
        with pdfplumber.open(str(pdf_path)) as pdf:
            for page in pdf.pages:
                full_text_upper += (page.extract_text() or "") + "\n"
        full_text_upper = full_text_upper.upper()
    except Exception as e:
        return False, [f"ERROR reading PDF: {e}", "Manual review required."]

    if not full_text_upper.strip():
        return False, ["WARNING: No text could be extracted from the PDF (may be image-based).",
                       "Manual review required."]

    matches = []
    for pattern in patterns:
        if pattern in full_text_upper:
            # Grab surrounding context lines
            lines = full_text_upper.splitlines()
            for i, line in enumerate(lines):
                if pattern in line:
                    ctx = lines[max(0, i - 1): i + 3]
                    matches.append("\n".join(ctx).strip())

    if matches:
        details = [f"MATCH FOUND for '{first_name} {last_name}':"] + matches[:5]
        return True, details

    return False, [
        f"Name '{first_name} {last_name}' not found in NJ Debarment List.",
        f"Source PDF: {pdf_path.name}",
        f"Search patterns used: {', '.join(patterns)}",
    ]


def check_nj_debarment(dsp: dict, folder: Path, today: datetime.date,
                       debarment_pdf: Path) -> str:
    """Run NJ Debarment check. Returns 'PASS', 'FAIL', or 'ERROR'."""
    first, last = dsp["first_name"], dsp["last_name"]
    name = dsp["name"]
    log.info(f"  [NJ Debarment] Checking {name} …")

    try:
        found, details = _search_pdf_for_name(debarment_pdf, first, last)
        passed = not found
        pdf_out = folder / f"{today.isoformat()}_NJ_Debarment.pdf"
        create_result_pdf(pdf_out, name, "NJ Debarment List", today, passed, details)
        result = "PASS" if passed else "FAIL"
        log.info(f"  [NJ Debarment] {name} → {result}")
        return result
    except Exception as e:
        log.error(f"  [NJ Debarment] ERROR for {name}: {e}")
        return "ERROR"


# ── OIG Exclusions Check ──────────────────────────────────────────────────────

def check_oig_exclusions(dsp: dict, folder: Path, today: datetime.date, browser) -> str:
    """
    Search OIG LEIE exclusions database and save a PDF of results.
    Returns 'PASS', 'FAIL', or 'ERROR'.
    """
    first, last = dsp["first_name"], dsp["last_name"]
    name = dsp["name"]
    log.info(f"  [OIG] Checking {name} …")

    page = browser.new_page()
    try:
        page.goto(OIG_URL, wait_until="networkidle", timeout=BROWSER_TIMEOUT_MS)

        # Fill Last Name and First Name fields
        # The OIG site uses standard HTML name/id attributes
        try:
            page.fill('input[name="lastName"], input[id*="LastName" i], input[id*="lname" i]',
                      last, timeout=10_000)
            page.fill('input[name="firstName"], input[id*="FirstName" i], input[id*="fname" i]',
                      first, timeout=10_000)
        except PlaywrightTimeout:
            # Fallback: fill by placeholder text
            page.get_by_placeholder(re.compile(r"last\s*name", re.I)).fill(last)
            page.get_by_placeholder(re.compile(r"first\s*name", re.I)).fill(first)

        # Click search
        page.click(
            'input[type="submit"], button[type="submit"], button:has-text("Search")',
            timeout=10_000,
        )
        page.wait_for_load_state("networkidle", timeout=BROWSER_TIMEOUT_MS)

        content_lower = page.inner_text("body").lower()
        no_results = any(
            phrase in content_lower
            for phrase in ["no records match", "no results found", "0 records", "no exclusions"]
        )

        pdf_out = folder / f"{today.isoformat()}_OIG_Exclusions.pdf"
        page.pdf(path=str(pdf_out), format="Letter", print_background=True)

        result = "PASS" if no_results else "FAIL"
        log.info(f"  [OIG] {name} → {result}")
        return result

    except Exception as e:
        log.error(f"  [OIG] ERROR for {name}: {e}")
        # Save a screenshot so the user can see what happened
        try:
            page.screenshot(path=str(folder / f"{today.isoformat()}_OIG_ERROR.png"))
        except Exception:
            pass
        return "ERROR"
    finally:
        page.close()


# ── NJ DORES / njstart.gov Check ──────────────────────────────────────────────

def check_nj_dores(dsp: dict, folder: Path, today: datetime.date, browser) -> str:
    """
    Search NJ Treasury DORES on njstart.gov (Criminal Offense filter) and save PDF.
    Returns 'PASS', 'FAIL', or 'ERROR'.
    """
    first, last = dsp["first_name"], dsp["last_name"]
    name = dsp["name"]
    full_name = f"{first} {last}".strip()
    log.info(f"  [DORES] Checking {name} …")

    page = browser.new_page()
    try:
        # Try the direct DORES/ADSIT search page first
        dores_urls = [
            f"{NJSTART_URL}/bso/content/search/search_adsit.html",
            f"{NJSTART_URL}/bso/content/search/search_debarment.html",
            NJSTART_URL,
        ]

        landed = False
        for url in dores_urls:
            try:
                page.goto(url, wait_until="networkidle", timeout=BROWSER_TIMEOUT_MS)
                # Confirm we see a search form
                if page.locator("input[type='text'], input[type='search']").count() > 0:
                    landed = True
                    log.info(f"  [DORES] Landed on search form at: {url}")
                    break
            except Exception:
                continue

        if not landed:
            log.warning("  [DORES] Could not reach DORES search form. Saving screenshot.")
            page.screenshot(path=str(folder / f"{today.isoformat()}_DORES_ERROR.png"))
            return "ERROR"

        # Fill the name field (the form uses a combined or split name field)
        filled = False
        for selector in [
            'input[name*="name" i]',
            'input[id*="name" i]',
            'input[placeholder*="name" i]',
            'input[type="text"]',
        ]:
            try:
                loc = page.locator(selector).first
                if loc.is_visible(timeout=3000):
                    loc.fill(full_name)
                    filled = True
                    break
            except Exception:
                continue

        if not filled:
            log.warning("  [DORES] Could not find name input field.")

        # Select "Criminal Offense" from Reason dropdown
        reason_selected = False
        for selector in [
            'select[name*="reason" i]',
            'select[id*="reason" i]',
            'select[name*="type" i]',
        ]:
            try:
                loc = page.locator(selector).first
                if loc.is_visible(timeout=3000):
                    # Try selecting by label text
                    loc.select_option(label=re.compile(r"criminal\s*offense", re.I))
                    reason_selected = True
                    break
            except Exception:
                continue

        if not reason_selected:
            log.warning("  [DORES] Could not select 'Criminal Offense' reason — check selectors.")

        # Submit the form
        try:
            page.click(
                'input[type="submit"], button[type="submit"], button:has-text("Search")',
                timeout=10_000,
            )
            page.wait_for_load_state("networkidle", timeout=BROWSER_TIMEOUT_MS)
        except Exception as e:
            log.warning(f"  [DORES] Submit click issue: {e}")

        content_lower = page.inner_text("body").lower()
        no_results = any(
            phrase in content_lower
            for phrase in ["no results", "no records", "0 results", "not found",
                           "no matches", "no data found"]
        )

        pdf_out = folder / f"{today.isoformat()}_NJ_DORES.pdf"
        page.pdf(path=str(pdf_out), format="Letter", print_background=True)

        result = "PASS" if no_results else "FAIL"
        log.info(f"  [DORES] {name} → {result}")
        return result

    except Exception as e:
        log.error(f"  [DORES] ERROR for {name}: {e}")
        try:
            page.screenshot(path=str(folder / f"{today.isoformat()}_DORES_ERROR.png"))
        except Exception:
            pass
        return "ERROR"
    finally:
        page.close()


# ── Email report ──────────────────────────────────────────────────────────────

def send_email_report(results: list, today: datetime.date, new_folders: list):
    """Send the monthly summary email via Gmail SMTP."""
    month_str = today.strftime("%B %Y")

    passed_all = [r for r in results if all(r[k] == "PASS" for k in ("nj_debarment", "oig", "dores"))]
    failed     = [r for r in results if any(r[k] == "FAIL"  for k in ("nj_debarment", "oig", "dores"))]
    errored    = [r for r in results if any(r[k] == "ERROR" for k in ("nj_debarment", "oig", "dores"))]

    def status_icon(s):
        return {"PASS": "✅ PASS", "FAIL": "❌ FAIL", "ERROR": "⚠️ ERROR"}.get(s, s)

    # Plain-text body
    lines = [
        f"DSP Monthly Compliance Check — {month_str}",
        "=" * 55,
        f"Total DSPs checked : {len(results)}",
        f"All Clear          : {len(passed_all)}",
        f"Issues Found       : {len(failed)}",
        f"Errors (need review): {len(errored)}",
        "",
    ]

    if failed:
        lines += ["── ISSUES FOUND ─────────────────────────────────────", ""]
        for r in failed:
            lines.append(
                f"  {r['name']:<30} | NJ Debarment: {r['nj_debarment']:<5} "
                f"| OIG: {r['oig']:<5} | DORES: {r['dores']}"
            )
        lines.append("")

    if errored:
        lines += ["── ERRORS (manual review needed) ─────────────────────", ""]
        for r in errored:
            lines.append(
                f"  {r['name']:<30} | NJ Debarment: {r['nj_debarment']:<5} "
                f"| OIG: {r['oig']:<5} | DORES: {r['dores']}"
            )
            for err in r.get("errors", []):
                lines.append(f"      → {err}")
        lines.append("")

    if passed_all:
        lines += ["── ALL CLEAR ─────────────────────────────────────────", ""]
        for r in passed_all:
            lines.append(f"  {r['name']}")
        lines.append("")

    if new_folders:
        lines += ["── NEW FOLDERS CREATED ───────────────────────────────", ""]
        for f in new_folders:
            lines.append(f"  {f}")
        lines.append("")

    lines += [
        "─" * 55,
        f"Results saved to each DSP's '{MONTHLY_CHECKS_FOLDER}' folder.",
        f"Full log: {Path(LOG_FILE).resolve()}",
    ]

    body = "\n".join(lines)
    subject = f"DSP Compliance Check — {month_str} — {len(failed)} Issue(s), {len(errored)} Error(s)"

    msg = MIMEMultipart("alternative")
    msg["Subject"] = subject
    msg["From"] = GMAIL_ADDRESS
    msg["To"] = REPORT_TO_EMAIL
    msg.attach(MIMEText(body, "plain"))

    log.info(f"Sending email report to {REPORT_TO_EMAIL} …")
    try:
        with smtplib.SMTP(GMAIL_SMTP_HOST, GMAIL_SMTP_PORT) as smtp:
            smtp.ehlo()
            smtp.starttls()
            smtp.login(GMAIL_ADDRESS, GMAIL_APP_PASSWORD)
            smtp.sendmail(GMAIL_ADDRESS, REPORT_TO_EMAIL, msg.as_string())
        log.info("Email sent successfully.")
    except Exception as e:
        log.error(f"Failed to send email: {e}")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    today = datetime.date.today()
    log.info("=" * 60)
    log.info(f"DSP Monthly Compliance Checks — {today.isoformat()}")
    log.info("=" * 60)

    # Pull DSP list
    try:
        dsps = get_active_dsps()
    except Exception as e:
        log.critical(f"Cannot retrieve DSP list from Smartsheet: {e}")
        sys.exit(1)

    if not dsps:
        log.warning("No Active/Onboarding DSPs found. Nothing to check.")
        sys.exit(0)

    # Download NJ Debarment PDF once — shared across all DSPs
    try:
        debarment_pdf = _download_nj_debarment_pdf()
    except Exception as e:
        log.error(f"Could not download NJ Debarment PDF: {e}. This check will be skipped.")
        debarment_pdf = None

    results = []
    new_folders = []

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True)
        log.info("Browser launched (headless Chromium).")

        for dsp in dsps:
            name = dsp["name"]
            log.info(f"Checking: {name}")

            # Get/create the Monthly Checks folder
            try:
                mc_folder = get_monthly_checks_folder(name, new_folders)
            except Exception as e:
                log.error(f"Cannot find/create folder for {name}: {e}")
                results.append({
                    "name": name,
                    "nj_debarment": "ERROR",
                    "oig": "ERROR",
                    "dores": "ERROR",
                    "errors": [f"Folder error: {e}"],
                })
                continue

            record = {"name": name, "nj_debarment": "ERROR", "oig": "ERROR",
                      "dores": "ERROR", "errors": []}

            # 1. NJ Debarment
            if debarment_pdf:
                record["nj_debarment"] = check_nj_debarment(dsp, mc_folder, today, debarment_pdf)
            else:
                record["errors"].append("NJ Debarment PDF not available — skipped.")

            # 2. OIG Exclusions
            record["oig"] = check_oig_exclusions(dsp, mc_folder, today, browser)

            # 3. NJ DORES
            record["dores"] = check_nj_dores(dsp, mc_folder, today, browser)

            results.append(record)

            # Pause between DSPs to be polite to external sites
            time.sleep(REQUEST_DELAY_SECONDS)

        browser.close()
        log.info("Browser closed.")

    # Send email summary
    send_email_report(results, today, new_folders)

    # Print final summary to log
    passed = sum(1 for r in results if all(r[k] == "PASS" for k in ("nj_debarment", "oig", "dores")))
    log.info(f"Done. {passed}/{len(results)} DSPs passed all checks.")


if __name__ == "__main__":
    main()
