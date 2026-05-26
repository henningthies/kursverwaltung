---
name: vanilla-rails
description: Best practices for writing Rails code in the 37signals/Basecamp style. Use when implementing features, refactoring, or reviewing Rails code.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Vanilla Rails Best Practices

This skill documents the coding patterns and conventions distilled from 37signals Rails applications (Fizzy, Writebook, Campfire) and adapted for modern Rails 8 development.

## Core Philosophy

> "We favor a vanilla Rails approach with thin controllers directly invoking a rich domain model. We don't use services or other artifacts to connect the two." — 37signals STYLE.md

Key principles:
1. **Rails conventions over abstractions** - Use the framework as intended
2. **Rich domain models** - Business logic lives in models
3. **Thin controllers** - HTTP handling only
4. **Concerns for composition** - Not inheritance, not services
5. **Server-rendered HTML** - Hotwire for interactivity

## Model Patterns

### Structure and Organization

Models use concerns for feature composition:

```ruby
class Card < ApplicationRecord
  include Assignable, Attachments, Broadcastable, Eventable, Searchable, Taggable

  # Associations
  belongs_to :board
  has_many :comments, dependent: :destroy

  # Scopes
  scope :ordered, -> { order(:created_at) }
  scope :preloaded, -> { includes(:tags, :assignees).with_rich_text_description }

  # Enums
  enum :status, %w[active closed archived].index_by(&:itself), default: :active

  # Validations
  validates :title, presence: true

  # Instance methods
  def close!
    update!(status: :closed, closed_at: Time.current)
  end
end
```

### Concerns Organization

Place concerns in subdirectories matching the model:

```
app/models/
├── card.rb
├── card/
│   ├── assignable.rb      # Assignment logic
│   ├── broadcastable.rb   # Turbo broadcasts
│   ├── eventable.rb       # Activity tracking
│   └── searchable.rb      # Full-text search
└── concerns/
    └── positionable.rb    # Shared across models
```

### Current Attributes Pattern

Use `Current` for request-scoped state (never pass user through methods):

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :account, :request

  delegate :host, to: :request, prefix: true, allow_nil: true
end

# Usage in models
class Comment < ApplicationRecord
  belongs_to :creator, class_name: "User", default: -> { Current.user }
end
```

### Enum Patterns

Use the hash form with defaults and suffixes:

```ruby
enum :status, %w[active pending closed].index_by(&:itself), default: :active
enum :role, %i[member admin owner], suffix: true  # user.admin_role?
enum :involvement, %w[nothing mentions everything].index_by(&:itself), prefix: :involved_in
```

### Scope as API

Queries build through chainable scopes:

```ruby
scope :active, -> { where(status: :active) }
scope :ordered, -> { order(created_at: :desc) }
scope :with_creator, -> { includes(:creator) }
scope :for_board, ->(board) { where(board: board) }

# Composed in controller
@cards = Card.active.ordered.with_creator.for_board(@board)
```

### Async Job Pattern

Use `_later` and `_now` suffixes:

```ruby
module Card::Broadcastable
  def broadcast_later
    Card::BroadcastJob.perform_later(self)
  end

  def broadcast_now
    broadcast_replace_to board, target: dom_id(self)
  end
end

class Card::BroadcastJob < ApplicationJob
  def perform(card)
    card.broadcast_now
  end
end
```

## Controller Patterns

### Thin Controllers

Controllers handle HTTP only - no business logic:

```ruby
class CardsController < ApplicationController
  before_action :set_card, only: %i[show edit update destroy]

  def create
    @card = @board.cards.create!(card_params)
    redirect_to @card
  end

  def update
    @card.update!(card_params)
    redirect_to @card
  end

  private

  def set_card
    @card = Card.find(params[:id])
  end

  def card_params
    params.expect(card: [:title, :description])
  end
end
```

### Resource-Based Routing (REST)

Model actions as resources, not verbs:

```ruby
# Bad - custom actions
resources :cards do
  post :close
  post :reopen
  post :assign
end

# Good - nested resources
resources :cards do
  resource :closure, only: %i[create destroy]       # close/reopen
  resources :assignments, only: %i[create destroy]  # assign/unassign
end
```

### Controller Concerns

Cross-cutting behavior in concerns:

```ruby
# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :signed_in?, :current_user
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def require_authentication
    redirect_to login_path unless signed_in?
  end

  def signed_in?
    Current.user.present?
  end

  def current_user
    Current.user
  end
