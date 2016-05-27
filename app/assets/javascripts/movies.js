
$(function(){
  $(".tab").on("click", function(e){
    // $($('.active').data('target')).slideUp(800);
    $($('.active').data('target')).addClass('hidden');
    $('.active').removeClass('active');
    $($(this).data('target')).removeClass('hidden');
    // $($(this).data('target')).slideDown(800);
    $(this).addClass('active');
  });
});
