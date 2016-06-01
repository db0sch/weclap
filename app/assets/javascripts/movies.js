$(function(){
  $(".tab").on("click", function(e){
    // $($('.active').data('target')).slideUp(800);
    $($('.active').data('target')).addClass('hidden');
    $('.active').removeClass('active');
    $($(this).data('target')).removeClass('hidden');
    // $($(this).data('target')).slideDown(800);
    $(this).addClass('active');
  });

  $('#shows_in_theaters').on('mousewheel', function(e) {
    var event = e.originalEvent,
    d = event.wheelDelta || -event.detail;
    this.scrollTop += ( d < 0 ? 1 : -1 ) * 6;
    e.preventDefault();
  });
  window.sr = ScrollReveal().reveal('.movie-item');
});