end
```

### Scoped Resources

Filter through associations:

```ruby
# Good - scoped through current context
def set_card
  @card = Current.account.cards.find(params[:id])
end

# Bad - global lookup with authorization after
def set_card
  @card = Card.find(params[:id])
  authorize! @card
end
```

## View Patterns

### Helpers for Component Assembly

Complex view logic in helpers:

```ruby
# app/helpers/cards_helper.rb
def card_tag(card, &)
  tag.div id: dom_id(card),
    class: "card #{card.status}",
    data: {
      controller: "card",
      card_id: card.id
    }, &
end
```

### Turbo Streams for Real-Time

Server-rendered partials broadcast via Turbo:

```ruby
# Model callback
after_create_commit -> { broadcast_append_to board, :cards }

# Or explicit
def broadcast_create
  Turbo::StreamsChannel.broadcast_append_to(
    board, :cards,
    target: "cards",
    partial: "cards/card",
    locals: { card: self }
  )
end
```

## Testing Patterns

### Fixtures Over Factories

Use YAML fixtures. Fixtures are shared infrastructure - modify carefully:

```yaml
# test/fixtures/cards.yml
logo_card:
  board: design
  title: Design new logo
  status: active
  creator: david

feature_card:
  board: engineering
  title: Add user auth
  status: active
  creator: david
```

When adding fixtures:
- Check existing fixtures first - reuse before creating
- Keep fixture data realistic and minimal
- Name fixtures descriptively by their role in tests

### Assertion Quality

**NEVER use vague assertions.** Always assert exact values and state changes.

```ruby
# Good - precise assertions
assert_equal "Design new logo", card.title
assert_equal 3, board.cards.count
assert_equal "closed", card.reload.status
assert_includes response.body, "Card created successfully"

# Bad - vague assertions that hide bugs
assert card.title.present?
assert board.cards.any?
assert card.persisted?
assert response.successful?
```

Preferred assertion patterns:
- `assert_equal expected, actual` - exact value matching
- `assert_difference "Model.count", 1` - precise count changes
- `assert_changes -> { record.reload.attribute }, from: "old", to: "new"` - state transitions
- `assert_raises ActiveRecord::RecordInvalid` - specific exceptions
- `assert_not_nil` only when nil vs non-nil is the actual business rule

### Model Tests

Test the model's public API - validations, scopes, and business methods:

```ruby
class CardTest < ActiveSupport::TestCase
  setup do
    @card = cards(:logo_card)
  end

  # Validations - test boundary conditions
  test "requires title" do
    @card.title = nil
    assert_not @card.valid?
    assert_includes @card.errors[:title], "can't be blank"
  end

  # Scopes - verify exact records returned
  test "active scope returns only active cards" do
    active = Card.active
    assert_equal 2, active.count
    assert active.all? { |c| c.status == "active" }
  end

  # Business methods - verify state changes and return values
  test "close sets status and timestamp" do
    freeze_time do
      @card.close
      assert_equal "closed", @card.status
      assert_equal Time.current, @card.closed_at
    end
  end

  # Associations - test dependent behavior
  test "destroying card destroys comments" do
    assert_difference "Comment.count", -@card.comments.count do
      @card.destroy
    end
  end
end
```

### Controller Integration Tests

Test HTTP behavior: status codes, redirects, response content, and authorization:

```ruby
class CardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @card = cards(:logo_card)
    sign_in users(:david)
  end

  # CRUD - verify response AND state change
  test "should create card" do
    assert_difference("Card.count", 1) do
      post cards_url, params: { card: { title: "New card" } }
    end
    card = Card.last
    assert_equal "New card", card.title
    assert_redirected_to card_url(card)
  end

  test "should update card" do
    patch card_url(@card), params: { card: { title: "Updated" } }
    assert_redirected_to card_url(@card)
    assert_equal "Updated", @card.reload.title
  end

  # Authorization - test on every action
  test "requires authentication to create" do
    sign_out
    post cards_url, params: { card: { title: "New" } }
    assert_redirected_to login_url
  end

  # Sad path - verify error handling
  test "invalid params returns unprocessable entity" do
    post cards_url, params: { card: { title: "" } }
    assert_response :unprocessable_entity
  end
