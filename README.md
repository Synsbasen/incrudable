# Incrudable

`Incrudable` is a Rails gem that provides a set of common CRUD actions and helpers for controllers. It is designed to standardize and simplify the implementation of controllers in your Rails applications. By including `Incrudable` in your controller, you can handle basic CRUD operations while leveraging Rails' ActiveSupport and Pundit for resource scoping and authorization.

## Motivation

In Rails applications, controllers often share similar patterns for basic CRUD operations. This leads to repetitive and boilerplate code across different controllers. `Incrudable` was created to solve this problem by:

- **DRY Principles**: Eliminating redundant code and ensuring controllers remain lean and consistent.
- **Consistency**: Enforcing uniform behavior across all controllers that include `Incrudable`.
- **Policy Enforcement**: Integrating with Pundit to globally enforce policies for authorization and scoping.
- **Scalability**: Simplifying code maintenance as the number of controllers grows.
- **Error Reduction**: Minimizing the chances of introducing bugs by reusing tested patterns and logic.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'incrudable'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install incrudable
```

## Usage

Include `Incrudable` in your controller to gain access to pre-defined CRUD actions:

```ruby
class ArticlesController < ApplicationController
  include Incrudable
end
```

## Features

### Predefined Actions

The following standard actions are available out of the box:

- `index`: Fetches and sets a collection of records.
- `show`: Fetches and sets a single record for display.
- `new`: Prepares a new record for creation.
- `edit`: Fetches a record for editing.
- `create`: Handles creating a new record.
- `update`: Handles updating an existing record.
- `destroy`: Handles deleting a record.

### Callbacks

- `before_action` callbacks for setting resources:
  - `set_record` for `show`, `edit`, `update`, and `destroy` actions.
  - `set_records` for the `index` action.
  - `set_new_record` for `new` and `create` actions.

- `after_action` callbacks for Pundit authorization:
  - `verify_authorized`: Ensures all actions authorize their resources.
  - `verify_policy_scoped`: Ensures collections are policy-scoped.

### Automatic Resource Identification

`Incrudable` leverages the controller name to dynamically identify the resource it manages. For instance:

- In a controller named `ArticlesController`, the resource is identified as `Article`.
- The corresponding instance variables, such as `@article` or `@articles`, are automatically created and populated.

This means you don’t need to manually define methods to set these variables, reducing boilerplate and improving consistency.

### Example: Controller Before and After `Incrudable`

#### Before `Incrudable`

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = policy_scope(Article)
    authorize @articles
  end

  def show
    @article = policy_scope(Article).find(params[:id])
    authorize @article
  end

  def new
    @article = Article.new
    authorize @article
  end

  def create
    @article = Article.new(article_params)
    authorize @article
    if @article.save
      redirect_to article_path(@article), notice: "Article created successfully."
    else
      render :new
    end
  end

  def edit
    @article = policy_scope(Article).find(params[:id])
    authorize @article
  end

  def update
    @article = policy_scope(Article).find(params[:id])
    authorize @article
    if @article.update(article_params)
      redirect_to article_path(@article), notice: "Article updated successfully."
    else
      render :edit
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :content)
  end
end
```

#### After `Incrudable`

```ruby
class ArticlesController < ApplicationController
  include Incrudable

  private

  def permitted_params
    %i[title content]
  end

  def after_create_path
    article_path(record)
  end

  def after_update_path
    article_path(record)
  end
end
```

By using `Incrudable`, you significantly reduce the code duplication and ensure consistent behavior across all controllers.

### Customization Hooks

Override these methods in your controller to customize behavior:

#### `permitted_params`
Defines the attributes allowed for mass assignment. This method must be overridden in your controller.

#### `after_create_path`
Specifies the path to redirect to after successfully creating a record. Defaults to `redirect_back fallback_location: root_path`.

#### `after_update_path`
Specifies the path to redirect to after successfully updating a record. Defaults to `redirect_back fallback_location: root_path`.

#### `after_destroy_path`
Specifies the path to redirect to after successfully deleting a record. Defaults to the index path of the resource.

#### `record_param_identifier`
Defines the parameter used to fetch records. Defaults to `:id`.

#### `skip_authorization?`
Defines whether to skip authorization checks for the current action. Defaults to `false`.

#### `skip_policy_scope?`
Defines whether to skip policy scope checks for the current action. Defaults to `false`.

### Resource Helpers
If your controller does not follow standard Rails naming conventions, such as when using namespaced or custom modules, the automatic resource detection might not work as expected. In such cases, you can override the `resource` method to explicitly specify the resource class. For example:

```ruby'
class MyModule::ArticlesController < ApplicationController
  include Incrudable

  private

  def resource
    MyModule::Article
  end
end
```

This ensures that `Incrudable` correctly identifies the resource and creates the corresponding instance variables like `@article` or `@articles`. This is particularly useful for applications with complex or modular architectures.
- `record`: Fetches the current instance variable for the resource.

## Localization

`Incrudable` uses Rails' I18n framework for flash messages. Define translations in your locale files:

```yaml
en:
  articles:
    create:
      success: "Article created successfully."
    update:
      success: "Article updated successfully."
    destroy:
      success: "Article deleted successfully."
```

## Error Handling

`Incrudable` raises `NotImplementedError` if `permitted_params` is not defined in your controller.

## Dependencies

- ActiveSupport::Concern
- Pundit (for authorization and policy scoping)

## License

This gem is released under the MIT License.
