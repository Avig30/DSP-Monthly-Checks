document.addEventListener('DOMContentLoaded', function () {
  var toggle = document.querySelector('.nav-toggle');
  var nav = document.querySelector('.main-nav');
  if (toggle && nav) {
    var closeMenu = function () {
      nav.classList.remove('open');
      toggle.setAttribute('aria-expanded', 'false');
    };
    var openMenu = function () {
      nav.classList.add('open');
      toggle.setAttribute('aria-expanded', 'true');
    };
    toggle.addEventListener('click', function () {
      if (nav.classList.contains('open')) { closeMenu(); }
      else { openMenu(); }
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && nav.classList.contains('open')) {
        closeMenu();
        toggle.focus();
      }
    });
    nav.addEventListener('keydown', function (e) {
      if (e.key !== 'Tab' || !nav.classList.contains('open')) { return; }
      var focusable = nav.querySelectorAll('a');
      var first = focusable[0];
      var last = focusable[focusable.length - 1];
      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    });
  }

  if (nav) {
    var here = window.location.pathname;
    var navLinks = nav.querySelectorAll('a');
    navLinks.forEach(function (link) {
      link.classList.remove('active-accent');
      link.removeAttribute('aria-current');
      if (link.pathname === here) {
        link.classList.add('active-accent');
        link.setAttribute('aria-current', 'page');
      }
    });
  }
});
