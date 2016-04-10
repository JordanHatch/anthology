require 'rails_helper'

RSpec.describe 'start page', type: :feature do
  before(:each) { sign_in_user }

  it 'tells the user how many books they have on loan' do
    create_list(:loan, 5, user: signed_in_user)

    visit root_path

    expect(page).to have_content("Welcome, #{signed_in_user.name}!")
    expect(page).to have_content('You have 5 books on loan')
  end

  it 'lists recently added books' do
    create_list(:copy, 10)
    recent_copy = create(:copy)

    visit root_path

    within '.recently-added' do
      expect(page).to have_link(recent_copy.book.title,
                                href: copy_path(recent_copy))
    end
  end

  it 'list recent loans' do
    loans = create_list(:loan, 5)

    visit root_path

    within '.recent-activity' do
      loans.reverse.each_with_index do |loan, i|
        within "li:nth-of-type(#{i+1})" do
          expect(page).to have_link(loan.user.name, href: user_path(loan.user))
          expect(page).to have_link("##{loan.copy.book_reference}: #{loan.book.title}", href: copy_path(loan.copy))
        end
      end
    end
  end
end