end
```

### Concern Tests

Test concerns via the model that includes them, not in isolation:

```ruby
# Test Assignable concern through Card
class CardAssignmentTest < ActiveSupport::TestCase
  test "assign adds user to assignees" do
    card = cards(:logo_card)
    user = users(:david)
    assert_difference "card.assignees.count", 1 do
      card.assign(user)
    end
    assert_includes card.assignees, user
  end
end
```

### Test Description Format

Use `test "description"` not `def test_description`:

```ruby
# Good
test "card closes when closure created" do
  assert_changes -> { @card.reload.status }, to: "closed" do
    post card_closure_url(@card)
  end
end

# Bad
def test_card_closes_when_closure_created
  # ...
end
```

### Test Anti-Patterns

1. **Testing private methods** - Test through the public interface only
2. **Vague assertions** - `assert obj.valid?` tells you nothing when it fails
3. **No state verification after actions** - Always reload and check the database
4. **Missing sad paths** - Test invalid input, unauthorized access, missing records
5. **Over-mocking** - Use real objects and fixtures; mocks hide integration bugs
6. **Testing framework behavior** - Don't test that `validates :title, presence: true` works; test YOUR business rules

## Style Conventions

### Expanded Conditionals Over Guard Clauses

Prefer explicit if/else:

```ruby
# Good
def todos_for_group
  if ids = params.dig(:todolist, :todo_ids)
    @bucket.todos.find(ids.split(","))
  else
    []
  end
end

# Bad (guard clause with trivial body; acceptable only at method start for non-trivial bodies)
def todos_for_group
  ids = params.dig(:todolist, :todo_ids)
  return [] unless ids
  @bucket.todos.find(ids.split(","))
end
```

### Method Ordering by Invocation

Order methods vertically by call order:

```ruby
class Processor
  def process
    validate
    transform
    save
  end

  private

  def validate
    validate_format
    validate_content
  end

  def validate_format
    # ...
  end

  def validate_content
    # ...
  end

  def transform
    # ...
  end

  def save
    # ...
  end
end
```

### Visibility Modifiers

No blank line after private, indent content:

```ruby
class Example
  def public_method
    # ...
  end

  private
    def private_method_1
      # ...
    end

    def private_method_2
      # ...
    end
end
```

### Bang Methods Only for Counterparts

Use bang methods (!) only when a non-bang version exists:

```ruby
# Good - Rails provides both save and save!
card.save!

# Bad - no close counterpart exists
def close!
  # Should just be: def close
end
```

## JavaScript/Stimulus Patterns

### Modern Stimulus Controllers

Use private fields and targets:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output"]
  static classes = ["active", "loading"]
  static values = { url: String, delay: { type: Number, default: 300 } }

  #timer

  connect() {
    this.#startPolling()
  }

  disconnect() {
    this.#stopPolling()
  }

  #startPolling() {
    this.#timer = setInterval(() => this.#refresh(), this.delayValue)
  }

  #stopPolling() {
    clearInterval(this.#timer)
  }

  async #refresh() {
    const response = await fetch(this.urlValue)
    this.outputTarget.innerHTML = await response.text()
  }
}
```

### Outlet Pattern for Cross-Controller Communication

```javascript
export default class extends Controller {
  static outlets = ["messages"]

  send() {
    this.messagesOutlet.addMessage(this.inputTarget.value)
  }
}
```

## Database Conventions

### Migrations

Always add indexes for foreign keys and frequently queried columns:

```ruby
class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.references :board, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.integer :status, default: 0, null: false
      t.timestamps
    end

    add_index :cards, [:board_id, :status]
  end
end
```

### Naming Conventions

- Foreign keys: `{table}_id`
- Timestamps: `{action}_at` (closed_at, published_at)
- Counters: `{items}_count`
- Booleans: `is_{state}` or just `{state}` (active, published)

## Anti-Patterns to Avoid

1. **Service objects** - Use model methods and concerns instead
2. **Decorators/presenters** - Use helpers and view components
3. **Form objects** - Use model validations and accepts_nested_attributes
4. **Query objects** - Use scopes
5. **Fat controllers** - Move logic to models
6. **Callbacks for business logic** - Use explicit method calls
7. **Metaprogramming** - Prefer explicit code
8. **Premature abstraction** - Wait for duplication before extracting
