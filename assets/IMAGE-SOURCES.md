# Image sources — full-site rebuild (7 public pages)

This record covers photography on the 7 rebuilt public pages
(`claude/asg-full-rebuild-v3`). It does not cover `/family-caregivers/`,
whose images are reserved to that protected page and documented separately
in `assets/img/pfcp-image-sources.md`.

All images below were downloaded directly into this repo (never hotlinked),
visually inspected before use (the actual pixels, not just a caption or an
AI-generated description of the source page), and compressed to WebP.

## Adult 21+ audit

ASG's DDD services are for adults 21+. Every image below — new and
pre-existing — was checked specifically for this: does the person shown as
the individual receiving support clearly read as an adult, with no
child/teen/pediatric coding in age, styling, or setting. Only images that
passed are in use.

## In use

### assets/img/hero-home.jpg (pre-existing)
- Used on: / (Home) — hero
- Adult 21+: confirmed — the person receiving support is a visibly adult
  woman (mature face, glasses, adult styling), shown cooking with an older
  family member. No child-coded elements.

### assets/img/section4-home.jpg (pre-existing)
- Used on: / (Home) — "You are probably already doing this work"
- Adult 21+: confirmed — the person receiving support is a visibly adult
  man (mature face, visible light facial hair, adult styling), seated doing
  paperwork with a DSP. No child-coded elements.
- Alt text corrected per Avi's Phase 1 review: "A young man going through
  paperwork with his mother at the kitchen table" (the woman in this photo
  reads as family, not a DSP).

### assets/img/find-dsp-lake-outing.webp
- Source: https://unsplash.com/photos/man-in-blue-and-white-jacket-ako5dG2fqSM
- Photographer: Nathan Anderson
- License: Unsplash License (free for commercial use, no attribution
  required) — confirmed on the photo page itself, not Unsplash+
- Used on: /find-a-dsp/ — second section (independence/community life)
- Alt text: "An adult man with Down syndrome on a boat on a lake."
- Adult 21+: confirmed by direct visual inspection — visible beard/facial
  hair, mature adult features, genuine outdoor recreation setting.

### assets/img/about-park-bench.webp
- Source: Unsplash, photo id AvWfCletVGk
- Photographer/account: Hiki App (@hikiapp) — an Unsplash contributor
  account for the autistic/neurodivergent community; a stock-style
  aggregator of many different real community members' photos, not one
  family's photoshoot
- License: Unsplash License (free for commercial use, no attribution
  required)
- Used on: /about/ — hero
- Alt text: "A man laughing while holding fidget spinners at an outdoor
  park bench."
- Adult 21+: confirmed by direct visual inspection — full adult beard,
  mature face and build, real outdoor community setting (not a
  studio/staged shot).

## Removed this round: cross-page duplicate photo

### assets/img/fdsp-fitness-support.webp — REMOVED, do not reuse
Previously approved as "Photo C" for the /find-a-dsp/ hero
(source: pexels.com/photo/woman-doing-boxing-4058375/, photographer
Cliff Booth). While building this rebuild it was discovered — by directly
viewing both files side by side, not just comparing source URLs — that
this is the **identical underlying photograph** already used in the
protected /family-caregivers/ page as `pfcp-adult-boxing.webp` (same
coach, same subject, same pose, same gym; different crop/export only).
That page is locked as zero-reconstruction and cannot be changed, so the
duplicate had to be resolved here instead. Avi's decision: drop the photo
from /find-a-dsp/ and use a fully-designed non-photo hero (matching the
treatment style already approved for /become-a-dsp/) rather than reuse it
or force a new, unapproved replacement photo into the hero slot on short
notice. The file remains removed from `find-a-dsp/index.html`; if a
genuinely different adult 21+ photo is wanted for that hero later, it goes
through the normal contact-sheet approval gate first.

## Open gaps — non-photo treatment used instead

Per the adult 21+ / no-forced-photo rule, an unfilled photo slot gets a
refined non-photo layout instead of a forced or duplicate image:
- Find a DSP — hero (see removal note above)
- Become a DSP — hero (by earlier decision, after a dedicated search for a
  compliant landscape photo came up empty)
- Services — all four service-area sections
- Contact — hero band
- FAQ — hero band

If compliant, adult-21+, non-duplicate photography becomes available later,
these are the natural slots for it.
