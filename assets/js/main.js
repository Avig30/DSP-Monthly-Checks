document.addEventListener('DOMContentLoaded', function () {
  var toggle = document.querySelector('.nav-toggle');
  var nav = document.querySelector('.main-nav');
  if (toggle && nav) {
    toggle.addEventListener('click', function () {
      nav.classList.toggle('open');
    });
  }

  if (nav) {
    var here = window.location.pathname;
    var links = nav.querySelectorAll('a');
    links.forEach(function (link) {
      link.classList.remove('active-accent');
      if (link.pathname === here) {
        link.classList.add('active-accent');
      }
    });
  }
});
