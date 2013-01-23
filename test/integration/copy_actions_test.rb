require 'integration_test_helper'

class CopyActionsTest < ActionDispatch::IntegrationTest

  context "as a signed in user" do
    setup do
      sign_in_as_stub_user
    end

    context "given an available copy exists" do
      setup do
        @copy = FactoryGirl.create(:copy, :book_reference => "123")
      end

      should "render the copy page" do
        visit "/copy/123"

        assert page.has_content?("123")
        assert page.has_content?(@copy.book.title)
        assert page.has_content?("Available to borrow")
        assert page.has_content?("Borrow")
      end

      should "allow the book to be borrowed" do
        visit "/copy/123"
        click_on "Borrow"

        assert_equal "/copy/123", current_path
        assert page.has_content?("123")
        assert page.has_content?("On loan to you")
        assert page.has_content?("since #{Date.today.strftime("%b %d, %Y")}")
      end

      should "not display the loan history section if no previous loans" do
        visit "/copy/123"

        assert page.has_no_content?("Loan history")
      end

      should "link to the book page" do
        visit "/copy/123"
        assert page.has_link?("See all copies of this book", :href => "/books/#{@copy.book.id}")
      end
    end # given an available copy exists

    context "given a copy is on loan to the signed in user" do
      setup do
        @copy = FactoryGirl.create(:copy, :book_reference => "123")
        @copy.borrow(stub_user)
      end

      should "render the copy page" do
        visit "/copy/123"

        assert page.has_content?("123")
        assert page.has_content?(@copy.book.title)
        assert page.has_content?("On loan to you")
        assert page.has_content?("Return")
      end

      should "allow the book to be returned" do
        visit "/copy/123"
        click_on "Return"

        assert_equal "/copy/123", current_path
        assert page.has_content?("123")
        assert page.has_content?("Available to borrow")
      end
    end

    context "given a copy is on loan to another user" do
      setup do
        @another_user = FactoryGirl.create(:user, :name => "O'Brien")
        @copy = FactoryGirl.create(:copy, :book_reference => "123")
        @copy.borrow(@another_user)
      end

      should "render the copy page" do
        visit "/copy/123"

        assert page.has_content?("123")
        assert page.has_content?(@copy.book.title)
        assert page.has_content?("On loan to O'Brien")
        assert page.has_content?("since #{Date.today.strftime("%b %d, %Y")}")
      end

      should "not allow the book to be returned" do
        visit "/copy/123"

        assert page.has_no_content?("Return")
      end
    end

    context "given a copy which has been borrowed multiple times" do
      setup do
        @copy = FactoryGirl.create(:copy, :book_reference => "53")

        @user1 = FactoryGirl.create(:user, :name => "Julia")
        @user2 = FactoryGirl.create(:user, :name => "Emmanuel Goldstein")

        @loans = [
          FactoryGirl.create(:loan, :copy => @copy, :state => :returned, :user_id => @user1.id, :loan_date => Date.parse("1 January 2012").beginning_of_day, :return_date => Date.parse("15 January 2012").beginning_of_day),
          FactoryGirl.create(:loan, :copy => @copy, :state => :returned, :user_id => @user2.id, :loan_date => Date.parse("5 April 2012").beginning_of_day, :return_date => Date.parse("1 May 2012").beginning_of_day),
          FactoryGirl.create(:loan, :copy => @copy, :state => :returned, :user_id => @user1.id, :loan_date => Date.parse("17 June 2012").beginning_of_day, :return_date => Date.parse("10 July 2012").beginning_of_day)
        ]
      end

      should "display a list of previous loans" do
        visit "/copy/53"

        assert page.has_selector?("h3", :text => "Loan history")

        rows = page.all('table.history tr').map {|r| r.all('th, td').map(&:text).map(&:strip) }
        assert_equal [
          [ "17 June 2012 - 10 July 2012", "Julia" ],
          [ "5 April 2012 -  1 May 2012", "Emmanuel Goldstein" ],
          [ "1 January 2012 - 15 January 2012", "Julia" ]
        ], rows
      end

      should "link the name previous loaning user to their profile" do
        visit "/copy/53"

        assert page.has_link?("Julia", :href => "/user/#{@user1.id}")
        assert page.has_link?("Emmanuel Goldstein", :href => "/user/#{@user2.id}")
      end
    end
  end # as signed in user
end
