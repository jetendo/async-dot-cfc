<cfcomponent>
<cffunction name="index" access="remote">
	<cfscript>
	var asyncInitStruct={
		threadTimeout: 1000,
		threadDuration: 1000,
		threadNamePrefix: 'asyncThread',
		enableGlobalThreadLimit: true, 
		maxThreads: 8,
		debug: true
	}
	var asyncInstance=createobject("component", "async").init(asyncInitStruct);
	var exampleInstance=createobject("component", "example");
	var data={ "test": 1 };
	
	// create many workUnits to be executed together as a group
	var arrWorkUnit=[];
	for(var i=1;i LTE 100;i++){
		arrayAppend(arrWorkUnit, asyncInstance.createWorkUnit(exampleInstance, "workMethod", exampleInstance, "callbackMethod", data));
	}
	asyncInstance.executeWorkUnitGroup(arrWorkUnit, exampleInstance, "groupCallbackMethod");
	while(asyncInstance.hasWork()){
		// do other work
		sleep(1); // wait for 1 millisecond before polling again
	}
	</cfscript>
</cffunction>
	
<cffunction name="workMethod" access="public">
	<cfargument name="threadStruct" type="struct" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	// do some slower work
	arguments.threadStruct.test=arguments.dataStruct.test;
	sleep(5);
	</cfscript>
</cffunction>

<cffunction name="callbackMethod" access="public">
	<cfargument name="workUnit" type="struct" required="yes">
	<cfscript> 
	arguments.workUnit.data.message="workUnit callbackMethod was executed. data key test = "&arguments.workUnit.data.test;
	</cfscript>
</cffunction>

<cffunction name="groupCallbackMethod" access="public">
	<cfargument name="arrWorkUnit" type="array" required="yes">
	<cfscript>
	var total=0;
	for(var i=1;i LTE arrayLen(arguments.arrWorkUnit);i++){
		total+=arguments.arrWorkUnit[i].thread.test;
		writeoutput(arguments.arrWorkUnit[i].data.message&"<br />");
	}
	writeoutput('Total:'&total);
	</cfscript>
</cffunction>
</cfcomponent>