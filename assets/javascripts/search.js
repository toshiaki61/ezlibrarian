(function($) {
  $(function() {
    var $search = $('#search_books,#search_devices'),
      $loader = $('#ajax-indicator'),
      count = 0;
    $search.on('keypress', function(e) {
      var code = (e.keyCode ? e.keyCode : e.which);
      if (code == 13) {
        $search.autocomplete().enable();
        e.preventDefault();
      }
    });
    $search.autocomplete({
      serviceUrl: '/treasures/amazon',
      minChars: 3,
      deferRequestBy: 500,
      dataType: 'json',
      formatResult: function (suggestion, currentValue) {
        var formattedResult = $.Autocomplete.formatResult(suggestion, currentValue);
        var data = suggestion.data;
        if (data.ImageSets && data.ImageSets.ImageSet) {
          var imageSet = ArrayUtil.first(data.ImageSets.ImageSet);
          if (imageSet && imageSet.SwatchImage) {
            formattedResult = '<img src="' + imageSet.SwatchImage.URL + '" height="30"/>' + formattedResult;
          } else {
            //console.log(imageSet);
          }
        }
        return formattedResult;
      },
      onSearchStart: function(query) {
        $loader.show();
        count++;
      },
      onSearchComplete: function(query) {
        count--;
        if (count === 0) {
          $loader.hide();
        }
      },
      onSelect: function (suggestion) {
        var data = suggestion.data;
        var formatting = $search.data('wiki-formatting');
        $.each(BookConverter, function(key, converter) {
          $('#' + key).val(converter(data, formatting));
        });
      },
      transformResult: function(response) {
        response = typeof response === 'string' ? $.parseJSON(response) : response;
        return {
          query: response.query,
          suggestions: $.map(response.suggestions, function(suggestion, index) {
            return {
              value: suggestion.raw.ItemAttributes.Title, 
              data: suggestion.raw
            };
          })
        };
      }
    });
  });
})(jQuery);

