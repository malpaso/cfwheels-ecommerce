<cfcomponent extends="plugins.dbmigrate.Migration" hint="Initial database creation" output="false">

	<cffunction name="up">
		<cfscript>

			// accounts
			t = createTable(name="accounts",force=true);
			t.string(columnNames="name,account_type",null=false);
			t.decimal(columnNames="monthly_charge",null=false,default="0.0",precision=8,scale=2);
			t.boolean(columnNames="active",default=true,null=false);
			t.timestamps();
			t.create();

			// users
			t = createTable(name="users",force=true);
			t.string(columnNames="first_name,last_name",limit=40);
			t.date("birth_date");
			t.string(columnNames="email,state");
			t.integer("account_id");
			t.string(columnNames="customer_cim_id,password_salt,crypted_password,perishable_token,persistence_token,access_token");
			t.integer(columnNames="comments_count",default=0);
			t.timestamps();
			t.create();
			
			addIndex(table="users",columnNames="first_name",indexName="idx_users_first_name");
			addIndex(table="users",columnNames="last_name",indexName="idx_users_last_name");
			addIndex(table="users",columnNames="email",indexName="idx_users_email",unique=true);
			addIndex(table="users",columnNames="perishable_token",indexName="idx_users_perishable_token",unique=true);
			addIndex(table="users",columnNames="persistence_token",indexName="idx_users_persistence_token",unique=true);
			addIndex(table="users",columnNames="access_token",indexName="idx_users_access_token",unique=true);

			// states
			t = createTable(name="states",force=true);
			t.string(columnNames="name",null=false);
			t.string(columnNames="abbreviation",null=false,limit=5);
			t.string("described_as");
			t.integer(columnNames="country_id,shipping_zone_id",null=false);
			t.create();
			
			addIndex(table="states",columnNames="name",indexName="idx_states_name");
			addIndex(table="states",columnNames="country_id",indexName="idx_states_country_id");
			addIndex(table="states",columnNames="abbreviation",indexName="idx_states_abbreviation");
	
			// countries
			t = createTable(name="countries",force=true);
			t.string("name");
			t.string(columnNames="abbreviation",limit=5);
			t.create();
			
			addIndex(table="countries",columnNames="name",indexName="idx_countries_name");
			
			if(get("use_foreign_keys")){
				execute("alter table states add constraint fk_states_countries foreign key (country_id) references countries(id);");
			}

			// addresses
			t = createTable(name="addresses",force=true);
			t.integer("address_type_id");
			t.string(columnNames="first_name,last_name");
			t.integer(columnNames="addressable_id",null=false);
			t.string(columnNames="addressable_type,address1",null=false);
			t.string("address2");
			t.string(columnNames="city",null=false);
			t.integer("state_id");
			t.string("state_name");
			t.string(columnNames="zip_code",null=false);
			t.integer("phone_id");
			t.string("alternative_phone");
			t.boolean(columnNames="default,billing_default",default=false);
			t.boolean(columnNames="active",default=true);
			t.timestamps();
			t.create();
			
			addIndex(table="addresses",columnNames="state_id",indexName="idx_addresses_state_id");
			addIndex(table="addresses",columnNames="addressable_id",indexName="idx_addresses_addressable_id");
			addIndex(table="addresses",columnNames="addressable_type",indexName="idx_addresses_addressable_type");
			
			if(get('use_foreign_keys')){
				execute('alter table addresses add constraint fk_addresses_states foreign key (state_id) references states(id)');
			}
			
			// address types
			t = createTable(name="address_types",force=true);
			t.string(columnNames="name",null=false,limit=64);
			t.string("description");
			t.create();
			
			addIndex(table="address_types",columnNames="name",indexName="idx_address_types_name");

			// roles
			t = createTable(name="roles",force=true);
			t.string(columnNames="name",null=false,limit=30);
			t.create();
			
			addIndex(table="roles",columnNames="name",indexName="idx_roles_name");
			
			// user_roles
			t = createTable(name="user_roles",force=true);
			t.integer(columnNames="role_id,user_id",null=false);
			t.create();
			
			addIndex(table="user_roles",columnNames="role_id",indexName="idx_user_roles_role_id");
			addIndex(table="user_roles",columnNames="user_id",indexName="idx_user_roles_user_id");
			
			if(get('use_foreign_keys')){
				execute('alter table user_roles add constraint fk_user_roles_role_id foreign key (role_id) references roles(id)');
				execute('alter table user_roles add constraint fk_user_roles_user_id foreign key (user_id) references users(id)');
			}
			
			// prototypes
			t = createTable(name="prototypes",force=true);
			t.string(columnNames="name",null=false);
			t.boolean(columnNames="active",default=true,null=false);
			t.create();
			
			// properties
			t = createTable(name="properties",force=true);
			t.string(columnNames="identifying_name",null=false);
			t.string("display_name");
			t.boolean(columnNames="active",default=true);
			t.create();
			
			// prototype_properties
			t = createTable(name="prototype_properties",force=true);
			t.integer(columnNames="prototype_id,property_id",null=false);
			t.create();
			
			addIndex(table="prototype_properties",columnNames="prototype_id",indexName="idx_prototype_properties_prototype_id");
			addIndex(table="prototype_properties",columnNames="property_id",indexName="idx_prototype_properties_property_id");
			
			if(get('use_foreign_keys')){
				execute('alter table prototype_properties add constraint fk_prototype_properties_prototypes foreign key (prototype_id) references prototypes(id)');
				execute('alter table prototype_properties add constraint fk_prototype_properties_properties foreign key (property_id) references properties(id)');
			}			

			// products
			t = createTable(name="products",force=true);
			t.string(columnNames="name",null=false);
			t.text(columnNames="description,product_keywords");
			t.integer("tax_category_id,brand_id");
			t.integer(columnNames="product_type_id",null=false);
			t.integer("prototype_id");
			t.integer(columnNames="shipping_category_id,tax_status_id",null=false);
			t.string(columnNames="permalink",null=false);
			t.datetime(columnNames="available_at");
			t.string(columnNames="meta_keywords,meta_description");
			t.boolean(columnNames="featured",default=false);
			t.text("description_markup");
			t.boolean(columnNames="active",default=false);
			t.timestamps();
			t.create();
			
			addIndex(table="products",columnNames="name",indexName="idx_products_name");
			addIndex(table="products",columnNames="tax_category_id",indexName="idx_products_tax_category_id");
			addIndex(table="products",columnNames="product_type_id",indexName="idx_products_product_type_id");
			addIndex(table="products",columnNames="shipping_category_id",indexName="idx_products_shipping_category_id");
			addIndex(table="products",columnNames="prototype_id",indexName="idx_products_prototype_id");
			addIndex(table="products",columnNames="permalink",indexName="idx_products_permalink",unique=true);

			// variants
			t = createTable(name="variants",force=true);
			t.integer(columnNames="product_id",null=false);
			t.string(columnNames="sku",null=false);
			t.string("name");
			t.decimal(columnNames="price,cost",null=false,precision=8,scale=2,default="0.0");
			t.boolean(columnNames="master",default=false,null=false);
			t.integer("inventory_id");
			t.integer("brand_id");
			t.timestamps();
			t.create();
			
			addIndex(table="variants",columnNames="sku",indexName="idx_variants_sku");
			addIndex(table="variants",columnNames="product_id",indexName="idx_variants_product_id");
			addIndex(table="variants",columnNames="brand_id",indexName="idx_variants_brand_id");
			
			if(get('use_foreign_keys')){
				execute('alter table variants add constraint fk_variants_products foreign key (product_id) references products(id)');
			}
			
			// variant_properties
			t = createTable(name="variant_properties",force=true);
			t.integer(columnNames="variant_id,property_id",null=false);
			t.string(columnNames="description",null=false);
			t.boolean(columnNames="primary",default=false);
			t.create();
			
			addIndex(table="variant_properties",columnNames="variant_id",indexName="idx_variant_properties_variant_id");
			addIndex(table="variant_properties",columnNames="property_id",indexName="idx_variant_properties_property_id");

			if(get('use_foreign_keys')){
				execute('alter table variant_properties add constraint fk_variant_properties_variants foreign key (variant_id) references variants(id)');
				execute('alter table variant_properties add constraint fk_variant_properties_properties foreign key (property_id) references properties(id)');
			}	
 
 			// product_properties
 			t = createTable(name="product_properties",force=true);
 			t.integer(columnNames="product_id,property_id",null=false);
 			t.integer("position");
 			t.string(columnNames="description",null=false);
 			t.create();
 			
 			addIndex(table="product_properties",columnNames="product_id",indexName="idx_product_properties_product_id");
 			addIndex(table="product_properties",columnNames="property_id",indexName="idx_product_properties_property_id");
 			
			if(get('use_foreign_keys')){
				execute('alter table product_properties add constraint fk_product_properties_prototypes foreign key (product_id) references products(id)');
				execute('alter table product_properties add constraint fk_product_properties_properties foreign key (property_id) references properties(id)');
			}
			
			// product_types
			t = createTable(name="product_types",force=true);
			t.string(columnNames="name",null=false);
			t.integer("parent_id");
			t.integer("rgt");
			t.integer("lft");
			t.boolean(columnNames="active",default=true);
			t.create();
			
			addIndex(table="product_types",columnNames="parent_id",indexName="idx_product_types_parent_id");
			addIndex(table="product_types",columnNames="rgt",indexName="idx_product_types_rgt");
			addIndex(table="product_types",columnNames="lft",indexName="idx_product_types_lft");
			
			// slugs
			t = createTable(name="slugs",force=true);
			t.string("name");
			t.integer("sluggable_id");
			t.integer(columnNames="sequence",default=1,null=false);
			t.string(columnNames="sluggable_type",limit=40);
			t.string("scope");
			t.timestamps();
			t.create();
			
			addIndex(table="slugs",columnNames="sluggable_id",indexName="idx_slugs_sluggable_id");
			addIndex(table="slugs",columnNames="name,sluggable_type,sequence,scope",indexName="idx_slugs_name_sluggable_type_sequence_scope",unique=true);
			
			// shipping_categories
			t = createTable(name="shipping_categories",force=true);
			t.string(columnNames="name",null=false);
			t.create();
			
			// phone_types
			t = createTable(name="phone_types",force=true);
			t.string(columnNames="name",null=false);
			t.create();
			
			// phones
			t = createTable(name="phones",force=true);
			t.integer("phone_type_id");
			t.string(columnNames="number,phoneable_type",null=false);
			t.integer(columnNames="phoneable_id",null=false);
			t.boolean(columnNames="primary",default=false);
			t.timestamps();
			t.create();

			addIndex(table="phones",columnNames="phoneable_type",indexName="idx_phones_phoneable_type");
			addIndex(table="phones",columnNames="phoneable_id",indexName="idx_phones_phoneable_id");
			addIndex(table="phones",columnNames="phone_type_id",indexName="idx_phones_phone_type_id");
 
			// suppliers
			t = createTable(name="suppliers",force=true);
			t.string(columnNames="name",null=false);
			t.string("email");
			t.timestamps();
			t.create();
			
 			// variant_suppliers
 			t = createTable(name="variant_suppliers",force=true);
 			t.integer(columnNames="variant_id,supplier_id",null=false);
 			t.decimal(columnNames="cost",precision=8,scale=2,default="0.0",null=false);
 			t.integer(columnNames="total_quantity_supplied",default=0);
 			t.integer(columnNames="min_quantity",default=1);
 			t.integer(columnNames="max_quantity",default=10000);
 			t.boolean(columnNames="active",default=true);
 			t.timestamps();
 			t.create();
 			
 			addIndex(table="variant_suppliers",columnNames="variant_id",indexName="idx_variant_suppliers_variant_id");
 			addIndex(table="variant_suppliers",columnNames="supplier_id",indexName="idx_variant_suppliers_supplier_id");
 
 			// brands
			t = createTable(name="brands",force=true);
			t.string("name");
			t.create();
			
			// purchase_orders
 			t = createTable(name="purchase_orders",force=true);
 			t.integer(columnNames="supplier_id",null=false);
 			t.string(columnNames="invoice_number,tracking_number,notes,state");
 			t.datetime(columnNames="ordered_at",null=false);
 			t.date("estimated_arrival_on");
 			t.decimal(columnNames="total_cost",null=false,default="0.0",precision=8,scale=2);
 			t.timestamps();
 			t.create();
 			
 			addIndex(table="purchase_orders",columnNames="supplier_id",indexName="idx_purchase_orders_supplier_id");
 			addIndex(table="purchase_orders",columnNames="tracking_number",indexName="idx_purchase_orders_tracking_number");
 			
 			// purchase_order_variants
 			t = createTable(name="purchase_order_variants",force=true);
 			t.integer(columnNames="purchase_order_id,variant_id,quantity",null=false);
 			t.decimal(columnNames="cost",precision=8,scale=2,null=false);
 			t.boolean(columnNames="is_received",default=false);
 			t.timestamps();
 			t.create();
 			
 			addIndex(table="purchase_order_variants",columnNames="purchase_order_id",indexName="idx_purchase_order_variants_purchase_order_id");
 			addIndex(table="purchase_order_variants",columnNames="variant_id",indexName="idx_purchase_order_variants_variant_id");
 
 			// images
			t = createTable(name="images",force=true);
			t.integer("imageable_id");
			t.string("imageable_type");
			t.integer("image_height,image_width,position");
			t.string("caption,photo_file_name,photo_content_type");
			t.integer("photo_file_size");
			t.datetime("photo_updated_at");
			t.timestamps();
			t.create();
			
			addIndex(table="images",columnNames="imageable_id",indexName="idx_images_imageable_id");
			addIndex(table="images",columnNames="imageable_type",indexName="idx_images_imageable_type");
			addIndex(table="images",columnNames="position",indexName="idx_images_position");

 			// item_types
			t = createTable(name="item_types",force=true);
			t.string(columnNames="name",null=false);
			t.create();
			
			// cart_items
			t = createTable(name="cart_items",force=true);
			t.integer("user_id,cart_id");
			t.integer(columnNames="variant_id",null=false);
			t.integer(columnNames="quantity",default=1);
			t.boolean(columnNames="active",default=true);
			t.integer(columnNames="item_type_id",null=false);
			t.timestamps();
			t.create();
			
			addIndex(table="cart_items",columnNames="user_id",indexName="idx_cart_items_user_id");
			addIndex(table="cart_items",columnNames="cart_id",indexName="idx_cart_items_cart_id");
			addIndex(table="cart_items",columnNames="variant_id",indexName="idx_cart_items_variant_id");
			addIndex(table="cart_items",columnNames="item_type_id",indexName="idx_cart_items_item_type_id");

			// carts
			t = createTable(name="carts",force=true);
			t.integer("user_id");
			t.timestamps();
			t.create();
			
			addIndex(table="carts",columnNames="user_id",indexName="idx_carts_user_id");

			// orders
			t = createTable(name="orders",force=true);
			t.string("number,ip_address,email,state");
			t.integer("user_id,bill_address_id,ship_address_id,coupon_id,customer_id");
			t.boolean(columnNames="active",default=true,null=false);
			t.boolean(columnNames="shipped",default=false,null=false);
			t.integer(columnNames="shipments_count",default=0);
			t.decimal(columnNames="credited_amount",default="0.0",precision=8,scale=2);
			t.datetime("calculated_at,completed_at");
			t.timestamps();
			t.create();
			
			addIndex(table="orders",columnNames="user_id",indexName="idx_orders_user_id");
			addIndex(table="orders",columnNames="number",indexName="idx_orders_number");
			addIndex(table="orders",columnNames="email",indexName="idx_orders_email");
			addIndex(table="orders",columnNames="bill_address_id",indexName="idx_orders_bill_address_id");
			addIndex(table="orders",columnNames="ship_address_id",indexName="idx_orders_ship_address_id");
			addIndex(table="orders",columnNames="coupon_id",indexName="idx_orders_coupon_id");

			// order_items
			t = createTable(name="order_items",force=true);
			t.decimal(columnNames="price,total",precision=8,scale=2);
			t.integer(columnNames="order_id,variant_id",null=false);
			t.string(columnNames="state",null=false);
			t.integer("tax_rate_id,shipping_rate_id,shipment_id");
			t.timestamps();
			t.create();
			
			addIndex(table="order_items",columnNames="order_id",indexName="idx_order_items_order_id");
			addIndex(table="order_items",columnNames="variant_id",indexName="idx_order_items_variant_id");
			addIndex(table="order_items",columnNames="tax_rate_id",indexName="idx_order_items_tax_rate_id");
			addIndex(table="order_items",columnNames="shipping_rate_id",indexName="idx_order_items_shipping_rate_id");
			addIndex(table="order_items",columnNames="shipment_id",indexName="idx_order_items_shipment_id");
    
			// shipping rates
			t = createTable(name="shipping_rates",force=true);
			t.integer(columnNames="shipping_method_id",null=false);
			t.decimal(columnNames="rate",precision=8,scale=2,default="0.0",null=false);
			t.integer(columnNames="shipping_rate_type_id,shipping_category_id",null=false);
			t.decimal(columnNames="minimum_charge",precision=8,scale=2,default="0.0",null=false);
			t.integer("position");
			t.boolean(columnNames="active",default=true);
			t.timestamps();
			t.create();

			addIndex(table="shipping_rates",columnNames="shipping_category_id",indexName="idx_shipping_rates_shipping_category_id");
			addIndex(table="shipping_rates",columnNames="shipping_method_id",indexName="idx_shipping_rates_shipping_method_id");
			addIndex(table="shipping_rates",columnNames="shipping_rate_type_id",indexName="idx_shipping_rates_shipping_rate_type_id");

			// shipping_rate_types
			t = createTable(name="shipping_rate_types",force=true);
			t.string(columnNames="name",null=false);
			t.create();
			
			// shipping_methods
			t = createTable(name="shipping_methods",force=true);
			t.string(columnNames="name",null=false);
			t.integer(columnNames="shipping_zone_id",null=false);
			t.timestamps();
			t.create();
			
			addIndex(table="shipping_methods",columnNames="shipping_zone_id",indexName="idx_shipping_methods_shipping_zone_id");
			
			// shipping_zones
			t = createTable(name="shipping_zones",force=true);
			t.string(columnNames="name",null=false);
			t.create();
			
			// tax_statuses
			t = createTable(name="tax_statuses",force=true);
			t.string(columnNames="name",null=false);
			t.create();
			
			// tax_rates
			t = createTable(name="tax_rates",force=true);
			t.decimal(columnNames="percentage",precision=8,scale=2,default="0.0",null=false);
			t.integer(columnNames="tax_status_id,state_id",null=false);
			t.date(columnNames="start_date",null=false);
			t.date("end_date");
			t.boolean(columnNames="active",default=true);
			t.create();
			
			addIndex(table="tax_rates",columnNames="tax_status_id",indexName="idx_tax_rates_tax_status_id");
			addIndex(table="tax_rates",columnNames="state_id",indexName="idx_tax_rates_state_id");
			
			// shipments
			t = createTable(name="shipments",force=true);
			t.integer("order_id");
			t.integer(columnNames="shipping_method_id,address_id",null=false);
			t.string("tracking");
			t.string(columnNames="number,state",null=false);
			t.datetime("shipped_at");
			t.boolean(columnNames="active",default=true,null=false);
			t.timestamps();
			t.create();
			
			addIndex(table="shipments",columnNames="shipping_method_id",indexName="idx_shipments_shipping_method_id");
			addIndex(table="shipments",columnNames="address_id",indexName="idx_shipments_address_id");
			addIndex(table="shipments",columnNames="order_id",indexName="idx_shipments_order_id");
			addIndex(table="shipments",columnNames="number",indexName="idx_shipments_number");

			// payment_profiles
			t = createTable(name="payment_profiles",force=true);
			t.integer("user_id,address_id");
			t.string("payment_cim_id");
			t.string(columnNames="last_digits",limit=8);
			t.string(columnNames="month",limit=20);
			t.string(columnNames="year",limit=8);
			t.string(columnNames="cc_type,first_name,last_name",limit=30);
			t.string(columnNames="card_name",limit=120);
			t.boolean("default,active");
			t.timestamps();
			t.create();
			
			addIndex(table="payment_profiles",columnNames="user_id",indexName="idx_payment_profiles_user_id");
			addIndex(table="payment_profiles",columnNames="address_id",indexName="idx_payment_profiles_address_id");

			// invoices
			t = createTable(name="invoices",force=true);
			t.integer(columnNames="order_id",null=false);
			t.decimal(columnNames="amount",null=false,precision=8,scale=2);
			t.string(columnNames="invoice_type",default="#get('invoice_purchase')#",null=false);
			t.decimal(columnNames="credited_amount",default="0.0",precision=8,scale=2);
			t.string(columnNames="state",null=false);
			t.boolean(columnNames="active",null=false,default=true);
			t.timestamps();
			t.create();
			
			addIndex(table="invoices",columnNames="order_id",indexName="idx_invoices_order_id");

			// payments
			t = createTable(name="payments",force=true);
			t.integer("invoice_id");
			t.string("confirmation_id");
			t.integer("amount");
			t.string(columnNames="error,error_code,message,action");
			t.text("params");
			t.boolean(columnNames="success,test");
			t.timestamps();
			t.create();
			
			addIndex(table="payments",columnNames="invoice_id",indexName="idx_payments_invoice_id");
			
			// batches
			t = createTable(name="batches",force=true);
			t.string("batchable_type");
			t.integer("batchable_id");
			t.string("name");
			t.timestamps();
			t.create();
			
			addIndex(table="batches",columnNames="batchable_type",indexName="idx_batches_batchable_type");
			addIndex(table="batches",columnNames="batchable_id",indexName="idx_batches_batchable_id");

			// transactions
			t = createTable(name="transactions",force=true);
			t.string("type");
			t.integer("batch_id");
			t.timestamps();
			t.create();
			
			addIndex(table="transactions",columnNames="batch_id",indexName="idx_transactions_batch_id");

			// transaction_ledgers
			t = createTable(name="transaction_ledgers",force=true);
			t.string("accountable_type");
			t.integer(columnNames="accountable_id,transaction_id,transaction_account_id");
			t.decimal(columnNames="tax_amount",precision=8,scale=2,default="0.0");
			t.decimal(columnNames="debit",precision=8,scale=2,null=false);
			t.decimal(columnNames="credit",precision=8,scale=2,null=false);
			t.string("period");
			t.timestamps();
			t.create();
			
			addIndex(table="transaction_ledgers",columnNames="accountable_id",indexName="idx_transaction_ledgers_accountable_id");
			addIndex(table="transaction_ledgers",columnNames="transaction_id",indexName="idx_transaction_ledgers_transaction_id");
			addIndex(table="transaction_ledgers",columnNames="transaction_account_id",indexName="idx_transaction_ledgers_transaction_account_id");			

			// transaction_accounts
			t = createTable(name="transaction_accounts",force=true);
			t.string(columnNames="name");
			t.timestamps();
			t.create();
			
			// return_authorizations
			t = createTable(name="return_authorizations",force=true);
			t.string("number");
			t.decimal(columnNames="amount",precision=8,scale=2,null=false);
			t.decimal(columnNames="restocking_fee",precision=8,scale=2,default="0");
			t.integer(columnNames="order_id,user_id",null=false);
			t.string(columnNames="state",null=false);
			t.integer("created_by");
			t.boolean(columnNames="active",default=true);
			t.timestamps();
			t.create();
			
			addIndex(table="return_authorizations",columnNames="number",indexName="idx_return_authorizations_number");
			addIndex(table="return_authorizations",columnNames="order_id",indexName="idx_return_authorizations_order_id");
			addIndex(table="return_authorizations",columnNames="user_id",indexName="idx_return_authorizations_user_id");
			addIndex(table="return_authorizations",columnNames="created_by",indexName="idx_return_authorizations_created_by");

			// return_items
			t = createTable(name="return_items",force=true);
			t.integer(columnNames="return_authorization_id,order_item_id",null=false);
			t.integer(columnNames="return_condition_id,return_reason_id");
			t.boolean(columnNames="returned",default=false);
			t.integer("updated_by");
			t.timestamps();
			t.create();
			
			addIndex(table="return_items",columnNames="return_authorization_id",indexName="idx_return_items_return_authorization_id");
			addIndex(table="return_items",columnNames="order_item_id",indexName="idx_return_items_order_item_id");
			addIndex(table="return_items",columnNames="return_condition_id",indexName="idx_return_items_return_condition_id");
			addIndex(table="return_items",columnNames="return_reason_id",indexName="idx_return_items_return_reason_id");
			addIndex(table="return_items",columnNames="updated_by",indexName="idx_return_items_updated_by");

			// comments
			t = createTable(name="comments",force=true);
			t.text("note");
			t.string("commentable_type");
			t.integer(columnNames="commentable_id,created_by,user_id");
			t.timestamps();
			t.create();
			
			addIndex(table="comments",columnNames="commentable_type",indexName="idx_comments_commentable_type");
			addIndex(table="comments",columnNames="commentable_id",indexName="idx_comments_commentable_id");
			addIndex(table="comments",columnNames="created_by",indexName="idx_comments_created_by");
			addIndex(table="comments",columnNames="user_id",indexName="idx_comments_user_id");

			// return_conditions
			t = createTable(name="return_conditions",force=true);
			t.string(columnNames="label,description");
			t.create();

			// return_reasons
			t = createTable(name="return_reasons",force=true);
			t.string(columnNames="label,description");
			t.create();
			
			// store_credits
			t = createTable(name="store_credits",force=true);
			t.decimal(columnNames="amount",default="0.0",precision=8,scale=2);
			t.integer(columnNames="user_id",null=false);
			t.timestamps();
			t.create();
			
			addIndex(table="store_credits",columnNames="user_id",indexName="idx_store_credits_user_id");
			
			// coupons
			t = createTable(name="coupons",force=true);
			t.string(columnNames="type,code",null=false);
			t.decimal(columnNames="amount",precision=8,scale=2,default=0);
			t.decimal(columnNames="minimum_value",precision=8,scale=2);
			t.integer(columnNames="percent",default=0);
			t.text(columnNames="description",null=false);
			t.boolean(columnNames="combine",default=false);
			t.datetime(columnNames="starts_at,expires_at");
			t.timestamps();
			t.create();
			
			addIndex(table="coupons",columnNames="code",indexName="idx_coupons_code");
			addIndex(table="coupons",columnNames="expires_at",indexName="idx_coupons_expires_at");
		
			// inventories
			t = createTable(name="inventories",force=true);
			t.integer(columnNames="count_on_hand,count_pending_to_customer,count_pending_from_supplier",default=0);
			t.create();
			
			// accounting_adjustments
			t = createTable(name="accounting_adjustments",force=true);
			t.integer(columnNames="adjustable_id",null=false);
			t.string(columnNames="adjustable_type",null=false);
			t.string("notes");
			t.decimal(columnNames="amount",precision=8,scale=2,null=false);
			t.timestamps();
			t.create();
				
	
		</cfscript>
	</cffunction>
	
	<cffunction name="down">
		<cfscript>

			dropTable("accounts");
			dropTable("users");
			dropTable("states");
			dropTable("countries");
			dropTable("addresses");
			dropTable("address_types");
			dropTable("roles");
			dropTable("user_roles");
			dropTable("prototypes");
			dropTable("properties");
			dropTable("prototype_properties");
			dropTable("products");
			dropTable("variants");
			dropTable("variant_properties");
			dropTable("product_properties");
			dropTable("product_types");
			dropTable("slugs");
			dropTable("shipping_categories");
			dropTable("phone_types");
			dropTable("phones");
			dropTable("suppliers");
			dropTable("variant_suppliers");
			dropTable("brands");
			dropTable("purchase_orders");
			dropTable("purchase_order_variants");
			dropTable("images");
			dropTable("item_types");
			dropTable("cart_items");
			dropTable("carts");
			dropTable("orders");
			dropTable("order_items");
			dropTable("shipping_rates");
			dropTable("shipping_rate_types");
			dropTable("shipping_methods");
			dropTable("shipping_zones");
			dropTable("tax_statuses");
			dropTable("tax_rates");
			dropTable("shipments");
			dropTable("payment_profiles");
			dropTable("invoices");
			dropTable("payments");
			dropTable("batches");
			dropTable("transactions");
			dropTable("transaction_ledgers");
			dropTable("transaction_accounts");
			dropTable("return_authorizations");
			dropTable("return_items");
			dropTable("comments");
			dropTable("return_conditions");
			dropTable("return_reasons");
			dropTable("store_credits");
			dropTable("coupons");
			dropTable("inventories");
			dropTable("accounting_adjustments");
			
		</cfscript>
	</cffunction>
	
</cfcomponent>