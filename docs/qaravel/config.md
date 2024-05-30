---
titleTemplate: Qaravel
---

# Config

Config is where you can define the module settings of the application.

```js
module.exports = {
  name: "Qaravel",
  description: "",
  version: "1.0",
  modules: [
    {
      name: "Example",
      layout: "AdminLayout",
      permissions: ["View", "Edit", "List", "New", "Delete"],
      icon: "fas fa-user-shield",
      softDeletes: true,
      fields: [
        {
          key: "first_name",
          type: "string",
          rule: "required",
          frontend: "type:text|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
        },
        {
          key: "last_name",
          type: "string",
          rule: "required",
          frontend: "type:text|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
        },
        {
          key: "gender",
          type: "string",
          frontend: "type:text|classes:col-xs-12 col-sm-6",
          table: true,
        },
        {
          key: "email",
          type: "string",
          rule: "required|email|unique:admins",
          frontend: "type:email|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
          unique: true,
        },
        {
          key: "phone_number",
          type: "string",
          frontend: "type:text|classes:col-xs-12 col-sm-6",
          table: true,
        },
        {
          key: "email_verified_at",
          type: "string",
          frontend: false,
          fillable: false,
        },
        {
          key: "password",
          type: "string",
          rule: "required|min:6|confirmed",
          frontend: "type:password|classes:col-xs-12 col-sm-6",
          required: true,
        },
        {
          key: "password_confirmation",
          migration: false,
          fillable: false,
          frontend: "type:password|classes:col-xs-12 col-sm-6",
          required: true,
        },
        {
          key: "status",
          type: "string",
          options: ["Active", "Pending", "Disable"],
          default: "Pending",
          frontend: "type:select|classes:col-xs-12 col-sm-6",
          table: true,
          toolbar: true,
        },
        {
          key: "is_active",
          type: "boolean",
          frontend: "type:boolean|classes:col-xs-12 col-sm-6",
          default: true,
        },
        {
          key: "is_super_admin",
          type: "boolean",
          default: false,
          frontend: "type:boolean|classes:col-xs-12 col-sm-6",
        },
        { key: "remember_token", type: "string", fillable: false },
        {
          key: "rfid",
          type: "string",
          frontend: {
            label: "Key fob",
            classes: "col-xs-12 col-sm-6",
            type: "text",
            hint: "A field hint for user...",
          },
        },
      ],
    },
  ],
};
```

## Configuration Attributes

The configuration file defines the settings for various modules of the application. Below is a comprehensive guide to all available configuration attributes.

### General Configuration

#### name
- **Type:** `string`
- **Description:** The name of the application.
- **Example:**
  ```js
  name: "Qaravel"
  ```

#### description
- **Type:** `string`
- **Description:** A brief description of the application.
- **Example:**
  ```js
  description: "An example application configuration"
  ```

#### version
- **Type:** `string`
- **Description:** The version of the application.
- **Example:**
  ```js
  version: "1.0"
  ```

### Modules Configuration

Each module object in the `modules` array can have the following attributes:

#### name
- **Type:** `string`
- **Description:** The name of the module.
- **Example:**
  ```js
  name: "Customer"
  ```

#### layout
- **Type:** `string`
- **Description:** The layout to be used for this module.
- **Example:**
  ```js
  layout: "CustomerLayout"
  ```

#### permissions
- **Type:** `array of strings`
- **Description:** List of permissions for this module. Possible values are `"View"`, `"Edit"`, `"List"`, `"New"`, `"Delete"`.
- **Example:**
  ```js
  permissions: ["View", "Edit", "List", "New", "Delete"]
  ```

#### icon
- **Type:** `string`
- **Description:** Icon to be used for this module, specified as a FontAwesome class.
- **Example:**
  ```js
  icon: "fas fa-user"
  ```

#### softDeletes
- **Type:** `boolean`
- **Description:** Enable or disable soft deletes for this module.
- **Example:**
  ```js
  softDeletes: true
  ```

#### fields
- **Type:** `array of objects`
- **Description:** Array of field objects for the module.
- **Example:**
  ```js
  fields: [
    {
      key: "first_name",
      type: "string",
      rule: "required",
      frontend: "type:text|classes:col-xs-12 col-sm-6",
      required: true,
      table: true,
    }
  ]
  ```

### Field Attributes

Each field object in the `fields` array can have the following attributes:

#### key
- **Type:** `string`
- **Description:** The key for the field.
- **Example:**
  ```js
  key: "first_name"
  ```

