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
    assert_select "h3", text: "Claude Code im Projektalltag", count: 0
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
end
