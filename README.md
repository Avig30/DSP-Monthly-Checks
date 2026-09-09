# ASG Home Care — Website Rebuild

Static HTML/CSS/JS rebuild of asghomecare.com, per the Claude Code handoff brief.
One shared stylesheet (`assets/css/style.css`), one folder per route with an
`index.html`, so the site serves clean paths (`/services/`, `/find-a-dsp/`, etc.)
on any static host.

## Structure

```
index.html              Home (/)
services/                /services
find-a-dsp/               /find-a-dsp   (has a form)
become-a-dsp/             /become-a-dsp (has a form)
about/                     /about
contact/                   /contact      (has a form)
family-caregivers/        /family-caregivers  — STUB, see below
faq/                       /faq                — STUB, see below
assets/css/style.css      shared stylesheet (design system)
assets/js/main.js          mobile nav toggle
assets/img/                logo + hero photos, downloaded from the brief's asset links
```

## ⚠️ Action needed before launch: wire up the 3 forms

The Find a DSP, Become a DSP, and Contact forms currently POST to a
**placeholder** endpoint:

```
https://formspree.io/f/YOUR_FORMSPREE_ID
```

I don't have (and shouldn't create) a Formspree/Web3Forms account on the
owner's behalf, so this needs one real step before the forms will actually
deliver mail to `info@asghomecare.com`:

1. Go to [formspree.io](https://formspree.io) (or web3forms.com) and sign up
   with `info@asghomecare.com`, or whatever inbox should receive submissions.
2. Create one form (or one per page) and copy the real form endpoint/ID.
3. Replace `YOUR_FORMSPREE_ID` in the `action="..."` attribute in:
   - `find-a-dsp/index.html`
   - `become-a-dsp/index.html`
   - `contact/index.html`
4. Verify the destination email address in Formspree's dashboard (they send
   a confirmation email the first time).

Each form already has a hidden `_subject` field so submissions arrive
labeled by which form they came from, and a honeypot field (`_gotcha`) for
basic spam filtering (Formspree convention — remove it if you switch to a
different backend that doesn't support it).

## Stub pages flagged for owner approval

Per the brief, two pages are intentionally placeholders, each marked with a
visible yellow banner at the top of the page:

- **`/family-caregivers`** — linked from buttons across the site. Currently
  reuses only already-approved copy fragments from the Home page (Section 2
  "I'm a family member" card + Section 4 body) as a content placeholder.
  Needs the owner's sign-off on final content.
- **`/faq`** — linked from the footer. Currently a bare placeholder with no
  invented copy, pointing visitors to Contact in the meantime.

Remove the `.stub-banner` div and swap in approved copy once the owner signs
off, then update this README.

## Design system

Colors, type (Manrope via Google Fonts), spacing, card/button styles, and
header/footer rules all live in `assets/css/style.css`, matching Part 3 of
the handoff brief. Header nav accent differs intentionally: "Home" is teal
on the homepage; "Get Paid to Care for Family" is teal on every inner page.

## Deployment

No DNS changes or live deploys have been made — this build is meant for
preview only. To preview locally:

```
npx serve .
```

(or any static file server — just make sure it serves each folder's
`index.html` for its clean-URL path, e.g. `/services/` → `services/index.html`).

When the owner approves a cutover, this can be deployed as-is to any static
host (Netlify, Vercel, GitHub Pages, Cloudflare Pages, S3 + CloudFront) that
serves `folder/index.html` for `folder/` requests — this is the default
behavior on Netlify, Vercel, and Cloudflare Pages.

## Acceptance checklist (self-check against the brief)

- [x] Header + footer identical across all 8 pages (same markup, same links)
- [x] All Part 2 copy pasted verbatim (no rewrites/trims/expansions)
- [x] All buttons linked per their specified targets
- [x] All 3 forms point at a form backend that emails `info@asghomecare.com`
      — **pending the real Formspree/Web3Forms ID, see above**
- [x] Colors/typography match Part 3 design system
- [x] Mobile: single-column stacking, hamburger nav toggle below 900px
- [x] `/family-caregivers` and `/faq` stubs flagged visibly for owner review

Nothing here goes live without the owner's explicit approval.