#### type
- **Type:** `string`
- **Description:** The data type of the field. Possible values include `"string"`, `"integer"`, `"decimal"`, `"boolean"`, `"date"`, etc. Available [column types](https://laravel.com/docs/11.x/migrations#available-column-types)
- **Example:**
  ```js
  type: "string"
  ```

#### rule
- **Type:** `string`
- **Description:** Validation rules for the field.
- **Example:**
  ```js
  rule: "required|max:50"
  ```

#### frontend
- **Type:** `string` or `object`
- **Description:** Frontend settings for the field. This can be a string specifying the type and classes, or an object with more detailed settings.
  - **String format:** `"type:<input type>|classes:<CSS classes>"`
  - **Object format:**
    - `label` (string): Label for the field.
    - `classes` (string): CSS classes for the field.
    - `type` (string): Input type for the field.
    - `hint` (string): A hint to be displayed for the field.
- **Example:**
  ```js
  frontend: "type:text|classes:col-xs-12 col-sm-6"
  // or
  frontend: {
    label: "First Name",
    classes: "col-xs-12 col-sm-6",
    type: "text",
    hint: "Enter your first name"
  }
  ```

#### required
- **Type:** `boolean`
- **Description:** Whether the field is required.
- **Example:**
  ```js
  required: true
  ```

#### table
- **Type:** `boolean`
- **Description:** Whether the field should be displayed in tables.
- **Example:**
  ```js
  table: true
  ```

#### unique
- **Type:** `boolean`
- **Description:** Whether the field value must be unique.
- **Example:**
  ```js
  unique: true
  ```

#### fillable
- **Type:** `boolean`
- **Description:** Whether the field is fillable.
- **Example:**
  ```js
  fillable: false
  ```

#### migration
- **Type:** `boolean`
- **Description:** Whether the field should be included in migrations.
- **Example:**
  ```js
  migration: false
  ```

#### options
- **Type:** `array of strings`
- **Description:** List of options for select fields.
- **Example:**
  ```js
  options: ["Active", "Pending", "Disable"]
  ```

#### default
- **Type:** `any`
- **Description:** Default value for the field.
- **Example:**
  ```js
  default: "Pending"
  ```

#### toolbar
- **Type:** `boolean`
- **Description:** Whether the field should be included in the toolbar.
- **Example:**
  ```js
  toolbar: true
  ```

## Example Configuration

To demonstrate the versatility of the settings, here is a configuration file that includes modules for `Customer`, `Customer/Order`, `Product`, and `Product/Category`.

```js
module.exports = {
  name: "Qaravel",
  description: "An example application configuration",
  version: "1.0",
  modules: [
    {
      name: "Customer",
      layout: "CustomerLayout",
      permissions: ["View", "Edit", "List", "New", "Delete"],
      icon: "fas fa-user",
      softDeletes: true,
      fields: [
        {
          key: "first_name",
          type: "string",
          rule: "required",
          frontend: "type:text|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
        },
        {
          key: "last_name",
          type: "string",
          rule: "required",
          frontend: "type:text|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
        },
        {
          key: "email",
          type: "string",
          rule: "required|email|unique:customers",
          frontend: "type:email|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
          unique: true,
        },
        {
          key: "phone_number",
          type: "string",
          frontend: "type:text|classes:col-xs-12 col-sm-6",
          table: true,
        },
        {
          key: "address",
          type: "text",
          frontend: "type:textarea|classes:col-xs-12 col-sm-12",
          table: false,
        },
        {
          key: "status",
          type: "string",
          options: ["Active", "Inactive"],
          default: "Active",
          frontend: "type:select|classes:col-xs-12 col-sm-6",
          table: true,
          toolbar: true,
        },
      ],
    },
    {
      name: "Customer/Order",
      layout: "CustomerLayout",
      permissions: ["View", "Edit", "List", "New", "Delete"],
      icon: "fas fa-shopping-cart",
      softDeletes: false,
      fields: [
        {
          key: "order_id",
          type: "string",
          rule: "required|unique:orders",
          frontend: "type:text|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
          unique: true,
        },
        {
          key: "customer_id",
          type: "integer",
          rule: "required",
          frontend: "type:number|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
        },
        {
          key: "order_date",
          type: "date",
          rule: "required",
          frontend: "type:date|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
        },
        {
          key: "status",
          type: "string",
          options: ["Pending", "Shipped", "Delivered", "Cancelled"],
          default: "Pending",
          frontend: "type:select|classes:col-xs-12 col-sm-6",
          table: true,
          toolbar: true,
        },
        {
          key: "total_amount",
          type: "decimal",
          rule: "required",
          frontend: "type:number|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
        },
      ],
    },
    {
      name: "Product",
      layout: "ProductLayout",
      permissions: ["View", "Edit", "List", "New", "Delete"],
      icon: "fas fa-box",
      softDeletes: true,
      fields: [
        {
          key: "product_id",
          type: "string",
          rule: "required|unique:products",
          frontend

: "type:text|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
          unique: true,
        },
        {
          key: "name",
          type: "string",
          rule: "required",
          frontend: "type:text|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
        },
        {
          key: "description",
          type: "text",
          frontend: "type:textarea|classes:col-xs-12 col-sm-12",
          table: false,
        },
        {
          key: "price",
          type: "decimal",
          rule: "required",
          frontend: "type:number|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
        },
        {
          key: "category_id",
          type: "integer",
          rule: "required",
          frontend: "type:number|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
        },
        {
          key: "stock",
          type: "integer",
          rule: "required|min:0",
          frontend: "type:number|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
        },
        {
          key: "status",
          type: "string",
          options: ["Available", "Out of Stock"],
          default: "Available",
          frontend: "type:select|classes:col-xs-12 col-sm-6",
          table: true,
          toolbar: true,
        },
      ],
    },
    {
      name: "Product/Category",
      layout: "ProductLayout",
      permissions: ["View", "Edit", "List", "New", "Delete"],
      icon: "fas fa-tags",
      softDeletes: true,
      fields: [
        {
          key: "category_id",
          type: "string",
          rule: "required|unique:categories",
          frontend: "type:text|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
          unique: true,
        },
        {
          key: "name",
          type: "string",
          rule: "required",
          frontend: "type:text|classes:col-xs-12 col-sm-6",
          required: true,
          table: true,
        },
        {
          key: "description",
          type: "text",
          frontend: "type:textarea|classes:col-xs-12 col-sm-12",
          table: false,
        },
      ],
    },
  ],
};
```

### Explanation

- **Customer Module**: Manages customer information with fields like `first_name`, `last_name`, `email`, etc.
- **Customer/Order Module**: Handles customer orders with fields such as `order_id`, `customer_id`, `order_date`, etc.
- **Product Module**: Manages product information with fields like `product_id`, `product_name`, `category_id`, etc.
- **Product/Category Module**: Manages product categories with fields such as `category_id`, `category_name`, `description`, etc.

This configuration provides a comprehensive structure for managing customers, their orders, products, and product categories, each with specified fields, permissions, and layout settings.