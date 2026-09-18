document.addEventListener('DOMContentLoaded', function () {
  var toggle = document.querySelector('.nav-toggle');
  var nav = document.querySelector('.main-nav');
  if (toggle && nav) {
    toggle.addEventListener('click', function () {
      nav.classList.toggle('open');
    });
  }

  // Sitewide active-nav fix: the current page's own nav link is the only
  // one that ever gets the active treatment. No page hardcodes this.
  if (nav) {
    var here = window.location.pathname;
    var links = nav.querySelectorAll('a');
    links.forEach(function (link) {
      link.classList.remove('active-accent');
      link.removeAttribute('aria-current');
      if (link.pathname === here) {
        link.classList.add('active-accent');
        link.setAttribute('aria-current', 'page');
      }
    });
  }

  // Scroll-reveal for .reveal sections, with a hard safety net so content
  // is never left invisible (no IntersectionObserver, slow paint, etc.).
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var reveals = document.querySelectorAll('.reveal');
  if (reveals.length && !reduceMotion && 'IntersectionObserver' in window) {
    reveals.forEach(function (el) { el.classList.add('pre-reveal'); });
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('revealed');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0, rootMargin: '0px 0px -5% 0px' });
    reveals.forEach(function (el) { observer.observe(el); });
    // Short safety net: real scrolling users see the progressive reveal
    // as they go; anything not yet scrolled to (or any tool that renders
    // the full page without a real scroll, e.g. a screenshot pass) still
    // gets fully visible content well under half a second after load.
    setTimeout(function () {
      reveals.forEach(function (el) { el.classList.add('revealed'); });
      observer.disconnect();
    }, 450);
  }

  // Accessible accordion (FAQ pages): real buttons with aria-expanded/
  // aria-controls, keyboard-operable by default since they're <button>s.
  document.querySelectorAll('.accordion-trigger').forEach(function (btn) {
    var panel = document.getElementById(btn.getAttribute('aria-controls'));
    if (!panel) { return; }
    btn.addEventListener('click', function () {
      var isOpen = btn.getAttribute('aria-expanded') === 'true';
      btn.setAttribute('aria-expanded', String(!isOpen));
      if (isOpen) {
        panel.style.maxHeight = panel.scrollHeight + 'px';
        requestAnimationFrame(function () { panel.style.maxHeight = '0px'; });
      } else {
        panel.hidden = false;
        panel.style.maxHeight = panel.scrollHeight + 'px';
      }
      panel.addEventListener('transitionend', function handler() {
        if (btn.getAttribute('aria-expanded') === 'false') { panel.hidden = true; }
        panel.removeEventListener('transitionend', handler);
      });
    });
  });
});
