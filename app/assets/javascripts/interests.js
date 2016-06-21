$(document).ready(function() {
  $(function() {
    $('.selectpicker.checkbox-diff').on('change', function(){
      var selected = $(this).find("option:selected").val();
      if (selected === 'on_vod'){
        $(".interest-js").removeClass('hidden')
        $(".interest-js:not(.streams)").addClass('hidden');
      }
      else if (selected === 'on_Theater'){
        $(".interest-js").removeClass('hidden')
        $(".interest-js:not(.theater)").addClass('hidden');
      }
      else if (selected === 'all'){
        $(".interest-js").removeClass('hidden')
      }
    });

    // $('.selectpicker.sort-by').on('change', function(){
    //   var selected = $(this).find("option:selected").val();
    //   if (selected === 'rating'){

    //   }
    //   else if (selected === 'release_date'){
    //   }
    // });

    $('.selectpicker.genres').on('changed.bs.select', function(){
      var selected =  $('.selectpicker.genres').select().val();
        if (selected == "All") {
          $(".interest-js").removeClass('hidden');
        }
        else {
          $(".interest-js").addClass('hidden');
          for (var i = 0; i < selected.length; i += 1) {
            $(".interest-js." + selected[i] + "").removeClass('hidden');
          }
        }
    });
  });

});
