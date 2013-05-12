(function($) {
  $(function() {
    var $addReview = $('#add-review');
    $('.open-review').on('click', function() {
      $addReview.removeClass('hidden');
      return false;
    });
    $('.close-review').on('click', function() {
      $addReview.addClass('hidden');
      return false;
    });
  });
})(jQuery);

