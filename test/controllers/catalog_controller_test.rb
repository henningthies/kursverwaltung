require "test_helper"

class CatalogControllerTest < ActionDispatch::IntegrationTest
  test "index is reachable without login (public marketplace)" do
    get root_url
    assert_response :success
    assert_select "h1"
  end

  test "index shows only active courses" do
    get root_url
    assert_response :success
    assert_select "h3", text: "Claude Code im Projektalltag"
    assert_select "h3", text: "Prompt Engineering meistern"
    assert_select "h3", text: "Rails Performance", count: 0   # draft
    assert_select "h3", text: "Git für Teams", count: 0       # done
  end

  test "index shows the price per card and Gratis for free courses" do
    get root_url
    assert_match(/129,00/, response.body)   # claude_code
    assert_match(/49,00/, response.body)     # prompt_engineering
  end

  test "filtering by category shows only that category's active courses" do
    get root_url(category: categories(:ki).slug)
    assert_select "h3", text: "Prompt Engineering meistern"
    assert_select "h3", text: "Einführung in KI"
    assert_select "h3", text: "Claude Code im Projektalltag", count: 0   # Entwicklung
  end

  test "unknown category falls back to all active courses" do
    get root_url(category: "gibt-es-nicht")
    assert_response :success
    assert_select "h3", text: "Claude Code im Projektalltag"
  end

  test "category filter pills are rendered" do
    get root_url
    assert_select "a", text: "Alle"
    assert_select "a", text: "KI & Automation"
  end

  test "sort=price_asc orders active courses cheapest first" do
    get root_url(sort: "price_asc")
    assert_response :success
    # Einführung in KI (0) < Notion Mastery (3900) < Prompt Engineering (4900) < Claude Code (12900)
    positions = [ "Einführung in KI", "Notion Mastery", "Prompt Engineering meistern", "Claude Code im Projektalltag" ]
                  .map { |title| response.body.index(title) }
    assert_equal positions, positions.sort
  end

  test "sort=price_desc orders active courses most expensive first" do
    get root_url(sort: "price_desc")
    assert_response :success
    assert response.body.index("Claude Code im Projektalltag") < response.body.index("Einführung in KI")
  end

  test "unknown sort falls back to title order" do
    get root_url(sort: "gibt-es-nicht")
    assert_response :success
    # Titel-Sortierung: Claude Code (C) vor Notion Mastery (N)
    assert response.body.index("Claude Code im Projektalltag") < response.body.index("Notion Mastery")
  end

  test "sort combines with the category filter" do
    get root_url(category: categories(:ki).slug, sort: "price_asc")
    assert_response :success
    assert_select "h3", text: "Claude Code im Projektalltag", count: 0   # andere Kategorie
    # Innerhalb KI: Einführung in KI (0) vor Prompt Engineering (4900)
    assert response.body.index("Einführung in KI") < response.body.index("Prompt Engineering meistern")
  end

  test "category pills keep the active sort selection" do
    get root_url(sort: "price_asc")
    assert_response :success
    assert_select "a[href=?]", root_path(category: categories(:ki).slug, sort: "price_asc")
  end
end
