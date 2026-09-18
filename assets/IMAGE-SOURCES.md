# Image sources — full-site upgrade (7 public pages)

This record covers the photography added in the full-site upgrade branch
(`claude/asg-home-care-upgrade-e7g7qo`). It does **not** cover
`/family-caregivers/`, whose images belong to the separate, still-unapproved
`paid-family-care-program-refresh` branch and its own
`assets/img/pfcp-image-sources.md` — those files are reserved to that page
and are not reused here.

All images below were downloaded directly into this repo (never hotlinked),
visually inspected before use, and compressed to WebP.

## Adult 21+ audit

ASG's DDD services are for adults 21+. Every image below — new and
pre-existing — was checked specifically for this: does the person shown as
the individual receiving support clearly read as an adult, with no
child/teen/pediatric coding in age, styling, or setting. Only images that
passed are in use. Nothing borderline was kept "because it looked good."

## In use

### assets/img/fdsp-fitness-support.webp
- Source: https://www.pexels.com/photo/woman-doing-boxing-4058375/
- Photographer: Cliff Booth
- License: Pexels License (free for commercial use, no attribution required)
- Used on: /find-a-dsp/ — hero
- Alt text: "A young woman with Down syndrome training one-on-one with a boxing coach in a gym"
- Adult 21+: confirmed — adult female facial structure, jawline, and body proportions; Pexels' own title/tags describe the subject as a "woman," not a girl or teen; no child-coded styling or setting.

### assets/img/find-dsp-lake-outing.webp
- Source: https://unsplash.com/photos/man-in-blue-and-white-jacket-ako5dG2fqSM
- Photographer: Nathan Anderson
- License: Unsplash License (free for commercial use, no attribution required) — confirmed on the photo page itself, not Unsplash+
- Used on: /find-a-dsp/ — second section (independence/community life)
- Alt text: "An adult man with Down syndrome on a boat on a lake"
- Adult 21+: confirmed by direct visual inspection — visible beard/facial hair, mature adult features, genuine outdoor recreation setting.
- Different person/shoot from every other photo on the site, including the reserved Paid Family Care set and the boxing photo (fdsp-fitness-support.webp) used elsewhere on this same page.

### assets/img/about-park-bench.webp
- Source: Unsplash, photo id AvWfCletVGk
- Photographer/account: Hiki App (@hikiapp) — an Unsplash contributor account for the autistic/neurodivergent community; a stock-style aggregator of many different real community members' photos, not one family's photoshoot
- License: Unsplash License (free for commercial use, no attribution required)
- Used on: /about/ — hero
- Alt text: "A man laughing while holding fidget spinners at an outdoor park bench"
- Adult 21+: confirmed by direct visual inspection — full adult beard, mature face and build, real outdoor community setting (not a studio/staged shot).
- Different person from every other photo on the site.

### assets/img/hero-home.jpg (pre-existing, re-audited)
- Used on: / (Home) — hero
- Adult 21+: confirmed — the person receiving support is a visibly adult
  woman (mature face, glasses, adult styling), shown cooking with an older
  family member. No child-coded elements.

### assets/img/section4-home.jpg (pre-existing, re-audited)
- Used on: / (Home) — "You are probably already doing this work for free"
- Adult 21+: confirmed — the person receiving support is a visibly adult
  man (mature face, visible light facial hair, adult styling), seated doing
  paperwork with a DSP. No child-coded elements.

## Rejected candidates (kept out, and why)

These were downloaded and visually inspected, then discarded before being
added to any page. Listed transparently rather than silently dropped.

- **pexels-mikhail-nilov-7698232** ("man in white long-sleeve shirt holding
  a cooking pan") and **pexels-mikhail-nilov-7698287** ("man sitting by desk
  with laptop") — both show a clearly adult man with Down syndrome, so they
  passed the age check, but were dropped for tone: the first reads as a
  costume/staged chef portrait rather than an authentic real-life cooking
  moment, and the second has a tired/downcast expression that risks reading
  as unhappy rather than confident and independent. Intended slot: Services
  page ("Individual Supports" life-skills photography).
- **pexels-sanaa-ali-13995877** ("Volunteers Talking with People with Down
  Syndrome," a charity event in Damascus) — rejected specifically on the
  new adult 21+ rule: several people in the frame, including a background
  figure wearing an event lanyard, read as plausibly under 21. Rather than
  guess, this was dropped entirely. Intended slot: Services page
  ("community-based supports").
- **pexels-cliff-booth-4058222** ("young girl using laptop inside a
  restaurant," formerly committed here as `fdsp-independent-home.webp`) —
  approved in an earlier round on the reasoning that it was the same adult
  woman as the approved boxing photo (same shoot, same day), just
  mislabeled by Pexels. On review that reasoning was rejected: it's the
  same person/shoot as an already-used photo, and the source page's own
  "girl" label should have been a hard stop rather than something to
  reason past. The file has been permanently deleted from
  `assets/img/` and every reference to it removed from
  `find-a-dsp/index.html` so it can't be used by accident.
- **Unsplash dotm8dUpAxc** ("portrait of a nonbinary autistic person using their mobile phone indoors," Hiki App) — originally proposed for /become-a-dsp/'s hero. Rejected: age-ambiguous, the disability context isn't visible without the caption, and it's a portrait-orientation photo that would need a bad crop to fill a 16:9 hero. A further round of searching (~10 more queries, several candidates individually opened and viewed) found no landscape-native replacement that also showed a clear, caption-independent support/IDD context — the pattern held that photos with visible context (a fidget spinner in hand, headphones on) are portrait crops, and naturally-landscape photos in this space tend to be plain portraits or lifestyle shots with nothing visible connecting them to the page. Become a DSP's hero uses the blended-gradient treatment instead, by decision, not as a fallback nobody chose.
- Also reviewed and rejected in that round: Unsplash pOu6YEQyA6k (plain green-backdrop portrait, no visible context), Unsplash NqkTxxK_2ZY ("man holding a small dog" — genuinely candid and adult, but zero visible disability context), Unsplash aM-BRQtrng8 ("two autistic friends," age-ambiguous), Unsplash YAVHheaHGi0 and oz9fHNCUhZc (both read as staged editorial/influencer photography on direct viewing).

## Open gaps — flagged, not filled with irrelevant stock

Per instruction, an unfilled photo slot got a refined non-photo layout
(kicker bars, soft-shape background bands, bold typographic sections)
instead of a forced or irrelevant image. After extensive search (Pexels and
Unsplash) for licensed, authentic, adult-21+, non-eldercare, non-clinical
photography clearly depicting adults with intellectual/developmental
disabilities in varied everyday contexts, very little exists beyond what's
listed above and what the approved Paid Family Care page already claimed
exclusively. Pages/sections currently using a non-photo treatment instead of
new photography:

- Home — third photo moment for "How we support your family" (kept to the
  2 existing, re-audited photos instead of forcing a third)
- Services — all four service-area sections
- Become a DSP — hero (by decision, after a dedicated search for a landscape
  replacement came up empty — see rejected candidates above) and
  "what the job is"
- Contact — hero band
- FAQ — hero band

If compliant, adult-21+, non-duplicate photography becomes available later
(e.g., ASG's own real photos of clients/DSPs who've consented), these are
the natural slots for it.
