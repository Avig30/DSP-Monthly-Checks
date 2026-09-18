(function () {
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (reduceMotion || !('IntersectionObserver' in window)) { return; }
  var els = document.querySelectorAll('.reveal');
  els.forEach(function (el) { el.classList.add('pre-reveal'); });
  var observer = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
      if (entry.isIntersecting) {
        entry.target.classList.add('revealed');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0, rootMargin: '0px 0px -5% 0px' });
  els.forEach(function (el) { observer.observe(el); });
  /* Safety net: never leave content invisible, regardless of scroll
     behavior, timing, or tooling that doesn't scroll at all. */
  setTimeout(function () {
    els.forEach(function (el) { el.classList.add('revealed'); });
    observer.disconnect();
  }, 450);
})();
