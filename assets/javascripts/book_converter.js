var BookConverter = {
  'book_title': function(data) {
    if (data.ItemAttributes && data.ItemAttributes.Title) {
      return ArrayUtil.join(data.ItemAttributes.Title);
    }
    return '';
  },
  'book_author': function(data) {
    if (data.ItemAttributes && data.ItemAttributes.Author) {
      return ArrayUtil.join(data.ItemAttributes.Author);
    }
    return '';
  },
  'book_publisher': function(data) {
    if (data.ItemAttributes && data.ItemAttributes.Publisher) {
      return ArrayUtil.join(data.ItemAttributes.Publisher);
    }
    return '';
  },
  'book_published_on': function(data) {
    if (data.ItemAttributes && data.ItemAttributes.PublicationDate) {
      var published_on = data.ItemAttributes.PublicationDate;
      if (published_on.length === 7) {
        published_on += '-01';
      }
      return published_on;
    }
    return '';
  },
  'book_value': function(data) {
    if (data.ItemAttributes && data.ItemAttributes.ListPrice.Amount) {
      return data.ItemAttributes.ListPrice.Amount;
    }
    return '';
  },
  'book_isbn': function(data) {
    if (data.ItemAttributes && data.ItemAttributes.EAN) {
      return data.ItemAttributes.EAN;
    }
    return '';
  },
  'book_pages': function(data) {
    if (data.ItemAttributes && data.ItemAttributes.NumberOfPages) {
      return data.ItemAttributes.NumberOfPages;
    }
    return '';
  },
  'book_content': function(data, formatting) {
    var content = '';
    if (data.DetailPageURL) {
      content += WikiUtil.detail(data.DetailPageURL, formatting);
      content += '\n';
    }
    if (data.EditorialReviews && data.EditorialReviews.EditorialReview) {
      content += ArrayUtil.first(data.EditorialReviews.EditorialReview).Content;
    }
    return content;
  },
  'book_intro_url': function(data) {
    if (data.ImageSets && data.ImageSets.ImageSet) {
      return ArrayUtil.first(data.ImageSets.ImageSet).MediumImage.URL;
    }
    return '';
  }
};

var ArrayUtil = {
  join: function(data) {
    var data = jQuery.isArray(data) ? data.join(',') : data;
    return data.replace(/\s+/g, '');
  },
  first: function(data) {
      return jQuery.isArray(data) ? jQuery(data).first() : data;
  }
};

var WikiUtil = {
  detail: function(data, formatting) {
    if (!data) {
      return '';
    }
    if (formatting === 'textile') {
      return '"detail":' + data;
    }
    if (formatting === 'markdown') {
      return '[detail](' + data + ')';
    }
    return data;
  }
};