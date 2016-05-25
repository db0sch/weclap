// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function(){
  $(".tab").on("click", function(e){
    $($('.active').data('target')).addClass('hidden');
    $('.active').removeClass('active');
    $(this).addClass('active');
    $($(this).data('target')).removeClass('hidden');
  });
});
