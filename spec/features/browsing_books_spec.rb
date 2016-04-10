require 'rails_helper'

RSpec.describe 'browsing books', type: :feature do
  let!(:book) { create(:book) }
  before(:each) { sign_in_user }

  it 'displays the book details' do
    visit "/books/#{book.id}"

    within ".cover" do
      expect(page).to have_selector("img[src='http://bks0.books.google.co.uk/books?id=#{book.google_id}&printsec=frontcover&img=1&zoom=1&edge=none&source=gbs_api']")
    end

    within ".title" do
      expect(page).to have_content(book.title)
      expect(page).to have_content("by #{book.author}")
    end
  end

  it 'lists the copies of the book' do
    visit "/books/#{book.id}"

    expect(page).to have_content("1 copy")
    within ".copies li" do
      expect(page).to have_link("#1", :href => "/copy/#{book.copies.first.to_param}")
      expect(page).to have_content("Available to borrow")
      expect(page).to have_link("Borrow", :href => "/copy/#{book.copies.first.to_param}/borrow")
    end
  end

  it 'lists previous versions of the book' do
    previous_editor = create(:user)

    with_versioning do
      PaperTrail.whodunnit = previous_editor.id.to_s
      book.update_attributes!(title: 'Goodnight Mister Tom')

      visit "/books/#{book.id}"
      click_on 'See revision history'

      expect(page).to have_selector('table.history')

      entries = page.all('table.history tr').map {|row|
        cells = row.all('td')
        cells.map(&:text).map(&:strip)
      }

      expect(entries).to contain_exactly(
        [ previous_editor.name, "less than a minute ago", "Title: Goodnight Mister Tom" ]
      )
    end
  end

  it 'shows a message when no previous book versions exist' do
    visit "/books/#{book.id}"
    click_on "See revision history"

    assert page.has_content?(book.title)
    assert page.has_content?("No changes have been made to this book yet.")
  end

end
