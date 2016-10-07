$(document).ready(function() {
  $(function(){
    $(".typewunderlist").typed({
      strings: ["love wunderlist?", "love movies?", "say hello to"],
      // showcursor
      showCursor: true,
      // backspacing speed
      backSpeed: 50,
      typeSpeed: 100,
      // loop
      loop: false,
      cursorChar: "_",
    });
  });

});