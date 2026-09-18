/* Event layer using only the existing GA4 tag already on every page
   (gtag/dataLayer from the inline snippet in <head>). No new IDs,
   properties, or third-party scripts. No PII is ever sent: only route,
   section, and label/destination strings that are already public UI
   text or URLs, never form field values, names, emails, or phone
   numbers a visitor typed in. */
(function () {
  if (typeof gtag !== 'function') { return; }
  var route = window.location.pathname;

  function send(name, params) {
    gtag('event', name, Object.assign({ route: route }, params));
  }

  document.addEventListener('click', function (e) {
    var el = e.target.closest('a, button');
    if (!el) { return; }

    if (el.matches('a[href^="tel:"]')) {
      send('phone_click', { section: sectionOf(el) });
      return;
    }
    if (el.matches('a[href^="mailto:"]')) {
      send('email_click', { section: sectionOf(el) });
      return;
    }
    if (el.closest('.main-nav')) {
      send('navigation_click', { destination: el.getAttribute('href'), context: window.innerWidth < 900 ? 'mobile' : 'desktop' });
      return;
    }
    if (el.matches('.btn')) {
      var destination = el.getAttribute('href') || '';
      send('cta_click', { label: (el.textContent || '').trim(), destination: destination, section: sectionOf(el) });
      if (destination.indexOf('/family-caregivers/') === 0) { send('paid_family_care_click', { section: sectionOf(el) }); }
      if (route.indexOf('/become-a-dsp/') === 0 && el.closest('form')) { send('dsp_apply_click', { section: sectionOf(el) }); }
    }
  });

  document.querySelectorAll('.accordion-item').forEach(function (item) {
    item.addEventListener('toggle', function () {
      if (item.open) {
        var summary = item.querySelector('summary');
        send('faq_open', { question: summary ? summary.textContent.trim() : '' });
      }
    });
  });

  document.querySelectorAll('form').forEach(function (form) {
    var started = false;
    var name = form.querySelector('h3') ? form.querySelector('h3').textContent.trim() : 'form';
    form.addEventListener('focusin', function () {
      if (!started) { started = true; send('form_start', { form: name }); }
    });
    form.addEventListener('submit', function () {
      send('form_submit', { form: name });
    });
  });

  function sectionOf(el) {
    var section = el.closest('section');
    if (!section) { return ''; }
    var heading = section.querySelector('h1, h2');
    return heading ? heading.textContent.trim().slice(0, 60) : '';
  }
})();
