// $(function(){
//   $(".tab").on("click", function(e){
//     // $($('.active').data('target')).slideUp(800);
//     $($('.active').data('target')).addClass('hidden');
//     $('.active').removeClass('active');
//     $($(this).data('target')).removeClass('hidden');
//     // $($(this).data('target')).slideDown(800);
//     $(this).addClass('active');
//   });

//   $('#shows_in_theaters').on('mousewheel', function(e) {
//     var event = e.originalEvent,
//     d = event.wheelDelta || -event.detail;
//     this.scrollTop += ( d < 0 ? 1 : -1 ) * 6;
//     e.preventDefault();
//   });

//   window.sr = ScrollReveal({ reset: true });
//   sr.reveal('.movie-item', {
//     origin: 'top',
//     duration: 300,
//     mobile: true,
//     // container: '#scrollable-list'
//   });
// });

$('.movies-list').infinitePages({
  debug: true,
  buffer: 200,
  context: '.movies-list',
  loading: function() {
    return $(this).text("Loading...");
  },
  success: function() {},
  error: function() {
    return $(this).text("Trouble! Please drink some coconut water and click again");
  }
});


$('a.back-to-top').click(function() {
  $('body').animate({
    scrollTop: 0
  });

  return false;
});



$(window).scroll(function() {
  var amountScrolled = 300;

  if ( $(window).scrollTop() > amountScrolled ) {
    $('a.back-to-top').fadeIn('slow');
  } else {
    $('a.back-to-top').fadeOut('slow');
  }
});


