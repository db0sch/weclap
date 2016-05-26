
$(function(){
  $(".tab").on("click", function(e){
    $($('.active').data('target')).slideUp(800);
    $('.active').removeClass('active');
    $($(this).data('target')).slideDown(800);
    $(this).addClass('active');
  });
});
