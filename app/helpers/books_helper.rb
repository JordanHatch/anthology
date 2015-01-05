module BooksHelper
  def book_cover_tag(book, options = { })
    attributes = {
      class: 'cover',
      alt: "Cover image of '#{book.title}'",
    }.merge(options[:html] || {})

    image_tag cover_url_for(book, options.fetch(:size, "S")), attributes
  end

  def cover_url_for(book, size = "S")
    if book.google_id.present?
      "http://bks0.books.google.co.uk/books?id=#{book.google_id}&printsec=frontcover&img=1&zoom=#{cover_sizes[size]}&edge=none&source=gbs_api"
    elsif book.openlibrary_id.present?
      "http://covers.openlibrary.org/b/olid/#{book.openlibrary_id}-M.jpg"
    else
      ""
    end
  end

  def cover_sizes
    {
      "S" => 1,
      "M" => 2,
      "L" => 3
    }
  end

  def formatted_version_author(version)
    user_id = version.whodunnit
    unless user_id.blank?
      User.where(:id => user_id).first.name || "Unknown user"
    else
      "Unknown user"
    end
  end

  def formatted_version_changes(version)
    version.changeset.map do |key, (old_value,new_value)|
      content_tag :li do
        (key.capitalize + ": " + content_tag(:code){ new_value.to_s }).html_safe
      end
    end.join('').html_safe
  end

  def user_or_second_person(resource_user, signed_in_user)
    return "unknown" unless resource_user.present?
    resource_user == signed_in_user ? 'you' : resource_user.name
  end
end
