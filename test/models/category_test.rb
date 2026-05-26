require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "requires a name" do
    category = Category.new(name: "")
    assert_not category.valid?
  end

  test "name must be unique" do
    duplicate = Category.new(name: categories(:development).name)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "ist bereits vergeben"
  end

  test "generates a slug from the name when blank" do
    category = Category.create!(name: "Daten & Analyse")
    assert_equal "daten-analyse", category.slug
  end

  test "keeps an explicit slug" do
    category = Category.create!(name: "Sonderfall", slug: "custom")
    assert_equal "custom", category.slug
  end

  test "to_param returns the slug" do
    assert_equal categories(:development).slug, categories(:development).to_param
  end

  test "destroying a category nullifies its courses" do
    category = categories(:development)
    course = category.courses.first
    assert_not_nil course
    category.destroy
    assert_nil course.reload.category_id
  end
end
