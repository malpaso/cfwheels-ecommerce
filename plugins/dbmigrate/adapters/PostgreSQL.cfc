<cfcomponent extends="Abstract">

	<cfset variables.sqlTypes = {}>
	<cfset variables.sqlTypes['primaryKey'] = "SERIAL PRIMARY KEY">
	<cfset variables.sqlTypes['binary'] = {name='BYTEA'}>
	<cfset variables.sqlTypes['boolean'] = {name='BOOLEAN'}>
	<cfset variables.sqlTypes['date'] = {name='DATE'}>
	<cfset variables.sqlTypes['datetime'] = {name='TIMESTAMP'}>
	<cfset variables.sqlTypes['decimal'] = {name='DECIMAL'}>
	<cfset variables.sqlTypes['float'] = {name='FLOAT'}>
	<cfset variables.sqlTypes['integer'] = {name='INTEGER'}>
	<cfset variables.sqlTypes['string'] = {name='CHARACTER VARYING',limit=255}>
	<cfset variables.sqlTypes['text'] = {name='TEXT'}>
	<cfset variables.sqlTypes['time'] = {name='TIME'}>
	<cfset variables.sqlTypes['timestamp'] = {name='TIMESTAMP'}>

	<cffunction name="adapterName" returntype="string" access="public" hint="name of database adapter">
		<cfreturn "PostgreSQL">
	</cffunction>
	
	<cffunction name="addColumnOptions" returntype="string" access="public">
		<cfargument name="sql" type="string" required="true" hint="column definition sql">
		<cfargument name="type" type="string" required="false" hint="column type">
		<cfargument name="options" type="struct" required="false" default="#StructNew()#" hint="column options">
		<cfscript>
		if(StructKeyExists(arguments.options,'type') && arguments.options.type != 'primaryKey') {
			if(StructKeyExists(arguments.options,'default') && optionsIncludeDefault(argumentCollection=arguments.options)) {
				if(arguments.options.default eq "NULL" || (arguments.options.default eq "" && ListFindNoCase("boolean,date,datetime,time,timestamp,decimal,float,integer",arguments.options.type))) {
					arguments.sql = arguments.sql & " DEFAULT NULL";
				} else if(arguments.options.type == 'boolean') {
					arguments.sql = arguments.sql & " DEFAULT #IIf(arguments.options.default,de('true'),de('false'))#";
				} else {
					arguments.sql = arguments.sql & " DEFAULT #quote(value=arguments.options.default,options=arguments.options)#";
				}
			}
			if(StructKeyExists(arguments.options,'null') && !arguments.options.null) {
				arguments.sql = arguments.sql & " NOT NULL";
			}
		}
		</cfscript>
		<cfreturn arguments.sql>
	</cffunction>
	
	<!--- postgres uses double quotes --->
	<cffunction name="quoteTableName" returntype="string" access="public" hint="surrounds table or index names with quotes">
		<cfargument name="name" type="string" required="true" hint="column name">
		<cfreturn '"#Replace(arguments.name,".","`.`","ALL")#"'>
	</cffunction>

	<!--- postgres uses double quotes --->
	<cffunction name="quoteColumnName" returntype="string" access="public" hint="surrounds column names with quotes">
		<cfargument name="name" type="string" required="true" hint="column name">
		<cfreturn '"#arguments.name#"'>
	</cffunction>

	<!--- createTable - use default --->
	<cffunction name="createTable" returntype="string" access="public" hint="generates sql to create a table">
		<cfargument name="name" type="string" required="true" hint="table name">
		<cfargument name="columns" type="array" required="true" hint="array of column definitions">
		<cfargument name="foreignKeys" type="array" required="false" default="#ArrayNew(1)#" hint="array of foreign key definitions">
		<cfscript>
		var loc = {};
		loc.sql = "CREATE TABLE #quoteTableName(LCase(arguments.name))# (#chr(13)##chr(10)#";
		loc.iEnd = ArrayLen(arguments.columns);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++) {
			loc.sql = loc.sql & " " & arguments.columns[loc.i].toSQL();
			if(loc.i != loc.iEnd) { loc.sql = loc.sql & ",#chr(13)##chr(10)#"; }
		}
		loc.iEnd = ArrayLen(arguments.foreignKeys);
		for (loc.i=1; loc.i <= loc.iEnd; loc.i++) {
			loc.sql = loc.sql & ",#chr(13)##chr(10)# " & arguments.foreignKeys[loc.i].toSQL();
		}
		loc.sql = loc.sql & "#chr(13)##chr(10)#)";
		</cfscript>
		<cfreturn loc.sql>
	</cffunction>
	
	<cffunction name="renameTable" returntype="string" access="public" hint="generates sql to rename a table">
		<cfargument name="oldName" type="string" required="true" hint="old table name">
		<cfargument name="newName" type="string" required="true" hint="new table name">
		<cfreturn "ALTER TABLE #quoteTableName(arguments.oldName)# RENAME TO #quoteTableName(arguments.newName)#">
	</cffunction>

	<!--- dropTable - use default --->
	
	<!--- NOTE FOR addColumnToTable & changeColumnInTable 
		  Rails adaptor appears to be applying default/nulls in separate queries
		  Need to check if that is necessary --->
	<!--- addColumnToTable - ? --->
	<!--- changeColumnInTable - ? --->
	
	<!--- renameColumnInTable - use default --->
	
	<!--- dropColumnFromTable - use default --->
	
	<!--- addForeignKeyToTable - use default --->
	
	<cffunction name="dropForeignKeyFromTable" returntype="string" access="public" hint="generates sql to add a foreign key constraint to a table">
		<cfargument name="name" type="string" required="true" hint="table name">
		<cfargument name="keyName" type="any" required="true" hint="foreign key name">
		<cfreturn "ALTER TABLE #quoteTableName(LCase(arguments.name))# DROP CONSTRAINT #quoteTableName(arguments.keyname)#">
	</cffunction>
	
	<!--- foreignKeySQL - use default --->
	
	<!--- addIndex - use default --->
	
	<!--- removeIndex - use default --->

</cfcomponent>