<cfcomponent extends="plugins.dbmigrate.Migration" hint="Initial database creation" output="false">

	<cffunction name="up">
		<cfscript>

			// accounts
			t = createTable("accounts");
			t.string(columnNames="name,account_type",null=false);
			t.decimal(columnNames="monthly_charge",null=false,default="0.0",precision=8,scale=2);
			t.boolean(columnNames="active",default=true,null=false);
			t.timestamps();
			t.create();

			// users
			t = createTable("users");
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
			t = createTable("states");
			t.string(columnNames="name",null=false);
			t.string(columnNames="abbreviation",null=false,limit=5);
			t.string("described_as");
			t.integer(columnNames="country_id,shipping_zone_id",null=false);
			t.create();
			
			addIndex(table="states",columnNames="name",indexName="idx_states_name");
			addIndex(table="states",columnNames="country_id",indexName="idx_states_country_id");
			addIndex(table="states",columnNames="abbreviation",indexName="idx_states_abbreviation");
	
			// countries
			t = createTable("countries");
			t.string("name");
			t.string(columnNames="abbreviation",limit=5);
			t.create();
			
			addIndex(table="countries",columnNames="name",indexName="idx_countries_name");
			
			if(get("use_foreign_keys")){
				execute("alter table states add constraint fk_states_countries foreign key (country_id) references countries(id);");
			}

			// addresses
			t = createTable("addresses");
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
			t = createTable("address_types");
			t.string(columnNames="name",null=false,limit=64);
			t.string("description");
			t.create();
			
			addIndex(table="address_types",columnNames="name",indexName="idx_address_types_name");

			// roles
			t = createTable("roles");
			t.string(columnNames="name",null=false,limit=30);
			
			addIndex(table="roles",columnNames="name",indexName="idx_roles_name");
			
			// user_roles
			t = createTable("user_roles");
			t.integer(columnNames="role_id,user_id",null=false);
			
			addIndex(table="user_roles",columnNames="role_id",indexName="idx_user_roles_role_id");
			addIndex(table="user_roles",columnNames="user_id",indexName="idx_user_roles_user_id");
			
			if(get('use_foreign_keys')){
				execute('alter table user_roles add constraint fk_user_roles_role_id foreign key (role_id) references roles(id)');
				execute('alter table user_roles add constraint fk_user_roles_user_id foreign key (user_id) references users(id)');
			}
			
			// prototypes
			t = createTable("prototypes");
			t.string(columnNames="name",null=false);
			t.boolean(columnNames="active",default=true,null=false);
			t.create();
			
			// properties
			t = createTable("properties");
			t.string(columnNames="identifying_name",null=false);
			t.string("display_name");
			t.boolean(columnNames="active",default=true);
			t.create();
			
			// prototype_properties
			t = createTable("prototype_properties");
			t.integer(columnNames="prototype_id,property_id",null=false);
			t.create();
			
			addIndex(table="prototype_properties",columnNames="prototype_id",indexName="idx_prototype_properties_prototype_id");
			addIndex(table="prototype_properties",columnNames="property_id",indexName="idx_prototype_properties_property_id");
			
			if(get('use_foreign_keys')){
				execute('alter table prototype_properties add constraint fk_prototype_properties_prototypes foreign key (prototype_id) references prototypes(id)');
				execute('alter table prototype_properties add constraint fk_prototype_properties_properties foreign key (property_id) references properties(id)');
			}			

			// products
			t = createTable("products");
			t.string(columnNames="name",null=false);
			t.text(columnNames="description,product_keywords");
			t.integer("tax_category_id");
			t.integer(columnNames="product_type_id",null=false);
			t.integer("prototype_id");
			t.integer(columnNames="shipping_category_id,tax_status_id",null=false);
			t.string(columnNames="permalink",null=false);
			t.datetime(columnNames="available_at");
			t.string(columnNames="meta_keywords,meta_description");
			t.boolean(columnNames="featured",default=false);
			t.timestamps();
			t.create();
			
			addIndex(table="products",columnNames="name",indexName="idx_products_name");
			addIndex(table="products",columnNames="tax_category_id",indexName="idx_products_tax_category_id");
			addIndex(table="products",columnNames="product_type_id",indexName="idx_products_product_type_id");
			addIndex(table="products",columnNames="shipping_category_id",indexName="idx_products_shipping_category_id");
			addIndex(table="products",columnNames="prototype_id",indexName="idx_products_prototype_id");
			addIndex(table="products",columnNames="permalink",indexName="idx_products_permalink",unique=true);

			// variants
			t = createTable("variants");
			t.integer(columnNames="product_id",null=false);
			t.string(columnNames="sku",null=false);
			t.string("name");
			t.decimal(columnNames="price,cost",null=false,precision=8,scale=2,default="0.0");
			t.boolean(columnNames="master",default=false,null=false);
			t.integer(columnNames="count_on_hand,count_pending_to_customer,count_pending_from_supplier",default=0,null=false);
			t.timestamps();
			t.create();
			
			addIndex(table="variants",columnNames="sku",indexName="idx_variants_sku");
			addIndex(table="variants",columnNames="product_id",indexName="idx_variants_product_id");
			
			if(get('use_foreign_keys')){
				execute('alter table variants add constraint fk_variants_products foreign key (product_id) references products(id)');
			}
			
			// variant_properties
			t = createTable("variant_properties");
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
 			t = createTable("product_properties");
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
			t = createTable("product_types");
			t.string(columnNames="name",null=false);
			t.integer("parent_id");
			t.boolean(columnNames="active",default=true);
			t.create();
			
			addIndex(table="product_types",columnNames="parent_id",indexName="idx_product_types_parent_id");
			
			// slugs
			t = createTable("slugs");
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
			t = createTable("shipping_categories");
			t.string(columnNames="name",null=false);
			t.create();
			
			// phone_types
			t = createTable("phone_types");
			t.string(columnNames="name",null=false);
			t.create();
			
			// phones
			t = createTable("phones");
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
			t = createTable("suppliers");
			t.string(columnNames="name",null=false);
			t.string("email");
			t.timestamps();
			t.create();
			
 			// variant_suppliers
 			t = createTable("variant_suppliers");
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
			t = createTable("brands");
			t.string("name");
			t.create();
			
			// purchase_orders
 			t = createTable("purchase_orders");
 			t.integer(columnNames="supplier_id",null=false);
 			t.string(columnNames="invoice_number,tracking_number,notes,state");
 			t.datetime(columnNames="ordered_at",null=false);
 			t.date("estimated_arrival_on");
 			t.timestamps();
 			t.create();
 			
 			addIndex(table="purchase_orders",columnNames="supplier_id",indexName="idx_purchase_orders_supplier_id");
 			addIndex(table="purchase_orders",columnNames="tracking_number",indexName="idx_purchase_orders_tracking_number");
 			
 			// purchase_order_variants
 			t = createTable("purchase_order_variants");
 			t.integer(columnNames="purchase_order_id,variant_id,quantity",null=false);
 			t.decimal(columnNames="cost",precision=8,scale=2,null=false);
 			t.boolean(columnNames="is_received",default=false);
 			t.timestamps();
 			t.create();
 			
 			addIndex(table="purchase_order_variants",columnNames="purchase_order_id",indexName="idx_purchase_order_variants_purchase_order_id");
 			addIndex(table="purchase_order_variants",columnNames="variant_id",indexName="idx_purchase_order_variants_variant_id");
 
 			// images
			t = createTable("images");
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
			t = createTable("item_types");
			t.string("name");
			t.create();
			
			// cart_items
			t = createTable("cart_items");
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
			t = createTable("carts");
			t.integer("user_id");
			t.timestamps();
			t.create();
			
			addIndex(table="carts",columnNames="user_id",indexName="idx_carts_user_id");

			// orders
			t = createTable("orders");
			t.string("number,ip_address,email,state");
			t.integer("user_id,bill_address_id,ship_address_id,coupon_id");
			t.boolean(columnNames="active",default=true,null=false);
			t.boolean(columnNames="shipped",default=false,null=false);
			t.integer(columnNames="shipment_counter",default=0);
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
			t = createTable("order_items");
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
			
		</cfscript>
	</cffunction>
	
</cfcomponent>