require 'rails_helper'

RSpec.describe 'borrowing books', type: :feature do
  let(:book) { create(:book) }
  let(:copy) { create(:copy, book: book) }

  before(:each) { sign_in_user }

  it 'borrows a copy that is available' do
    visit copy_path(copy)

    expect(page).to have_content('Available')

    click_on 'Borrow'

    expect(page).to have_content('On loan to you')
  end

  it 'cannot borrow a copy that is on loan' do
    copy.borrow(create(:user))
    visit copy_path(copy)

    expect(page).to have_content('On loan')
    expect(page).to_not have_link('Borrow')
  end

  it 'returns a copy on loan to the current user' do
    copy.borrow(signed_in_user)
    visit copy_path(copy)

    expect(page).to have_content('On loan to you')

    click_on 'Return'

    expect(page).to have_content('Available')
  end

  it 'returns a copy on loan to another user' do
    other_user = create(:user)
    copy.borrow(other_user)
    visit copy_path(copy)

    expect(page).to have_content("On loan to #{other_user.name}")

    click_on 'Return'

    expect(page).to have_content('Available')
    expect(page).to have_content("returned by #{signed_in_user.name}")
  end

  it 'lists previous loans of a copy' do
    previous_user = create(:user)

    loans = create_list(:returned_loan, 5, copy: copy, user: previous_user)

    visit copy_path(copy)

    entries = page.all('table.history tr').map {|row|
      cells = row.all('th, td')
      cells.map(&:text).map(&:strip)
    }

    expect(entries).to contain_exactly(
      *loans.map {|loan|
        [
          "#{I18n.localize loan.loan_date, format: :short_date} - #{I18n.localize loan.return_date, format: :short_date}",
          loan.user.name,
        ]
      }
    )
  end

end
