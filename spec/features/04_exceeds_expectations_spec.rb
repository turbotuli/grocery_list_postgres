require "spec_helper"

feature "user can update and delete items" do
  scenario "delete an item" do
    db_connection do |conn|
      sql_query_1 = "INSERT INTO groceries (name) VALUES ($1)"
      data_1 = ["eggs"]
      conn.exec_params(sql_query_1, data_1)
    end

    visit "/groceries"
    click_button "Delete"

    expect(page).to_not have_content("eggs")
  end

  scenario "update an item" do
    db_connection do |conn|
      sql_query_1 = "INSERT INTO groceries (name) VALUES ($1)"
      data_1 = ["eggs"]
      conn.exec_params(sql_query_1, data_1)
    end

    visit "/groceries"
    click_button "Update"

    expect(page).to have_css("input[value='eggs']")

    fill_in "Item", with: "Peanut Butter"
    click_button "Update"

    expect(page).to have_content "Peanut Butter"
  end

  scenario "try to update without a name" do
    db_connection do |conn|
      sql_query_1 = "INSERT INTO groceries (name) VALUES ($1)"
      data_1 = ["eggs"]
      conn.exec_params(sql_query_1, data_1)
    end

    visit "/groceries"
    click_button "Update"

    fill_in "Item", with: ""
    click_button "Update"

    expect(page).to have_content "Item:"
    expect(page).to have_css("input[value='eggs']")

    visit "/groceries"
    expect(page).to have_content "eggs"
  end
end
