require "rails_helper"

RSpec.describe "Player screen waiting invite", type: :system do
  include_context "waiting invite"

  describe "with a pointer and no Web Share" do
    include_context "waiting invite with a pointer and no Web Share"

    it "copies the join link and confirms, then says when it could not" do
      page.execute_script("window.__copied = null; navigator.clipboard.writeText = (t) => { window.__copied = t; return Promise.resolve() }")
      click_button "Copy link"
      expect(page).to have_button("Copied ✓")
      expect_join_url(page.evaluate_script("window.__copied"))
      expect(page).to have_button("Copy link", wait: 3)

      page.execute_script("navigator.clipboard.writeText = () => Promise.reject(new Error('denied'))")
      click_button "Copy link"
      expect(page).to have_button("Couldn't copy")
      expect(page).to have_button("Copy link", wait: 3)
    end
  end
end
