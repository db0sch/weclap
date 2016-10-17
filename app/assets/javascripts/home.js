
$(document).ready(function() {
  // Smooth scroll
  $(function() {
    $('a[href*="#"]:not([href="#"])').click(function() {
      if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
        var target = $(this.hash);
        target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
        if (target.length) {
          $('html, body').animate({
            scrollTop: target.offset().top
          }, 1000);
          return false;
        }
      }
    });
  });

 //Typedjs 
  $(function(){
    $(".element").typed({
      strings: ["love movies?", "movie night with friends?"],
      // showcursor
      showCursor: true,
      // backspacing speed
      backSpeed: 50,
      typeSpeed: 100,
      // loop
      loop: true,
      cursorChar: "_",
    });
  });

});