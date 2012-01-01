<cfset set(dataSourceName="cfecommerce")>
<cfset set(dataSourceUserName="")>
<cfset set(dataSourcePassword="")>

<cfset set(URLRewriting="On")>

<cfset set(overwritePlugins=false)>

<!--- ORM settings --->
<cfset set(timeStampOnCreateProperty="created_at")>
<cfset set(timeStampOnUpdateProperty="updated_at")>
<cfset set(softDeleteProperty="deleted_at")>

<cfset set(use_foreign_keys=true)>
<cfset set(invoice_purchase="")>